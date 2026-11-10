function s = konaet_stream_init(seed)
%KONAET_STREAM_INIT Estado causal do demonstrador; RNG proprio e repetivel.
if nargin<1, seed=91001; end
s=struct('time_s',0,'capacitor_V',1.65,'window_C',nan(32,1),'samples',0, ...
    'random',RandStream('mt19937ar','Seed',seed),'p',konaet_rc_parameters(), ...
    'time',[],'input',[],'node',[],'current',[],'charge',[],'classes',[]);
end
