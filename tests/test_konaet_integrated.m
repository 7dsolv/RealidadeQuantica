function report = test_konaet_integrated(root,output)
%TEST_KONAET_INTEGRATED Verificacao numerica, treino, dados e retomada real.
data=load(fullfile(output,'benchmark.mat')); result=data.result;
tests={@gradient_check,@reproducible_data,@reproducible_training,@locked_test, ...
    @weights_are_new,@training_loss,@quantized_fidelity,@model_roundtrip, ...
    @source_interop,@real_data_audit,@invalid_sensor,@rc_step,@rc_energy, ...
    @rc_passivity,@metrics_abstention,@memory_resume,@csv_interface, ...
    @bundle_tampering,@metadata_tampering,@memory_rejects_incompatible, ...
    @contract_covers_dependencies,@context_is_label_free,@uncertainty_reproducible, ...
    @local_memory_compare_and_swap,@bounded_stream_history,@no_representable_calibration, ...
    @qualification_rejects_abstention,@evidence_rejects_metric_drift,@bench_capture_contract};
report=struct('source_revision',getenv('GITHUB_SHA'),'passed',0,'failed',0,'total',numel(tests), ...
    'cases',struct('name',{},'passed',{},'message',{}));
for k=1:numel(tests)
    ok=true; message=''; try, tests{k}(); catch err, ok=false; message=err.message; end
    report.cases(k)=struct('name',func2str(tests{k}),'passed',ok,'message',message);
    report.passed=report.passed+ok; report.failed=report.failed+~ok;
    fprintf('%s %s %s\n',string(ok),func2str(tests{k}),message);
