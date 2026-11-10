function [loss,gradient] = konaet_loss(m,celsius,truth,regularization)
%KONAET_LOSS Entropia cruzada e gradiente analitico, sem toolbox de IA.
x=(single(celsius)-single(50))/single(20); n=size(x,2);
h=max(m.W1*x+m.b1,0); z=m.W2*h+m.b2;
z=z-max(z,[],1); p=exp(z); p=p./sum(p,1);
indices=sub2ind(size(p),truth+1,1:n);
loss=-mean(log(max(double(p(indices)),realmin))) ...
    +regularization/2*(sum(double(m.W1).^2,'all')+sum(double(m.W2).^2,'all'));
if nargout<2, return; end
p(indices)=p(indices)-1; d=p/single(n);
gradient.W2=d*h'+single(regularization)*m.W2; gradient.b2=sum(d,2);
dh=(m.W2'*d).*(h>0);
gradient.W1=dh*x'+single(regularization)*m.W1; gradient.b1=sum(dh,2);
end
