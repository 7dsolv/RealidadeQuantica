function value = konaet_uuid(text)
%KONAET_UUID IDs deterministas, evitando alteracoes cosmeticas a cada geracao.
d=java.security.MessageDigest.getInstance('SHA-256'); d.update(unicode2native(text,'UTF-8'));
h=lower(reshape(dec2hex(typecast(d.digest(),'uint8'),2).',1,[]));
h(13)='5'; h(17)='a'; value=[h(1:8) '-' h(9:12) '-' h(13:16) '-' h(17:20) '-' h(21:32)];
end
