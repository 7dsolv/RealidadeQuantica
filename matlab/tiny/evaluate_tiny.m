function report = evaluate_tiny(root, output, compiled)
%EVALUATE_TINY Avalia pesos de terceiros, adaptador local e quantizacao propria.
if nargin<3, compiled=false; end
if ~isfolder(output), mkdir(output); end
m=tiny_load_model(root);
[calibration,~]=tiny_windows(512,7301);
[data,truth]=tiny_windows(1024,7302);
q=tiny_quantize(m,calibration);
[fp,fp_label]=tiny_fp32(m,data);
[iq,iq_label,status]=tiny_int8(q,data);
reference=jsondecode(fileread(fullfile(root,'models','anomalynet','reference.json')));
tests={@reference_logits,@parameter_count,@quantized_types,@paired_agreement, ...
    @invalid_input,@batch_consistency,@determinism,@hash_rejection};
if compiled, tests=[tests {@fortran_logits}]; end
report.revision=getenv('GITHUB_SHA'); report.source_model=m.source.model;
report.source_revision=m.source.revision; report.weights_trained_by='Eoin Jordan';
report.data_origin='KONAET synthetic evaluation, not original training/test set';
report.calibration_seed=7301; report.evaluation_seed=7302;
report.calibration_windows=512; report.evaluation_windows=1024;
report.accuracy_fp32=mean(fp_label==truth);
report.accuracy_int8=mean(iq_label==truth);
report.decision_agreement=mean(fp_label==iq_label);
report.invalid_windows=sum(~status.representable);
report.hidden_saturations=sum(status.hidden_saturations);
report.fp32_confusion=[sum(truth==0 & fp_label==0),sum(truth==0 & fp_label==1); ...
    sum(truth==1 & fp_label==0),sum(truth==1 & fp_label==1)];
report.int8_confusion=[sum(truth==0 & iq_label==0),sum(truth==0 & iq_label==1); ...
    sum(truth==1 & iq_label==0),sum(truth==1 & iq_label==1)];
report.model_fp32_bytes=3368; report.model_int8_payload_bytes=q.payload_bytes;
report.mcu_latency='NOT_MEASURED'; report.mcu_flash_ram='NOT_MEASURED';
report.device_integration='NOT_DEPLOYED'; report.network_required_for_inference=false;
report.passed=0; report.failed=0;
report.tests=struct('name',{},'passed',{},'message',{});
for k=1:numel(tests)
    ok=true; message='';
    try, tests{k}(); catch err, ok=false; message=err.message; end
    report.tests(k)=struct('name',func2str(tests{k}),'passed',ok,'message',message);
    report.passed=report.passed+ok; report.failed=report.failed+~ok;
    fprintf('%s %s %s\n',string(ok),func2str(tests{k}),message);
end
report.total=numel(tests);
write_json(fullfile(output,'tiny-report.json'),report);
assert(report.failed==0,'Tiny: %d testes falharam.',report.failed);
writetable(table(truth.',fp_label.',iq_label.',fp(1,:).',fp(2,:).',iq(1,:).',iq(2,:).', ...
    'VariableNames',{'truth','fp32_label','int8_label','fp32_normal_logit','fp32_anomaly_logit', ...
    'int8_normal_logit','int8_anomaly_logit'}),fullfile(output,'tiny-predictions.csv'));
