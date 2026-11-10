function [m,state,experiments] = konaet_agent_search(training_x,training_y,dev_x,dev_y,output,previous,previous_model)
%KONAET_AGENT_SEARCH Agente restrito de pesquisa: UCB e politica atualizada.
% Objetivo e conjunto de validacao definidos antes de consultar o teste final.
arms=[struct('learning_rate',0.003,'regularization',1e-4,'epochs',40), ...
    struct('learning_rate',0.008,'regularization',1e-4,'epochs',40), ...
    struct('learning_rate',0.003,'regularization',1e-3,'epochs',40)];
state=struct('schema_version',1,'objective','validation balanced accuracy minus 0.15 FPR', ...
    'policy','UCB1 over three training configurations','counts',zeros(1,3), ...
    'reward_sum',zeros(1,3),'best_reward',-inf,'best_arm',0,'test_used_for_selection',false);
experiments=struct('round',{},'arm',{},'seed',{},'reward',{},'validation',{},'loss_initial',{},'loss_final',{});
state.cycle=1; state.resumed=false; best=[];
if nargin>=7 && ~isempty(previous)
    konaet_validate_memory(previous,previous_model);
    state=previous; state.counts=state.counts(:).'; state.reward_sum=state.reward_sum(:).';
    [~,prediction]=tiny_fp32(previous_model,dev_x);
    rechecked=konaet_metrics(dev_y,prediction);
    assert(abs(rechecked.utility-state.best_reward)<1e-8,'Konaet:InvalidResearchState', ...
        'A recompensa do candidato mudou; reinicie o contrato de pesquisa.');
    state.revalidated_best_reward=rechecked.utility;
    state.cycle=state.cycle+1; state.resumed=true; best=previous_model;
end
state.before_counts=state.counts; state.before_reward_sum=state.reward_sum;
for round=1:6
    unknown=find(state.counts==0,1);
    if ~isempty(unknown), arm=unknown;
    else
        upper=state.reward_sum./state.counts+sqrt(2*log(sum(state.counts)+1)./state.counts);
        [~,arm]=max(upper);
    end
    seed=7700+101*state.cycle+round;
    [candidate,loss]=konaet_train(training_x,training_y,arms(arm),seed);
    [~,pred]=tiny_fp32(candidate,dev_x); metrics=konaet_metrics(dev_y,pred);
    reward=metrics.utility;
    state.counts(arm)=state.counts(arm)+1; state.reward_sum(arm)=state.reward_sum(arm)+reward;
    experiments(round)=struct('round',round,'arm',arm,'seed',seed,'reward',reward, ...
        'validation',metrics,'loss_initial',loss(1),'loss_final',loss(end));
    if reward>state.best_reward
        best=candidate; state.best_reward=reward; state.best_arm=arm; state.best_seed=seed;
    end
    fprintf('Agente: rodada %d, configuracao %d, utilidade validacao %.4f\n',round,arm,reward);
end
m=best; state.experiments=numel(experiments); state.training_complete=true;
state.policy_scores=state.reward_sum./max(state.counts,1); state.source_revision=getenv('GITHUB_SHA');
konaet_write_json(fullfile(output,'agent-memory.json'),state);
konaet_write_json(fullfile(output,'agent-experiments.json'),experiments);
end
