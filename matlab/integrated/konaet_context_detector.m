function result = konaet_context_detector(calibration,evaluation)
%KONAET_CONTEXT_DETECTOR Normal-prefix envelope; no future labels or weights.
% Research comparator only. This is not part of the 842-parameter FPGA core.
assert(size(calibration,1)==32 && size(calibration,2)>=5 && all(isfinite(calibration),'all'));
a=features(calibration);b=features(evaluation);
center=median(a,2);ordered=sort(a,2);n=size(a,2);
scale=max(ordered(:,ceil(0.75*n))-ordered(:,ceil(0.25*n)),0.05);
cal_score=max(abs((a-center)./scale),[],1);
score=max(abs((b-center)./scale),[],1);
sorted=sort(cal_score);threshold=sorted(ceil(0.995*numel(sorted)));
result=struct('name','KONAET_CONTEXT','threshold',threshold,'calibration_windows',n, ...
    'prediction',double(score>threshold),'score',score, ...
    'protocol','fixed 99.5% normal calibration quantile; no evaluation labels', ...
    'deployment','MATLAB research comparator; not included in FPGA');
end
function f=features(x)
t=linspace(0,1,32)';trend=x(1,:)+(x(end,:)-x(1,:)).*t;
f=[mean(x,1);max(x,[],1)-min(x,[],1);std(x-trend,0,1);max(abs(diff(x,1,1)),[],1)];
end
