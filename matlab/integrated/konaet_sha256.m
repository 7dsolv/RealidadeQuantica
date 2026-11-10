function sha = konaet_sha256(path)
fid=fopen(path,'rb'); assert(fid>=0); guard=onCleanup(@() fclose(fid));
bytes=fread(fid,inf,'*uint8'); clear guard;
digest=java.security.MessageDigest.getInstance('SHA-256'); digest.update(bytes);
sha=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
end
