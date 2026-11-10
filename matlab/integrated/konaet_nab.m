function series = konaet_nab(root)
%KONAET_NAB Avaliacao temporal de duas series reais, distinta do score NAB.
folder=fullfile(root,'datasets','nab'); source=jsondecode(fileread(fullfile(folder,'source.json')));
for k=1:numel(source.files)
    entry=source.files(k); assert(strcmp(konaet_sha256(fullfile(folder,entry.name)),entry.sha256));
end
labels=jsondecode(fileread(fullfile(folder,'selected-labels.json')));
for k=1:numel(labels.series)
    item=labels.series(k); data=readtable(fullfile(folder,item.name),'TextType','string');
    if isdatetime(data.timestamp), times=data.timestamp;
    else, times=datetime(string(data.timestamp),'InputFormat','yyyy-MM-dd HH:mm:ss'); end
    values=double(data.value); assert(all(isfinite(values)) && all(diff(times)>seconds(0)));
    truth=false(size(values));
    for j=1:numel(item.windows)
        first=datetime(item.windows(j).start,'InputFormat','yyyy-MM-dd HH:mm:ss.SSSSSS');
        last=datetime(item.windows(j).end,'InputFormat','yyyy-MM-dd HH:mm:ss.SSSSSS');
        truth=truth | (times>=first & times<=last);
    end
    prefix=floor(numel(values)*0.20);
    normal=values(1:prefix); normal=normal(~truth(1:prefix)); assert(numel(normal)>64);
    center=median(normal); ordered=sort(normal);
    span=ordered(ceil(0.75*numel(ordered)))-ordered(ceil(0.25*numel(ordered)));
    span=max(span,1e-3);
    transformed=50+10*(values-center)/span;
    % Transformacao afim de unidades originais; NAO e conversao fisica para C.
    calibration=[]; testing=[]; targets=[]; endpoints=[];
    for last=32:8:numel(values)
        first=last-31;
        if last<=prefix && ~any(truth(first:last))
            calibration(:,end+1)=transformed(first:last); %#ok<AGROW>
        elseif first>prefix
            testing(:,end+1)=transformed(first:last); %#ok<AGROW>
            targets(end+1)=double(truth(last)); endpoints(end+1)=last; %#ok<AGROW>
        end
    end
    assert(size(calibration,2)>5 && ~isempty(testing));
    meta=struct('name',item.name,'origin','NAB real sensor measurements and upstream interval labels', ...
        'unit','affine normalized source units; not physical Celsius', ...
        'normalization_center',center,'normalization_IQR',span,'normalization_prefix_samples',prefix, ...
        'native_sample_interval_s',median(seconds(diff(times))),'window_samples',32,'stride_samples',8, ...
        'label_rule','endpoint inside upstream labeled interval', ...
        'split','early 20% normal-only calibration, 31-sample boundary guard, remaining future samples for test', ...
        'official_NAB_score',false,'overlapping_windows_within_test',true, ...
        'model_training_used_this_series',false,'source_revision',source.revision);
    series(k)=struct('meta',meta,'calibration',calibration,'x',testing,'y',targets, ...
        'endpoint_indices',endpoints,'source_values',values,'source_times',times); %#ok<AGROW>
end
end
