function tiny_export_int8(q,folder,provenance)
%TINY_EXPORT_INT8 Payload sem runtime, com escalas, hash e procedencia.
path=fullfile(folder,'anomalynet-int8.bin');
fid=fopen(path,'wb','ieee-le'); assert(fid>=0); guard=onCleanup(@() fclose(fid));
fwrite(fid,q.W1.','int8'); fwrite(fid,q.b1,'int32'); fwrite(fid,q.W2.','int8'); fwrite(fid,q.b2,'int32'); clear guard;
assert(dir(path).bytes==920);
fid=fopen(path,'rb'); assert(fid>=0); guard=onCleanup(@() fclose(fid));
bytes=fread(fid,inf,'*uint8'); clear guard;
digest=java.security.MessageDigest.getInstance('SHA-256'); digest.update(bytes);
meta=rmfield(q,{'W1','W2','b1','b2'});
meta.payload_sha256=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
meta.format='W1 row-major int8[24,32], b1 int32[24], W2 row-major int8[2,24], b2 int32[2]; little endian';
if nargin<3
    provenance=struct('model_credit','AnomalyNet, Copyright 2026 Eoin Jordan, Apache-2.0', ...
        'source_url','https://huggingface.co/eoinedge/AnomalyNet', ...
        'source_revision','bb9db962cebb0f506496dc51e824cfc15b8a7ab1');
end
meta.model_credit=provenance.model_credit;
meta.source_url=provenance.source_url; meta.source_revision=provenance.source_revision;
fid=fopen(fullfile(folder,'quantization.json'),'w','n','UTF-8'); assert(fid>=0);
guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s\n',jsonencode(meta,PrettyPrint=true));
end
