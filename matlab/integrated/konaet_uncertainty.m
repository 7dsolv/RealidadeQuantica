function ci = konaet_uncertainty(y,p,block,replicates,seed)
%KONAET_UNCERTAINTY Conditional moving-block bootstrap, preserving short lags.
y=y(:);p=p(:);n=numel(y);assert(n==numel(p) && n>=2);
block=min(block,n);s=RandStream('mt19937ar','Seed',seed);
values=nan(replicates,3);
for k=1:replicates
    starts=randi(s,n-block+1,1,ceil(n/block));indices=reshape((0:block-1)'+starts,[],1);indices=indices(1:n);
    truth=y(indices);prediction=p(indices);
    if ~any(truth==0) || ~any(truth==1),continue;end
    m=konaet_metrics(truth,prediction);
    values(k,:)=[m.balanced_accuracy m.recall m.false_positive_rate];
end
valid=values(all(isfinite(values),2),:);bounds=nan(2,3);
if size(valid,1)>=max(20,0.8*replicates)
    ordered=sort(valid,1);count=size(ordered,1);
    bounds=ordered([max(1,ceil(0.025*count)) max(1,ceil(0.975*count))],:);
end
ci=struct('method','moving-block bootstrap, conditional on this series', ...
    'block_windows',block,'replicates',replicates,'valid_replicates',size(valid,1),'seed',seed, ...
    'balanced_accuracy_95',bounds(:,1)','recall_95',bounds(:,2)','false_positive_rate_95',bounds(:,3)', ...
    'limitation','Block length is a declared heuristic; not independent-device or industrial reliability evidence');
end
