function [temperature, label] = tiny_windows(count, seed)
%TINY_WINDOWS Avaliacao sintetica propria; nao e o dataset de treino original.
assert(count>=8 && mod(count,2)==0);
s=RandStream('mt19937ar','Seed',seed);
t=(0:31).'/10;
temperature=50+0.7*randn(s,1,count)+0.3*sin(2*pi*t/15+2*pi*rand(s,1,count)) ...
    +0.08*randn(s,32,count)+t.*(0.08*randn(s,1,count));
label=zeros(1,count); label(2:2:end)=1;
for k=2:2:count
    kind=mod(k/2-1,4)+1;
    switch kind
        case 1
            pos=randi(s,[7 25]); temperature(pos:pos+1,k)=temperature(pos:pos+1,k)+10+12*rand(s);
        case 2
            pos=randi(s,[12 24]); temperature(pos:end,k)=temperature(pos:end,k)-12-10*rand(s);
        case 3
            temperature(:,k)=temperature(:,k)+linspace(0,12+12*rand(s),32).';
        case 4
            temperature(9:24,k)=temperature(9:24,k)+5*randn(s,16,1);
    end
end
end
