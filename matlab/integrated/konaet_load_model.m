function [m,q] = konaet_load_model(folder)
%KONAET_LOAD_MODEL Le apenas tensores numericos proprios com SHA-256.
card=jsondecode(fileread(fullfile(folder,'model-card.json')));
names={'fc1_weight.f32','fc1_bias.f32','fc2_weight.f32','fc2_bias.f32'}; values=cell(1,4);
for k=1:4
    item=card.files(strcmp({card.files.name},names{k})); assert(isscalar(item));
    path=fullfile(folder,names{k}); assert(strcmp(konaet_sha256(path),item.sha256));
    fid=fopen(path,'rb','ieee-le'); assert(fid>=0); guard=onCleanup(@() fclose(fid));
    values{k}=fread(fid,inf,'*single'); clear guard;
    assert(numel(values{k})*4==item.bytes);
end
m=struct('W1',reshape(values{1},32,24).','b1',values{2}, ...
    'W2',reshape(values{3},24,2).','b2',values{4},'mean_C',single(50),'scale_C',single(20),'source',card);
q=tiny_load_int8(folder);
end
