function konaet_export_model(m,q,output)
%KONAET_EXPORT_MODEL Pesos novos, manifesto de treinamento e formatos locais.
if ~isfolder(output), mkdir(output); end
tiny_validate_int8(q);
assert(isequal(q.W1,int8(round(double(m.W1)/q.w1_scale))) && isequal(q.W2,int8(round(double(m.W2)/q.w2_scale))));
assert(isequal(q.b1,int32(round(double(m.b1)/(q.input_scale*q.w1_scale)))) && ...
    isequal(q.b2,int32(round(double(m.b2)/(q.hidden_scale*q.w2_scale)))),'Konaet:InvalidBundle','FP32 e INT8 nao correspondem.');
names={'fc1_weight.f32','fc1_bias.f32','fc2_weight.f32','fc2_bias.f32'};
arrays={m.W1.',m.b1,m.W2.',m.b2}; files=struct('name',{},'bytes',{},'sha256',{});
for k=1:4
    path=fullfile(output,names{k}); fid=fopen(path,'wb','ieee-le'); assert(fid>=0);
    guard=onCleanup(@() fclose(fid)); fwrite(fid,arrays{k},'single'); clear guard;
    files(k)=struct('name',names{k},'bytes',dir(path).bytes,'sha256',konaet_sha256(path));
end
card=m.source; card.files=files; card.parameters=842;
card.license='MIT for the new KONAET Sense weights and integrated implementation';
card.scope='Binary anomaly research classifier; not a general intelligence model';
card.physical_deployment='NOT_MEASURED';
konaet_write_json(fullfile(output,'model-card.json'),card);
provenance=struct('model_credit','KONAET Sense 842, trained by 7dsolv from random initialization, MIT', ...
    'source_url','https://github.com/7dsolv/RealidadeQuantica/tree/main/integrated', ...
    'source_revision',getenv('GITHUB_SHA'),'payload_file','konaet-int8.bin');
tiny_export_int8(q,output,provenance);
konaet_model_bundle(output,true);
save(fullfile(output,'konaet-model.mat'),'m','q');
end
