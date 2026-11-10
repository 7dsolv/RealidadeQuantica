function [m,history] = konaet_train(x,y,config,seed)
%KONAET_TRAIN MLP 32-24-2 inicializada do zero e otimizada por Adam.
s=RandStream('mt19937ar','Seed',seed);
m.W1=single(randn(s,24,32)*sqrt(2/32)); m.b1=zeros(24,1,'single');
m.W2=single(randn(s,2,24)*sqrt(2/24)*0.3); m.b2=zeros(2,1,'single');
m.mean_C=single(50); m.scale_C=single(20);
names={'W1','b1','W2','b2'}; average=struct; square=struct;
for j=1:4, average.(names{j})=zeros(size(m.(names{j})),'single'); square.(names{j})=average.(names{j}); end
history=zeros(config.epochs,1); step=0;
for epoch=1:config.epochs
    order=randperm(s,size(x,2));
    for first=1:128:numel(order)
        ix=order(first:min(first+127,numel(order))); step=step+1;
        [~,g]=konaet_loss(m,x(:,ix),y(ix),config.regularization);
        norm_g=0; for j=1:4, norm_g=norm_g+sum(double(g.(names{j})).^2,'all'); end
        factor=min(1,5/sqrt(max(norm_g,eps)));
        for j=1:4
            name=names{j}; value=g.(name)*single(factor);
            average.(name)=0.9*average.(name)+0.1*value;
            square.(name)=0.999*square.(name)+0.001*value.^2;
            update=(average.(name)/(1-0.9^step))./(sqrt(square.(name)/(1-0.999^step))+1e-8);
            m.(name)=m.(name)-single(config.learning_rate)*update;
        end
    end
    history(epoch)=konaet_loss(m,x,y,config.regularization);
end
assert(all(isfinite(history)) && all(isfinite(m.W1),'all') && all(isfinite(m.W2),'all'));
m.source=struct('model','KONAET Sense 842','author','7dsolv', ...
    'initialization','random He initialization, no imported weights', ...
    'architecture','standard dense 32-24-2 ReLU; compatible comparison interface', ...
    'revision',getenv('GITHUB_SHA'),'training_seed',seed,'training_config',config, ...
    'training_origin','KONAET synthetic independent episodes; no NAB test data');
end
