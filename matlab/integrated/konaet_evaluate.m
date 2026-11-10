function [records,paired] = konaet_evaluate(models,x,y,calibration,suite)
%KONAET_EVALUATE Comparacao pareada com abstencao e dominio declarado.
valid=all(isfinite(x) & x>=10 & x<=90,1);
records=struct('suite',{},'model',{},'metrics',{}); paired=struct;
for k=1:numel(models)
    item=models(k); pred=-ones(1,size(x,2));
    if strcmp(item.kind,'int8')
        [~,pred]=tiny_int8(item.value,x);
    elseif any(valid)
        [~,pred(valid)]=tiny_fp32(item.value,x(:,valid));
    end
    records(end+1)=struct('suite',suite,'model',item.name,'metrics',konaet_metrics(y,pred)); %#ok<AGROW>
    paired.(matlab.lang.makeValidName(item.name))=pred;
end
cal_valid=all(isfinite(calibration) & calibration>=10 & calibration<=90,1);
rules=konaet_baselines(calibration(:,cal_valid),x);
for k=1:numel(rules)
    pred=rules(k).prediction; pred(~valid)=-1;
    records(end+1)=struct('suite',suite,'model',rules(k).name,'metrics',konaet_metrics(y,pred)); %#ok<AGROW>
    paired.(rules(k).name)=pred;
end
end
