function report = evaluate_tiny(root, output, compiled)
%EVALUATE_TINY Avalia pesos de terceiros, adaptador local e quantizacao propria.
if nargin<3, compiled=false; end
if ~isfolder(output), mkdir(output); end
m=tiny_load_model(root);
[calibration,~]=tiny_windows(512,7301);
[data,truth]=tiny_windows(1024,7302);
q=tiny_quantize(m,calibration);
tiny_export_int8(q,output);
[fp,fp_label]=tiny_fp32(m,data);
[iq,iq_label,status]=tiny_int8(q,data);
reference=jsondecode(fileread(fullfile(root,'models','anomalynet','reference.json')));
tests={@reference_logits,@parameter_count,@quantized_types,@paired_agreement, ...
    @invalid_input,@batch_consistency,@determinism,@hash_rejection,@export_roundtrip};
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
kinds={'spike','dropout','runaway_ramp','noise_burst'};
anomaly_indices=find(truth==1);
for k=1:4
    indices=anomaly_indices(k:4:end);
    report.by_anomaly_type(k)=struct('kind',kinds{k},'windows',numel(indices), ...
        'recall_fp32',mean(fp_label(indices)==1),'recall_int8',mean(iq_label(indices)==1));
end
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
save(fullfile(output,'tiny-model.mat'),'m','q','report');
f=figure('Visible','off','Color','white','Position',[30 30 1250 620]);
guard=onCleanup(@() close(f)); %#ok<NASGU>
tiledlayout(f,1,2,'Padding','loose');
ax=nexttile; imagesc(ax,report.int8_confusion); colorbar(ax);
colormap(ax,interp1([0 1],[0.95 0.92 0.99;0.36 0.12 0.58],linspace(0,1,256)));
xticks(ax,[1 2]); yticks(ax,[1 2]); xticklabels(ax,{'Normal','Anomalia'}); yticklabels(ax,{'Normal','Anomalia'});
xlabel(ax,'Classe prevista INT8'); ylabel(ax,'Classe sintética real');
for a=1:2, for b=1:2
    color=[0.15 0.10 0.22]; if report.int8_confusion(a,b)>max(report.int8_confusion,[],'all')/2, color=[1 1 1]; end
    text(ax,b,a,num2str(report.int8_confusion(a,b)),'HorizontalAlignment','center','FontWeight','bold','FontSize',24,'Color',color);
end, end
title(ax,'KONAET / ADAPTADOR ANOMALYNET');
ax2=nexttile; margin_fp=fp(2,:)-fp(1,:); margin_iq=iq(2,:)-iq(1,:);
scatter(ax2,margin_fp(truth==0),margin_iq(truth==0),12,[0.36 0.12 0.58],'filled'); hold(ax2,'on');
scatter(ax2,margin_fp(truth==1),margin_iq(truth==1),12,[0.05 0.5 0.5],'filled');
legend(ax2,{'Normal sintetico','Anomalia sintetica'},'Location','northwest');
grid(ax2,'on'); xlabel(ax2,'Margem FP32'); ylabel(ax2,'Margem INT8');
title(ax2,sprintf('Concordância: %.2f%% / 1.024 janelas sintéticas',100*report.decision_agreement));
set([ax ax2],'Color','white','XColor',[0.16 0.12 0.22],'YColor',[0.16 0.12 0.22],'FontSize',12);
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
    function export_roundtrip()
        restored=tiny_load_int8(output);
        [values,pred]=tiny_int8(restored,data);
        assert(isequal(q.W1,restored.W1) && isequal(q.b1,restored.b1));
        assert(isequal(q.W2,restored.W2) && isequal(q.b2,restored.b2));
        assert(isequal(values,iq) && isequal(pred,iq_label));
    end
end

function write_json(path,value)
fid=fopen(path,'w','n','UTF-8'); assert(fid>=0);
guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s\n',jsonencode(value,PrettyPrint=true));
end
