function konaet_validate_memory(s,m)
%KONAET_VALIDATE_MEMORY Reject corrupt, fractional or incompatible state.
required={'schema_version','cycle','counts','reward_sum','best_reward','best_arm','best_seed','test_used_for_selection'};
assert(isstruct(s) && isscalar(s) && all(isfield(s,required)), 'Konaet:InvalidResearchState','Memoria incompleta.');
assert(s.schema_version==1 && isequal(s.test_used_for_selection,false),'Konaet:InvalidResearchState','Schema ou protocolo invalido.');
validateattributes(s.cycle,{'numeric'},{'scalar','real','finite','integer','>=',1});
validateattributes(s.best_seed,{'numeric'},{'scalar','real','finite','integer','positive'});
validateattributes(s.best_arm,{'numeric'},{'scalar','integer','>=',1,'<=',3});
validateattributes(s.counts,{'numeric'},{'vector','numel',3,'real','finite','integer','nonnegative'});
validateattributes(s.reward_sum,{'numeric'},{'vector','numel',3,'real','finite'});
validateattributes(s.best_reward,{'numeric'},{'scalar','real','finite','>=',-0.15,'<=',1});
counts=s.counts(:);rewards=s.reward_sum(:);
assert(sum(counts)==6*s.cycle && all(rewards>=-0.15*counts-1e-10) && all(rewards<=counts+1e-10), ...
    'Konaet:InvalidResearchState','Contagens ou recompensas inconsistentes.');
assert(isstruct(m) && isfield(m,'source') && m.source.training_seed==s.best_seed, ...
    'Konaet:InvalidResearchState','Memoria e candidato nao correspondem.');
end