fid=fopen(fullfile(output,'anomalynet-int8.bin'),'wb','ieee-le'); assert(fid>=0);
guard=onCleanup(@() fclose(fid));
fwrite(fid,q.W1.','int8'); fwrite(fid,q.b1,'int32'); fwrite(fid,q.W2.','int8'); fwrite(fid,q.b2,'int32'); clear guard;
assert(dir(fullfile(output,'anomalynet-int8.bin')).bytes==920);
meta=rmfield(q,{'W1','W2','b1','b2'});
meta.format='W1 row-major int8[24,32], b1 int32[24], W2 row-major int8[2,24], b2 int32[2]; little endian';
meta.model_credit='AnomalyNet, Copyright 2026 Eoin Jordan, Apache-2.0';
write_json(fullfile(output,'quantization.json'),meta);
save(fullfile(output,'tiny-model.mat'),'m','q','report');
f=figure('Visible','off','Color',[0.04 0.025 0.07],'Position',[30 30 1250 620]);
guard=onCleanup(@() close(f)); %#ok<NASGU>
tiledlayout(f,1,2,'Padding','loose');
ax=nexttile; imagesc(ax,report.int8_confusion); colorbar(ax);
xticks(ax,[1 2]); yticks(ax,[1 2]); xticklabels(ax,{'Normal','Anomalia'}); yticklabels(ax,{'Normal','Anomalia'});
xlabel(ax,'Classe prevista INT8'); ylabel(ax,'Classe sintética real');
for a=1:2, for b=1:2, text(ax,b,a,num2str(report.int8_confusion(a,b)),'HorizontalAlignment','center','FontWeight','bold','FontSize',24,'Color','white'); end, end
title(ax,'KONAET / ADAPTADOR ANOMALYNET');
ax2=nexttile; scatter(ax2,fp(2,:)-fp(1,:),iq(2,:)-iq(1,:),8,double(truth),'filled');
grid(ax2,'on'); xlabel(ax2,'Margem FP32'); ylabel(ax2,'Margem INT8');
title(ax2,sprintf('Concordância: %.2f%% / 1.024 janelas sintéticas',100*report.decision_agreement));
exportgraphics(f,fullfile(output,'tiny-evaluation.png'),'Width',1500,'Height',740,'Units','pixels','Padding','figure','BackgroundColor','white');
fprintf('Tiny: %d/%d testes; FP32 %.2f%%, INT8 %.2f%%; payload %d bytes.\n', ...
    report.passed,report.total,100*report.accuracy_fp32,100*report.accuracy_int8,q.payload_bytes);

    function reference_logits()
        ref=tiny_fp32(m,single(reference.input_normalized(:))*20+50);
        assert(max(abs(double(ref)-reference.logits(:)))<4e-5);
    end
    function parameter_count()
        assert(numel(m.W1)+numel(m.W2)+numel(m.b1)+numel(m.b2)==842);
        assert(q.payload_bytes==920);
    end
    function quantized_types()
        assert(isa(q.W1,'int8') && isa(q.W2,'int8') && isa(q.b1,'int32') && isa(q.b2,'int32'));
        assert(all(isfinite(iq),'all') && all(status.representable));
    end
    function paired_agreement()
        assert(report.decision_agreement>=0.95,'Concordancia INT8 inferior ao criterio de 95%%.');
    end
    function invalid_input()
        x=ones(32,2)*50; x(1,1)=NaN; x(1,2)=200;
        [~,pred,s]=tiny_int8(q,x);
        assert(all(pred==-1) && ~any(s.representable));
    end
    function batch_consistency()
        for j=1:8
            [value,pred]=tiny_int8(q,data(:,j));
            assert(isequal(value,iq(:,j)) && pred==iq_label(j));
        end
    end
    function determinism()
        state=rng;
        [other,y]=tiny_windows(1024,7302);
        assert(isequal(data,other) && isequal(truth,y) && isequal(state,rng));
    end
    function hash_rejection()
        fixture=fullfile(output,'corrupt-fixture'); folder=fullfile(fixture,'models','anomalynet');
        if ~isfolder(folder), mkdir(folder); end
        copyfile(fullfile(root,'models','anomalynet','*'),folder);
        path=fullfile(folder,'fc1_weight.f32'); fid=fopen(path,'r+b'); assert(fid>=0);
        fwrite(fid,uint8([0 0 0 0]),'uint8'); fclose(fid);
        rejected=false;
        try, tiny_load_model(fixture); catch, rejected=true; end
        assert(rejected,'Tensor corrompido foi aceito.');
    end
    function fortran_logits()
        input=fullfile(output,'tiny-input.csv'); result=fullfile(output,'tiny-fortran.csv');
        writematrix(data(:,1:64).',input);
        command=sprintf('"%s" "%s" "%s" "%s"',fullfile(root,'build','tiny_anomalynet'),fullfile(root,'models','anomalynet'),input,result);
        [status_code,message]=system(command); assert(status_code==0,'%s',message);
        values=readmatrix(result);
        assert(isequal(size(values),[64 2]));
        assert(max(abs(values-double(fp(:,1:64).')),[],'all')<2e-4);
    end
end

function write_json(path,value)
fid=fopen(path,'w','n','UTF-8'); assert(fid>=0);
guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s\n',jsonencode(value,PrettyPrint=true));
end
