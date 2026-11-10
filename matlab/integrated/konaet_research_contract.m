function hash = konaet_research_contract(root)
%KONAET_RESEARCH_CONTRACT Reinicia aprendizagem se codigo ou dados mudarem.
names={'konaet_train.m','konaet_windows.m','konaet_loss.m','konaet_agent_search.m'};
value='KONAET research v2; train=39001/4096; dev=39002/768; MLP=32-24-2; objective=BA-0.15FPR';
for k=1:numel(names)
    content=fileread(fullfile(root,'matlab','integrated',names{k}));
    content=strrep(content,sprintf('\r\n'),sprintf('\n')); value=[value content]; %#ok<AGROW>
end
digest=java.security.MessageDigest.getInstance('SHA-256'); digest.update(unicode2native(value,'UTF-8'));
hash=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
end
