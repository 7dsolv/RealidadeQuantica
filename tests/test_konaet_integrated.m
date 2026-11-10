function report = test_konaet_integrated(root,output)
%TEST_KONAET_INTEGRATED Verificacao numerica, treino, dados e retomada real.
data=load(fullfile(output,'benchmark.mat')); result=data.result;
tests={@gradient_check,@reproducible_data,@reproducible_training,@locked_test, ...
    @weights_are_new,@training_loss,@quantized_fidelity,@model_roundtrip, ...
    @source_interop,@real_data_audit,@invalid_sensor,@rc_step,@rc_energy, ...
    @rc_passivity,@metrics_abstention,@memory_resume};
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

    function gradient_check()
        m=data.m; m.W1(:)=0.03; m.b1(:)=0.2; m.W2(:)=0.04; m.W2(2,:)=-0.02; m.b2(:)=0;
        x=[linspace(35,70,32)' linspace(60,25,32)']; y=[0 1];
        [~,g]=konaet_loss(m,x,y,1e-4); fields={'W1','b1','W2','b2'};
        for j=1:4
            name=fields{j}; plus=m; minus=m; h=single(0.001);
            plus.(name)(1)=plus.(name)(1)+h; minus.(name)(1)=minus.(name)(1)-h;
            numeric=(konaet_loss(plus,x,y,1e-4)-konaet_loss(minus,x,y,1e-4))/(2*double(h));
            assert(abs(numeric-double(g.(name)(1)))<3e-4,'Gradiente incorreto: %s',name);
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
        assert(numel(result.real_data)==2);
        assert(all(~[result.real_data.model_training_used_this_series]));
        assert(all([result.real_data.normalization_prefix_samples]>32));
        assert(all([result.real_data.native_sample_interval_s]>10));
        assert(any([result.real_data.source_nonmonotonic_steps]>0));
        assert(all(~[result.real_data.official_NAB_score]));
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
        [x,y]=konaet_windows(64,86); previous=result.agent_memory;
        [~,state,experiments]=konaet_agent_search(x,y,x,y,folder,previous,data.m);
        assert(state.resumed && state.cycle==previous.cycle+1);
        assert(sum(state.counts)==sum(previous.counts)+6 && numel(experiments)==6);
    end
end
