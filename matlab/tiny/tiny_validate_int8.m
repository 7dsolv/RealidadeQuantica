function tiny_validate_int8(q)
%TINY_VALIDATE_INT8 Complete arithmetic contract for the symmetric RTL format.
fields={'input_scale','hidden_scale','w1_scale','w2_scale','multiplier','shift','mean_C','scale_C','parameters','payload_bytes'};
assert(isstruct(q) && isscalar(q) && all(isfield(q,fields)),'Konaet:InvalidQuantization','Metadados incompletos.');
for k=1:numel(fields)
    validateattributes(q.(fields{k}),{'numeric'},{'scalar','real','finite'});
end
assert(q.parameters==842 && q.payload_bytes==920 && q.shift==30,'Konaet:InvalidQuantization','Formato incorreto.');
assert(q.mean_C==50 && q.scale_C==20 && abs(q.input_scale-2/127)<1e-15, ...
    'Konaet:InvalidQuantization','Normalizacao fora do contrato ADC/RTL.');
assert(all([q.hidden_scale q.w1_scale q.w2_scale]>0) && q.multiplier>0 && q.multiplier<2^31 && fix(q.multiplier)==q.multiplier, ...
    'Konaet:InvalidQuantization','Escala ou multiplicador invalido.');
expected=round(q.input_scale*q.w1_scale/q.hidden_scale*2^30);
assert(double(q.multiplier)==expected,'Konaet:InvalidQuantization','Multiplicador nao corresponde as escalas.');
if isfield(q,'W1')
    assert(isa(q.W1,'int8') && isequal(size(q.W1),[24 32]) && all(q.W1(:)>=-127));
    assert(isa(q.W2,'int8') && isequal(size(q.W2),[2 24]) && all(q.W2(:)>=-127));
    assert(isa(q.b1,'int32') && isequal(size(q.b1),[24 1]) && isa(q.b2,'int32') && isequal(size(q.b2),[2 1]));
    bound1=sum(abs(double(q.W1)),2)*128+abs(double(q.b1));
    bound2=sum(abs(double(q.W2)),2)*127+abs(double(q.b2));
    assert(max([bound1;bound2])<2^31 && max(bound1)*double(q.multiplier)+2^29<2^62, ...
        'Konaet:InvalidQuantization','Acumulador pode exceder o dominio inteiro.');
end
end
