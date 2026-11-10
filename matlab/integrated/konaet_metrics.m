function r = konaet_metrics(truth,prediction)
%KONAET_METRICS Abstencao nunca conta como acerto ou normal resolvido.
y=truth(:); p=prediction(:); assert(numel(y)==numel(p));
r.samples=numel(y); r.tp=sum(y==1 & p==1); r.fp=sum(y==0 & p==1);
r.tn=sum(y==0 & p==0); r.fn=sum(y==1 & p~=1);
r.abstentions=sum(p<0); r.normal_abstentions=sum(y==0 & p<0);
r.coverage=mean(p>=0); r.accuracy=mean(y==p);
r.precision=r.tp/max(r.tp+r.fp,1); r.recall=r.tp/max(sum(y==1),1);
r.f1=2*r.precision*r.recall/max(r.precision+r.recall,eps);
r.false_positive_rate=r.fp/max(sum(y==0),1);
r.normal_resolution=r.tn/max(sum(y==0),1);
r.balanced_accuracy=(r.recall+r.normal_resolution)/2;
r.utility=r.balanced_accuracy-0.15*r.false_positive_rate;
end
