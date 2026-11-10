function konaet_export_model(m,q,output)
%KONAET_EXPORT_MODEL Pesos novos, manifesto de treinamento e formatos locais.
if ~isfolder(output), mkdir(output); end
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
save(fullfile(output,'konaet-model.mat'),'m','q');
end
