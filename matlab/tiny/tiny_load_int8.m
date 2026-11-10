function q = tiny_load_int8(folder)
%TINY_LOAD_INT8 Recarrega o payload publicado; nenhuma conexao de rede.
q=jsondecode(fileread(fullfile(folder,'quantization.json')));
assert(q.parameters==842 && q.payload_bytes==920 && q.shift==30);
assert(all(isfinite([q.input_scale q.hidden_scale q.w1_scale q.w2_scale])));
assert(all([q.input_scale q.hidden_scale q.w1_scale q.w2_scale]>0));
filename='anomalynet-int8.bin';if isfield(q,'payload_file'),filename=q.payload_file;end
assert(any(strcmp(filename,{'anomalynet-int8.bin','konaet-int8.bin'})));
path=fullfile(folder,filename);
fid=fopen(path,'rb'); assert(fid>=0); guard=onCleanup(@() fclose(fid));
bytes=fread(fid,inf,'*uint8'); clear guard;
digest=java.security.MessageDigest.getInstance('SHA-256'); digest.update(bytes);
sha=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
assert(numel(bytes)==920 && strcmp(sha,q.payload_sha256),'Payload INT8 alterado.');
fid=fopen(path,'rb','ieee-le'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
q.W1=reshape(fread(fid,768,'*int8'),32,24).';
q.b1=fread(fid,24,'*int32');
q.W2=reshape(fread(fid,48,'*int8'),24,2).';
q.b2=fread(fid,2,'*int32'); q.multiplier=int64(q.multiplier);
end
