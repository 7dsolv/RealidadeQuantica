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
if sum(cal_valid)>=5
    rules=konaet_baselines(calibration(:,cal_valid),x);
    context=konaet_context_detector(calibration(:,cal_valid),x);
    rules(end+1)=struct('name',context.name,'threshold',context.threshold,'prediction',context.prediction);
else
    % A narrow normal prefix can have no complete representable windows.
    % Do not invent a threshold, change the split, or discard this series.
    names={'max_difference','detrended_spread','ewma_residual','KONAET_CONTEXT'};
    rules=struct('name',{},'threshold',{},'prediction',{});
    for j=1:numel(names)
        rules(j)=struct('name',names{j},'threshold',NaN,'prediction',-ones(1,size(x,2)));
    end
end
for k=1:numel(rules)
    pred=rules(k).prediction; pred(~valid)=-1;
    records(end+1)=struct('suite',suite,'model',rules(k).name,'metrics',konaet_metrics(y,pred)); %#ok<AGROW>
    paired.(rules(k).name)=pred;
end
block=1;if endsWith(suite,'.csv'),block=32;end
for k=1:numel(records)
    prediction=paired.(matlab.lang.makeValidName(records(k).model));
    records(k).metrics.bootstrap=konaet_uncertainty(y,prediction,block,256,66113);
    records(k).metrics.calibration_representable_windows=sum(cal_valid);
end
end
