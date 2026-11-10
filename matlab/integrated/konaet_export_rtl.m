function report = konaet_export_rtl(q,hard_x,output)
%KONAET_EXPORT_RTL ROMs, vetores independentes e limites de acumuladores.
folder=fullfile(output,'rtl'); if ~isfolder(folder), mkdir(folder); end
[~,~,trace]=tiny_int8(q,hard_x);
valid=find(trace.representable); assert(numel(valid)>=256);
cases=trace.input_int8(:,valid(1:256));
edges=int8([zeros(32,1),127*ones(32,1),-127*ones(32,1), ...
    repmat([127;-127],16,1),ones(32,1),[127;zeros(31,1)]]);
s=RandStream('mt19937ar','Seed',51003);
cases=[cases edges int8(randi(s,255,32,128)-128)];
physical=double(cases)*q.input_scale*q.scale_C+q.mean_C;
[~,~,expected]=tiny_int8(q,physical);
assert(isequal(expected.input_int8,cases));
weights=[reshape(q.W1.',[],1);reshape(q.W2.',[],1)];
bias=[q.b1;q.b2];
write_hex(fullfile(folder,'weights.mem'),typecast(weights,'uint8'),2);
write_hex(fullfile(folder,'bias.mem'),typecast(bias,'uint32'),8);
write_hex(fullfile(folder,'input.mem'),typecast(cases(:),'uint8'),2);
write_hex(fullfile(folder,'expected.mem'),typecast(expected.accumulators_int32(:),'uint32'),8);
assert(q.multiplier>0 && q.multiplier<2^31);
bound1=sum(abs(double(q.W1)),2)*128+abs(double(q.b1));
bound2=sum(abs(double(q.W2)),2)*127+abs(double(q.b2));
assert(max([bound1;bound2])<2^31);
assert(max(bound1)*double(q.multiplier)+2^29<2^63);
report=struct('source_revision',getenv('GITHUB_SHA'),'cases',size(cases,2), ...
    'multiply_accumulate_per_window',816,'first_layer_abs_bounds',bound1, ...
    'second_layer_abs_bounds',bound2,'max_requantized_product',max(bound1)*double(q.multiplier), ...
    'hardware_measurement','NOT_MEASURED','comparison','both signed INT32 logits and decision, not only label');
konaet_write_json(fullfile(folder,'rtl-vectors.json'),report);
fid=fopen(fullfile(folder,'konaet_model_params.vh'),'w'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'`ifndef KONAET_MODEL_PARAMS\n`define KONAET_MODEL_PARAMS\n');
fprintf(fid,'`define KONAET_REQUANT_MULTIPLIER 32''d%.0f\n',double(q.multiplier));
[~,zero_class]=tiny_int8(q,ones(32,1)*50);
fprintf(fid,'`define KONAET_ZERO_ANOMALY %d\n',zero_class);
fprintf(fid,'`define KONAET_TEST_CASES %d\n`endif\n',size(cases,2));
end
function write_hex(path,values,width)
fid=fopen(path,'w'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
format=sprintf('%%0%dX\n',width); fprintf(fid,format,values);
end
