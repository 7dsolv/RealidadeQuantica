function m = tiny_load_model(root)
%TINY_LOAD_MODEL Carrega apenas dados locais, com hash; nunca executa pickle.
if nargin<1, root=fileparts(fileparts(fileparts(mfilename('fullpath')))); end
folder=fullfile(root,'models','anomalynet');
source=jsondecode(fileread(fullfile(folder,'source.json')));
assert(strcmp(source.revision,'bb9db962cebb0f506496dc51e824cfc15b8a7ab1'));
names={'fc1_weight.f32','fc1_bias.f32','fc2_weight.f32','fc2_bias.f32'};
values=cell(1,4);
for k=1:4
    path=fullfile(folder,names{k});
    record=source.files(strcmp({source.files.name},names{k}));
    assert(isscalar(record));
    fid=fopen(path,'rb'); assert(fid>=0); guard=onCleanup(@() fclose(fid));
    bytes=fread(fid,inf,'*uint8'); clear guard;
    digest=java.security.MessageDigest.getInstance('SHA-256'); digest.update(bytes);
    sha=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
    assert(numel(bytes)==record.bytes && strcmp(sha,record.sha256),'Tensor alterado: %s',names{k});
    fid=fopen(path,'rb','ieee-le'); assert(fid>=0); guard=onCleanup(@() fclose(fid));
    values{k}=fread(fid,inf,'*single'); clear guard;
end
m.W1=reshape(values{1},32,24).'; m.b1=values{2};
m.W2=reshape(values{3},24,2).'; m.b2=values{4};
m.mean_C=single(50); m.scale_C=single(20);
m.source=source;
assert(numel(m.W1)+numel(m.b1)+numel(m.W2)+numel(m.b2)==842);
end
