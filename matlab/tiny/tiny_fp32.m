function [logits, label, hidden] = tiny_fp32(m, celsius)
%TINY_FP32 Adaptador MATLAB da AnomalyNet; colunas sao janelas de 32 amostras.
validateattributes(celsius,{'single','double'},{'real','finite','2d','nrows',32});
x=(single(celsius)-m.mean_C)/m.scale_C;
hidden=max(m.W1*x+m.b1,0);
logits=m.W2*hidden+m.b2;
[~,label]=max(logits,[],1); label=label-1;
end
