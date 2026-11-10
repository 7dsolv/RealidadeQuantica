function result = konaet_baselines(calibration,evaluation)
%KONAET_BASELINES Limiares fixados somente em janelas normais de calibracao.
cal_features=features(calibration); test_features=features(evaluation);
names={'max_difference','detrended_spread','ewma_residual'};
for k=1:3
    sorted=sort(cal_features(k,:)); threshold=sorted(max(1,ceil(0.99*numel(sorted))));
    result(k)=struct('name',names{k},'threshold',threshold, ...
        'prediction',double(test_features(k,:)>threshold)); %#ok<AGROW>
end
end
function value=features(x)
delta=diff(x,1,1); ewma=x(1,:); residual=zeros(1,size(x,2));
for j=2:32, residual=max(residual,abs(x(j,:)-ewma)); ewma=0.2*x(j,:)+0.8*ewma; end
t=linspace(0,1,32)'; trend=x(1,:)+(x(end,:)-x(1,:)).*t;
value=[max(abs(delta),[],1);std(x-trend,0,1);residual];
end
