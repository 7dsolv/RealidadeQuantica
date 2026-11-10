function [s,view] = konaet_stream_step(s,m,q,controls)
%KONAET_STREAM_STEP 100 ms causais: fonte -> RC nao ideal -> ADC -> rede.
dt=0.1; t=(0:0.001:dt)'; absolute=s.time_s+t;
u=1.65+0.035*sin(2*pi*0.4*absolute)+controls.noise_V*randn(s.random,size(t));
if controls.step_enabled, u=u+controls.step_V; end
u=min(max(u,0),s.p.supply_V);
trace=konaet_rc(t,u,s.p,s.capacitor_V); s.capacitor_V=trace.capacitor_V(end);
code=round(trace.node_V(end)/0.000125); code=min(max(code,0),26400);
sample_V=code*0.000125; celsius=50+20*(sample_V-1.65);
if controls.dropout, celsius=NaN; end
s.time_s=s.time_s+dt; s.samples=s.samples+1;
s.window_C=[s.window_C(2:end);celsius];
[~,pred,quant]=tiny_int8(q,s.window_C); hidden=double(quant.hidden_int8)*q.hidden_scale;
fp=-1; if all(isfinite(s.window_C)), [~,fp]=tiny_fp32(m,s.window_C); end
view=struct('temperature_C',celsius,'sample_V',sample_V,'code',code,'class',pred, ...
    'fp32_class',fp,'hidden',hidden,'node_V',trace.node_V(end), ...
    'input_V',u(end),'current_uA',trace.source_current_A(end)*1e6, ...
    'charge_uC',trace.charge_C(end)*1e6,'warmup',s.samples<32, ...
    'model_status','own KONAET weights; synthetic source; no physical sensor');
s.time(end+1)=s.time_s; s.input(end+1)=u(end); s.node(end+1)=trace.node_V(end);
s.current(end+1)=view.current_uA; s.charge(end+1)=view.charge_uC; s.classes(end+1)=pred;
% Bound display history while preserving the causal sample window/RNG.
if numel(s.time)>300
    for name={'time','input','node','current','charge','classes'}
        s.(name{1})=s.(name{1})(end-299:end);
    end
end
end
