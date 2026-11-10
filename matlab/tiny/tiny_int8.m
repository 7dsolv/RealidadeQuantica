function [logits, label, status] = tiny_int8(q, celsius)
%TINY_INT8 MACs inteiros; softmax nao e necessario para a decisao binaria.
assert(size(celsius,1)==32 && isreal(celsius));
x=(double(celsius)-q.mean_C)/q.scale_C;
finite=all(isfinite(x),1);
status.representable=finite & all(abs(x)<=127*q.input_scale,1);
x(:,~finite)=0;
qx=int8(min(max(round(x/q.input_scale),-127),127));
acc=repmat(q.b1,1,size(x,2));
for j=1:32, acc=acc+int32(q.W1(:,j)).*int32(qx(j,:)); end
positive=int64(max(acc,0));
requant=bitshift(positive*q.multiplier+int64(2^29),-q.shift);
status.hidden_saturations=sum(requant>127,1);
qh=int8(min(requant,127));
acc2=repmat(q.b2,1,size(x,2));
for j=1:24, acc2=acc2+int32(q.W2(:,j)).*int32(qh(j,:)); end
status.input_int8=qx; status.hidden_int8=qh; status.accumulators_int32=acc2;
logits=double(acc2)*(q.hidden_scale*q.w2_scale);
[~,label]=max(acc2,[],1); label=label-1;
label(~status.representable)=-1; % invalido e diferente de normal
end