end
konaet_write_json(fullfile(output,'test-report.json'),report);
assert(report.failed==0,'Konaet: %d testes falharam.',report.failed);

    function qualification_rejects_abstention()
        profile=jsondecode(fileread(fullfile(root,'integrated','qualification-profile.json')));
        assessment=konaet_model_qualification(result,profile);
        assert(~assessment.deployment_qualified && strcmp(assessment.status,'RESEARCH_ONLY'));
        assert(~assessment.new_independent_device_holdout_tested && ~assessment.physical_bench_validated);
        empty=assessment.cases([assessment.cases.coverage]==0);
        assert(~isempty(empty) && all(~[empty.predictive_thresholds_met]));
    end
    function evidence_rejects_metric_drift()
        folder=fullfile(output,'fixtures','metric-drift'); if ~isfolder(folder),mkdir(folder);end
        copyfile(fullfile(output,'model'),fullfile(folder,'model'));
        changed=result; changed.records(1).metrics.balanced_accuracy=0.999;
        konaet_write_json(fullfile(folder,'benchmark.json'),changed);
        rejected=false;
        try,konaet_evidence_summary(folder,fullfile(root,'integrated','qualification-profile.json'));
        catch exception,rejected=strcmp(exception.identifier,'Konaet:Evidence');end
        assert(rejected && ~isfile(fullfile(folder,'model-qualification.json')));
    end
    function bench_capture_contract()
        folder=fixture('synthetic-bench'); samplesFile=fullfile(folder,'samples.csv'); decisionsFile=fullfile(folder,'decisions.csv');
        metadataFile=fullfile(folder,'metadata.json');
        block=table(ones(32,1),(1:32).',13200*ones(32,1),zeros(32,1),(0:31).'/10, ...
            'VariableNames',{'window_id','sample_index','adc_code','quantized_int8','sample_time_s'});
        [~,label,status]=tiny_int8(data.q,50*ones(32,1));
        decisions=table(1,double(status.accumulators_int32(1)),double(status.accumulators_int32(2)),double(label),3.100206,0, ...
            'VariableNames',{'window_id','logit0_int32','logit1_int32','class_code','decision_time_s','energy_mJ'});
        meta=struct('schema_version',1,'physical_capture',true,'board_serial','SYNTHETIC_TEST_ONLY','pcb_revision','fixture', ...
            'instrument_id','fixture','calibration_reference','fixture','operator','fixture','capture_utc','2026-11-11T00:00:00Z', ...
            'model_bundle_sha256',konaet_sha256(fullfile(output,'model','model-bundle.json')));
        writetable(block,samplesFile); writetable(decisions,decisionsFile); konaet_write_json(metadataFile,meta);
        verified=konaet_validate_bench(samplesFile,decisionsFile,metadataFile,fullfile(output,'model'),folder);
        assert(verified.windows_compared==1 && ~verified.hardware_qualified && ~verified.equipment_authenticity_verified);
        decisions.logit0_int32=decisions.logit0_int32+1; writetable(decisions,decisionsFile);
        rejects(@()konaet_validate_bench(samplesFile,decisionsFile,metadataFile,fullfile(output,'model'),folder));
        block.sample_index(2)=1; writetable(block,samplesFile);
        rejects(@()konaet_validate_bench(samplesFile,decisionsFile,metadataFile,fullfile(output,'model'),folder));
    end
    function gradient_check()
        m=data.m; m.W1(:)=0.03; m.b1(:)=0.2; m.W2(:)=0.04; m.W2(2,:)=-0.02; m.b2(:)=0;
        x=[linspace(35,70,32)' linspace(60,25,32)']; y=[0 1];
        [~,g]=konaet_loss(m,x,y,1e-4); fields={'W1','b1','W2','b2'};
        for j=1:4
            name=fields{j}; plus=m; minus=m; h=single(0.001);
            indices=unique([1 ceil(numel(m.(name))/2) numel(m.(name))]);
            for index=indices
                plus=m; minus=m;
                plus.(name)(index)=plus.(name)(index)+h; minus.(name)(index)=minus.(name)(index)-h;
                numeric=(konaet_loss(plus,x,y,1e-4)-konaet_loss(minus,x,y,1e-4))/(2*double(h));
                assert(abs(numeric-double(g.(name)(index)))<3e-4,'Gradiente incorreto: %s/%d',name,index);
            end
        end
    end
    function reproducible_data()
        state=rng; [x,y]=konaet_windows(64,11); [xx,yy]=konaet_windows(64,11);
        [other,~]=konaet_windows(64,12);
        assert(isequal(x,xx) && isequal(y,yy) && ~isequal(x,other) && isequal(state,rng));
    end
    function reproducible_training()
        [x,y]=konaet_windows(64,42); c=struct('epochs',3,'learning_rate',0.003,'regularization',1e-4);
        [a,la]=konaet_train(x,y,c,123); [b,lb]=konaet_train(x,y,c,123);
        assert(isequal(a.W1,b.W1) && isequal(a.W2,b.W2) && isequal(la,lb));
    end
    function locked_test()
        assert(~result.test_used_for_selection && ~result.agent_memory.test_used_for_selection);
        assert(result.train_seed~=result.locked_test_seed && result.development_seed~=result.locked_test_seed);
        assert(sum(result.agent_memory.counts)-sum(result.agent_memory.before_counts)==6);
    end
    function weights_are_new()
        original=tiny_load_model(root);
        assert(norm(double(data.m.W1-original.W1),'fro')>1);
        assert(contains(data.m.source.initialization,'no imported weights'));
    end
    function training_loss()
        assert(all([result.experiments.loss_final]<[result.experiments.loss_initial]));
    end
    function quantized_fidelity()
        assert(result.quantized_agreement>=0.95);
    end
    function model_roundtrip()
        [m,q]=konaet_load_model(fullfile(output,'model'));
        assert(isequal(m.W1,data.m.W1) && isequal(m.W2,data.m.W2));
        [a,pa]=tiny_int8(q,data.hard_x); [b,pb]=tiny_int8(data.q,data.hard_x);
        assert(isequal(a,b) && isequal(pa,pb));
    end
    function source_interop()
        input=fullfile(output,'own-fortran-input.csv'); target=fullfile(output,'own-fortran-output.csv');
        x=data.hard_x(:,1:64); writematrix(x.',input);
        command=sprintf('"%s" "%s" "%s" "%s"',fullfile(root,'build','tiny_anomalynet'),fullfile(output,'model'),input,target);
        [status,message]=system(command); assert(status==0,'%s',message);
        independent=readmatrix(target); own=tiny_fp32(data.m,x);
        assert(max(abs(independent-double(own.')),[],'all')<2e-4);
    end
    function real_data_audit()
        assert(numel(result.real_data)==6);
        assert(all(~[result.real_data.model_training_used_this_series]));
        assert(all([result.real_data.normalization_prefix_samples]>32));
        assert(all([result.real_data.native_sample_interval_s]>10));
        assert(any([result.real_data.source_nonmonotonic_steps]>0));
        assert(all(~[result.real_data.official_NAB_score]));
        assert(sum(strcmp({result.real_data.evaluation_role},'new_external_fixed_protocol'))==4);
        assert(sum(strcmp({result.real_data.evaluation_role},'legacy_retrospective'))==2);
    end
    function invalid_sensor()
        x=ones(32,3)*50; x(1,1)=NaN; x(2,2)=Inf; x(3,3)=120;
        [~,pred,status]=tiny_int8(data.q,x);
        assert(all(pred==-1) && all(~status.representable));
    end
    function rc_step()
        p=konaet_rc_parameters(); t=[0;0.001;0.05;0.5];
        z=konaet_rc(t,ones(size(t))*3.3,p,0);
        % O estado capacitivo deve ter a mesma taxa em passos irregulares.
        long=konaet_rc([0;0.5],[3.3;3.3],p,0);
        assert(abs(z.capacitor_V(end)-long.capacitor_V(end))<1e-12);
        assert(z.dc_gain_node<1 && z.dc_gain_node>0.99);
    end
    function rc_energy()
        p=konaet_rc_parameters(); t=(0:0.001:1)';
        z=konaet_rc(t,1.5+0.5*sin(17*t),p,0.3);
        assert(abs(z.energy.balance_residual_J)<1e-12);
    end
    function rc_passivity()
        p=konaet_rc_parameters(); t=(0:0.01:1)'; z=konaet_rc(t,zeros(size(t)),p,3.3);
        assert(all(diff(z.capacitor_V)<0));
        assert(z.energy.series_heat_J>=0 && z.energy.esr_heat_J>=0 && z.energy.leak_heat_J>=0);
        assert(abs(z.energy.balance_residual_J)<1e-12);
    end
    function metrics_abstention()
        r=konaet_metrics([0 1 0 1],[-1 -1 0 1]);
        assert(r.accuracy==0.5 && r.coverage==0.5 && r.fn==1 && r.normal_abstentions==1);
    end
    function memory_resume()
        folder=fullfile(output,'fixtures','resume'); if ~isfolder(folder), mkdir(folder); end
        [x,y]=konaet_windows(64,86); [dev_x,dev_y]=konaet_windows(768,39002); previous=result.agent_memory;
        [~,state,experiments]=konaet_agent_search(x,y,dev_x,dev_y,folder,previous,data.m);
        assert(state.resumed && state.cycle==previous.cycle+1);
        assert(sum(state.counts)==sum(previous.counts)+6 && numel(experiments)==6);
    end
    function csv_interface()
        folder=fullfile(output,'fixtures','csv');if ~isfolder(folder),mkdir(folder);end
        x=ones(3,32)*50;x(2,7)=NaN;x(3,9)=120;
        input=fullfile(folder,'input.csv');target=fullfile(folder,'result.json');writematrix(x,input);
        r=konaet_classificar(input,target,fullfile(output,'model'));
        assert(r.windows==3 && all(r.classes(2:3)==-1));
        assert(isfile(target) && strcmp(r.model,'KONAET Sense 842 INT8'));
    end
    function bundle_tampering()
        folder=fixture('bundle'); copyfile(fullfile(output,'model','*'),folder);
        file=fullfile(folder,'fc1_weight.f32'); fid=fopen(file,'r+'); assert(fid>0);
        byte=fread(fid,1,'uint8'); fseek(fid,0,'bof'); fwrite(fid,bitxor(uint8(byte),uint8(1)),'uint8'); fclose(fid);
        rejects(@()konaet_load_model(folder));
    end
    function metadata_tampering()
        folder=fixture('metadata'); copyfile(fullfile(output,'model','*'),folder);
        file=fullfile(folder,'quantization.json'); meta=jsondecode(fileread(file));
        meta.input_scale=meta.input_scale*2; konaet_write_json(file,meta);
        rejects(@()tiny_load_int8(folder));
    end
    function memory_rejects_incompatible()
        state=result.agent_memory; state.counts(1)=state.counts(1)+1;
        rejects(@()konaet_validate_memory(state,data.m));
        state=result.agent_memory; state.reward_sum(1)=Inf;
        rejects(@()konaet_validate_memory(state,data.m));
        state=result.agent_memory; state.best_seed=state.best_seed+1;
        rejects(@()konaet_validate_memory(state,data.m));
    end
    function contract_covers_dependencies()
        [~,names]=konaet_research_contract(root);
        assert(any(strcmp(names,'matlab/integrated/konaet_metrics.m')));
        assert(any(strcmp(names,'matlab/tiny/tiny_fp32.m')));
        assert(any(strcmp(names,'matlab/tiny/tiny_int8.m')));
        assert(any(strcmp(names,'integrated/evaluation-protocol.json')));
    end
    function context_is_label_free()
        cal=data.cal_x(:,1:100); x=data.hard_x(:,1:50);
        a=konaet_context_detector(cal,x); b=konaet_context_detector(cal,x);
        assert(isequal(a,b) && numel(a.prediction)==50 && all(ismember(a.prediction,[0 1])));
    end
    function uncertainty_reproducible()
        truth=repmat([0 0 1 1],1,40); prediction=repmat([0 1 1 1],1,40);
        a=konaet_uncertainty(truth,prediction,8,256,66113); b=konaet_uncertainty(truth,prediction,8,256,66113);
        assert(isequal(a,b));
        assert(a.balanced_accuracy_95(1)<=0.75 && a.balanced_accuracy_95(2)>=0.75);
    end
    function local_memory_compare_and_swap()
        addpath(fullfile(root,'matlab')); folder=fixture('memory'); file=fullfile(folder,'memory.csv');
        writematrix([1 2 3],file); expected=fileread(file);
        konaet_commit_memory(file,[2 3 4],expected); assert(isequal(readmatrix(file),[2 3 4]));
        rejects(@()konaet_commit_memory(file,[9 9 9],expected));
        assert(isequal(readmatrix(file),[2 3 4]) && ~isfile([file '.lock']));
    end
    function bounded_stream_history()
        s=konaet_stream_init(123);
        controls=struct('noise_V',0,'step_enabled',false,'step_V',0,'dropout',false);
        for j=1:305,[s,view]=konaet_stream_step(s,data.m,data.q,controls);end
        assert(s.samples==305 && numel(s.time)==300 && numel(s.window_C)==32);
        assert(isfinite(view.node_V) && view.class>=0 && all(diff(s.time)>0));
    end
    function no_representable_calibration()
        x=ones(32,8)*50; cal=ones(32,8)*120;
        [records,paired]=konaet_evaluate(struct('name',{},'kind',{},'value',{}),x,[0 1 0 1 0 1 0 1],cal,'empty_calibration');
        assert(numel(records)==4 && all(paired.KONAET_CONTEXT==-1));
        assert(all(arrayfun(@(r)r.metrics.coverage==0,records)));
    end
    function folder=fixture(name)
        folder=fullfile(output,'fixtures',name); if ~isfolder(folder),mkdir(folder);end
    end
    function rejects(operation)
        rejected=false; try,operation();catch,rejected=true;end
        assert(rejected,'Entrada invalida foi aceita.');
    end
end
