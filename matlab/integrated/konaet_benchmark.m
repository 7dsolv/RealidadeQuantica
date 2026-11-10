function result = konaet_benchmark(root,output)
%KONAET_BENCHMARK Treino, busca autonoma, teste bloqueado e dados reais.
if ~isfolder(output), mkdir(output); end
[train_x,train_y]=konaet_windows(4096,39001);
[dev_x,dev_y]=konaet_windows(768,39002);
contract=konaet_research_contract(root); previous=[]; previous_model=[];
memory_path=fullfile(root,'state','konaet-research-memory.json');
if isfile(memory_path)
    existing=jsondecode(fileread(memory_path));
    if isfield(existing,'research_contract') && strcmp(existing.research_contract,contract)
        [previous_model,~]=konaet_load_model(fullfile(root,'assets','integrated','model'));
        assert(strcmp(previous_model.source.research_contract,contract));
        assert(previous_model.source.training_seed==existing.best_seed,'Memoria e pesos nao correspondem ao mesmo candidato.');
        previous=existing;
    end
end
[m,memory,experiments]=konaet_agent_search(train_x,train_y,dev_x,dev_y,output,previous,previous_model);
memory.research_contract=contract; m.source.research_contract=contract;
konaet_write_json(fullfile(output,'agent-memory.json'),memory);
[cal_x,cal_y]=konaet_windows(1024,39004); q=tiny_quantize(m,cal_x);
own_folder=fullfile(output,'model'); konaet_export_model(m,q,own_folder);
original=tiny_load_model(root); original_q=tiny_quantize(original,cal_x);
models=[struct('name','KONAET_FP32','kind','fp32','value',m), ...
    struct('name','KONAET_INT8','kind','int8','value',q), ...
    struct('name','AnomalyNet_FP32','kind','fp32','value',original), ...
    struct('name','AnomalyNet_INT8','kind','int8','value',original_q)];
[hard_x,hard_y,hard_meta]=konaet_windows(2048,39003);
[easy_x,easy_y]=tiny_windows(1024,39005);
[noisy_x,noisy_y]=konaet_windows(1024,39006,2.5);
[records,paired]=konaet_evaluate(models,hard_x,hard_y,cal_x(:,cal_y==0),'hard_synthetic_locked');
[more,~]=konaet_evaluate(models,easy_x,easy_y,cal_x(:,cal_y==0),'easy_synthetic'); records=[records more];
[more,~]=konaet_evaluate(models,noisy_x,noisy_y,cal_x(:,cal_y==0),'strong_noise_shift'); records=[records more];
nab=konaet_nab(root); metadata=[nab.meta];
for k=1:numel(nab)
    [more,decisions]=konaet_evaluate(models,nab(k).x,nab(k).y,nab(k).calibration,nab(k).meta.name);
    records=[records more]; %#ok<AGROW>
    names=fieldnames(decisions); table_data=table(nab(k).endpoint_indices.',nab(k).y.','VariableNames',{'endpoint_index','truth'});
    for j=1:numel(names), table_data.(names{j})=decisions.(names{j}).'; end
    writetable(table_data,fullfile(output,['nab-' num2str(k) '-decisions.csv']));
end
names=fieldnames(paired); table_data=table(hard_y.','VariableNames',{'truth'});
for j=1:numel(names), table_data.(names{j})=paired.(names{j}).'; end
writetable(table_data,fullfile(output,'hard-decisions.csv'));
result=struct('schema_version',1,'source_revision',getenv('GITHUB_SHA'), ...
    'train_seed',39001,'development_seed',39002,'locked_test_seed',39003, ...
    'training_windows',4096,'development_windows',768,'hard_test_windows',2048, ...
    'training_weights_origin','random initialization; no AnomalyNet weights transferred', ...
    'test_used_for_selection',false,'agent_memory',memory,'experiments',experiments, ...
    'records',records,'real_data',metadata,'hard_definition',hard_meta, ...
    'hardware_latency','NOT_MEASURED','physical_device','NOT_DEPLOYED');
result.quantized_agreement=mean(paired.KONAET_FP32==paired.KONAET_INT8);
result.external_protocol=jsondecode(fileread(fullfile(root,'integrated','evaluation-protocol.json')));
result.external_protocol_sha256=konaet_sha256(fullfile(root,'integrated','evaluation-protocol.json'));
result.context_comparator='Normal-only calibration, fixed level/shape envelope. Separate research method; not part of deployed neural weights or FPGA.';
result.all_methods_same_input_domain='10..90 equivalent C; abstentions are counted and never treated as normal';
konaet_write_json(fullfile(output,'benchmark.json'),result);
save(fullfile(output,'benchmark.mat'),'result','m','q','original','original_q','hard_x','hard_y','cal_x');
fprintf('KONAET treino proprio: concordancia FP32/INT8 %.2f%%; metricas reais publicadas sem filtro.\n',100*result.quantized_agreement);
end
