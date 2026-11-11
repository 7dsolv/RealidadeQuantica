function report=konaet_model_qualification(benchmark,profile)
%KONAET_MODEL_QUALIFICATION Keep successful experiments separate from deployment.
assert(profile.schema_version==1 && profile.require_new_independent_device_holdout ...
    && profile.require_physical_bench_validation,'Konaet:Qualification','Unsupported acceptance profile.');
targets={'minimum_balanced_accuracy','minimum_recall','maximum_false_positive_rate','minimum_coverage'};
for k=1:numel(targets)
    value=profile.(targets{k}); assert(isscalar(value) && isfinite(value) && value>=0 && value<=1);
end
cases=struct('suite',{},'balanced_accuracy',{},'recall',{},'false_positive_rate',{},'coverage',{}, ...
    'reference_balanced_accuracy',{},'predictive_thresholds_met',{});
for k=1:numel(benchmark.real_data)
    name=benchmark.real_data(k).name;
    own=benchmark.records(strcmp({benchmark.records.suite},name) & strcmp({benchmark.records.model},'KONAET_INT8'));
    reference=benchmark.records(strcmp({benchmark.records.suite},name) & strcmp({benchmark.records.model},'AnomalyNet_INT8'));
    assert(isscalar(own) && isscalar(reference),'Konaet:Qualification','Missing or duplicate external comparison.');
    m=own.metrics;
    values=[m.balanced_accuracy m.recall m.false_positive_rate m.coverage reference.metrics.balanced_accuracy];
    assert(all(isfinite(values)) && all(values>=0 & values<=1));
    accepted=m.balanced_accuracy>=profile.minimum_balanced_accuracy && m.recall>=profile.minimum_recall ...
        && m.false_positive_rate<=profile.maximum_false_positive_rate && m.coverage>=profile.minimum_coverage;
    if profile.require_no_regression_against_anomalynet_int8
        accepted=accepted && m.balanced_accuracy>=reference.metrics.balanced_accuracy;
    end
    cases(end+1)=struct('suite',name,'balanced_accuracy',m.balanced_accuracy,'recall',m.recall, ...
        'false_positive_rate',m.false_positive_rate,'coverage',m.coverage, ...
        'reference_balanced_accuracy',reference.metrics.balanced_accuracy,'predictive_thresholds_met',accepted); %#ok<AGROW>
end
assert(~isempty(cases),'Konaet:Qualification','External cases required.');
report=struct('schema_version',1,'source_revision',benchmark.source_revision,'profile',profile.profile, ...
    'status','RESEARCH_ONLY','deployment_qualified',false,'predictive_thresholds_met',all([cases.predictive_thresholds_met]), ...
    'new_independent_device_holdout_tested',false,'physical_bench_validated',false,'cases',cases, ...
    'reason','Observed public series and simulated RTL do not qualify a physical product. New device holdout and bench evidence require separate review.');
end
