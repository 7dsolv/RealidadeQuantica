function report=konaet_validate_bench(samplesFile,decisionsFile,metadataFile,modelFolder,output)
%KONAET_VALIDATE_BENCH Compare supplied physical captures to the integer model.
% This verifies file consistency; equipment identity still needs human review.
for path={samplesFile,decisionsFile,metadataFile}
    info=dir(path{1}); assert(isscalar(info) && ~info.isdir && info.bytes<=16*1024*1024,'Konaet:Bench','Invalid capture file.');
end
meta=jsondecode(fileread(metadataFile));
assert(meta.schema_version==1 && islogical(meta.physical_capture) && isscalar(meta.physical_capture) ...
    && meta.physical_capture,'Konaet:Bench','Physical capture declaration required.');
for name={'board_serial','pcb_revision','instrument_id','calibration_reference','operator','capture_utc'}
    value=meta.(name{1}); assert(ischar(value) && ~isempty(strtrim(value)) && numel(value)<=256,'Konaet:Bench','Missing capture provenance.');
end
assert(strcmp(meta.model_bundle_sha256,konaet_sha256(fullfile(modelFolder,'model-bundle.json'))),'Konaet:Bench','Capture uses another model.');
[~,q]=konaet_load_model(modelFolder);
samples=readtable(samplesFile); decisions=readtable(decisionsFile);
assert(isequal(samples.Properties.VariableNames,{'window_id','sample_index','adc_code','quantized_int8','sample_time_s'}), ...
    'Konaet:Bench','Unexpected sample columns.');
assert(isequal(decisions.Properties.VariableNames,{'window_id','logit0_int32','logit1_int32','class_code','decision_time_s','energy_mJ'}), ...
    'Konaet:Bench','Unexpected decision columns.');
assert(all(isfinite(samples{:,:}),'all') && all(isfinite(decisions{:,:}),'all'),'Konaet:Bench','Nonfinite capture.');
assert(height(samples)>0 && height(samples)==32*height(decisions),'Konaet:Bench','Complete 32-sample windows required.');
assert(isequal(decisions.window_id,(1:height(decisions)).'),'Konaet:Bench','Sequential unique windows required.');
latency=zeros(height(decisions),1); acquisition=latency;
for k=1:height(decisions)
    block=samples((k-1)*32+(1:32),:); row=decisions(k,:);
    assert(all(block.window_id==k) && isequal(block.sample_index,(1:32).'),'Konaet:Bench','Reordered, missing or duplicated samples.');
    code=block.adc_code; assert(all(code==fix(code) & code>=-32768 & code<=32767),'Konaet:Bench','Signed ADC range required.');
    expected=round((code-13200)*127/16000);
    assert(all(abs(expected)<=127),'Konaet:Bench','This valid-window comparison does not certify invalid-sensor recovery.');
    assert(isequal(block.quantized_int8,expected),'Konaet:Bench','Captured quantizer differs from RTL formula.');
    celsius=expected*q.input_scale*q.scale_C+q.mean_C;
    [~,label,status]=tiny_int8(q,celsius);
    assert(isequal(double(status.input_int8),expected) && ...
        isequal(double(status.accumulators_int32).',[row.logit0_int32 row.logit1_int32]) && row.class_code==label, ...
        'Konaet:Bench','Physical logits or class differ from integer reference.');
    assert(all(diff(block.sample_time_s)>0) && row.decision_time_s>=block.sample_time_s(end) && row.energy_mJ>=0, ...
        'Konaet:Bench','Invalid measured timing or energy.');
    latency(k)=row.decision_time_s-block.sample_time_s(end);
    acquisition(k)=row.decision_time_s-block.sample_time_s(1);
end
report=struct('schema_version',1,'status','CAPTURE_COMPARED','hardware_qualified',false, ...
    'windows_compared',height(decisions),'samples_sha256',konaet_sha256(samplesFile), ...
    'decisions_sha256',konaet_sha256(decisionsFile),'metadata_sha256',konaet_sha256(metadataFile), ...
    'model_bundle_sha256',meta.model_bundle_sha256,'post_input_latency_s',latency, ...
    'first_sample_to_decision_s',acquisition,'captured_energy_mJ',decisions.energy_mJ, ...
    'equipment_authenticity_verified',false,'fault_recovery_qualified',false, ...
    'scope','Consistency of supplied valid-window captures. Physical provenance, calibration, faults and endurance need independent review.');
if ~isfolder(output),mkdir(output);end
konaet_write_json(fullfile(output,'bench-comparison.json'),report);
end
