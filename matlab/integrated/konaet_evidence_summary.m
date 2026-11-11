function qualification=konaet_evidence_summary(output,profileFile)
%KONAET_EVIDENCE_SUMMARY Generate public tables from the exact measured package.
file=fullfile(output,'benchmark.json'); benchmark=jsondecode(fileread(file));
profile=jsondecode(fileread(profileFile));
assert(~isempty(regexp(benchmark.source_revision,'^[0-9a-f]{40}$','once')));
bundleFile=fullfile(output,'model','model-bundle.json'); bundle=jsondecode(fileread(bundleFile));
for k=1:numel(bundle.files)
    assert(~isempty(regexp(bundle.files(k).name,'^[A-Za-z0-9._-]+$','once')));
    assert(strcmp(konaet_sha256(fullfile(output,'model',bundle.files(k).name)),bundle.files(k).sha256),'Model bundle hash mismatch.');
end
qualification=konaet_model_qualification(benchmark,profile);
qualification.benchmark_sha256=konaet_sha256(file); qualification.model_bundle_sha256=konaet_sha256(bundleFile);
qualification.profile_sha256=konaet_sha256(profileFile);
text=sprintf('# KONAET / measured benchmark\n\nSource: `%s`\n\nBenchmark SHA-256: `%s`\n\nModel bundle SHA-256: `%s`\n\n', ...
    benchmark.source_revision,qualification.benchmark_sha256,qualification.model_bundle_sha256);
text=[text sprintf('Generated from counts in this package. BA includes abstentions as unresolved cases. Bootstrap intervals are conditional on each series.\n\n')];
text=[text sprintf('| Suite | Method | BA (%%) | Recall (%%) | FPR (%%) | Coverage (%%) |\n| --- | --- | ---: | ---: | ---: | ---: |\n')];
for k=1:numel(benchmark.records)
    row=benchmark.records(k); m=row.metrics;
    positives=m.tp+m.fn; negatives=m.tn+m.fp+m.normal_abstentions;
    assert(m.samples==positives+negatives && m.abstentions>=m.normal_abstentions);
    recall=m.tp/max(positives,1); fpr=m.fp/max(negatives,1);
    ba=(recall+m.tn/max(negatives,1))/2; coverage=1-m.abstentions/m.samples;
    assert(max(abs([ba-m.balanced_accuracy recall-m.recall fpr-m.false_positive_rate coverage-m.coverage]))<1e-12, ...
        'Konaet:Evidence','Stored metric differs from confusion counts.');
    assert(~isempty(regexp(row.suite,'^[A-Za-z0-9._-]+$','once')) && ~isempty(regexp(row.model,'^[A-Za-z0-9._-]+$','once')));
    text=[text sprintf('| %s | %s | %.2f | %.2f | %.2f | %.2f |\n',row.suite,row.model,100*ba,100*recall,100*fpr,100*coverage)]; %#ok<AGROW>
end
text=[text sprintf('\nDeployment: **RESEARCH_ONLY**. No new independent-device holdout or physical bench validation is claimed. See model-qualification.json for proposed targets and each external case.\n')];
konaet_write_json(fullfile(output,'model-qualification.json'),qualification);
fid=fopen(fullfile(output,'benchmark-summary.md'),'wb'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
bytes=unicode2native(text,'UTF-8'); assert(fwrite(fid,bytes,'uint8')==numel(bytes));
end
