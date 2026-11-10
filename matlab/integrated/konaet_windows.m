function [x,y,meta] = konaet_windows(count,seed,noise_multiplier)
%KONAET_WINDOWS Episodios independentes, incluindo anomalias pouco separaveis.
if nargin<3, noise_multiplier=1; end
assert(count>=16 && mod(count,2)==0 && noise_multiplier>0);
s=RandStream('mt19937ar','Seed',seed); t=(0:31)'/10;
base=25+50*rand(s,1,count); sigma=noise_multiplier*(0.03+0.75*rand(s,1,count));
amplitude=0.1+2.5*rand(s,1,count); period=2.2+12*rand(s,1,count);
x=base+amplitude.*sin(2*pi*t./period+2*pi*rand(s,1,count)) ...
    +t.*(0.15*randn(s,1,count))+randn(s,32,count).*sigma;
y=zeros(1,count); y(2:2:end)=1; kind=zeros(1,count);
for k=2:2:count
    kind(k)=mod(k/2-1,4)+1; amount=0.3+11.7*rand(s);
    switch kind(k)
        case 1
            j=randi(s,[5 28]); x(j:min(j+1,32),k)=x(j:min(j+1,32),k)+amount;
        case 2
            j=randi(s,[10 26]); x(j:end,k)=x(j:end,k)-amount;
        case 3
            j=randi(s,[4 18]); x(j:end,k)=x(j:end,k)+linspace(0,amount,33-j)';
        case 4
            x(9:24,k)=x(9:24,k)+randn(s,16,1)*(0.3+amount/3);
    end
end
meta=struct('seed',seed,'count',count,'kind',kind,'sample_rate_Hz',10, ...
    'origin','synthetic independent episodes','noise_multiplier',noise_multiplier);
end
