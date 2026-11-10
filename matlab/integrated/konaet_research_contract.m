function [hash,names] = konaet_research_contract(root)
%KONAET_RESEARCH_CONTRACT Reinicia aprendizagem se codigo ou dados mudarem.
% Conservative closure: changes to inference, metrics, normalization,
% quantization, dataset provenance or selection cannot retain old rewards.
names={};
for folder={'matlab/integrated','matlab/tiny'}
    entries=dir(fullfile(root,folder{1},'*.m'));
    for k=1:numel(entries),names{end+1}=[folder{1} '/' entries(k).name];end %#ok<AGROW>
end
names=sort([names {'datasets/nab/source.json','datasets/nab/selected-labels.json','integrated/evaluation-protocol.json'}]);
value='KONAET research v3; train=39001/4096; dev=39002/768; MLP=32-24-2; objective=BA-0.15FPR';
for k=1:numel(names)
    content=fileread(fullfile(root,names{k}));
    content=strrep(content,sprintf('\r\n'),sprintf('\n'));
    value=[value char(0) names{k} char(0) content]; %#ok<AGROW>
end
digest=java.security.MessageDigest.getInstance('SHA-256'); digest.update(unicode2native(value,'UTF-8'));
hash=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2).',1,[]));
end
