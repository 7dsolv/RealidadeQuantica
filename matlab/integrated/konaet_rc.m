function result = konaet_rc(t,vin,p,initial)
%KONAET_RC R+Rsource, ESR, fuga e carga ADC; solucao ZOH exata de um estado.
assert(isreal(t) && isvector(t) && numel(t)>1 && all(isfinite(t)) && all(diff(t)>0));
t=t(:); assert(isreal(vin) && isequal(size(vin),size(t)) && all(isfinite(vin)));
fields={'resistance_Ohm','capacitance_F','esr_Ohm','leak_resistance_Ohm','adc_resistance_Ohm'};
for k=1:numel(fields), assert(isfinite(p.(fields{k})) && p.(fields{k})>0); end
assert(isfinite(p.source_resistance_Ohm) && p.source_resistance_Ohm>=0);
if nargin<4, initial=0; end
r=p.resistance_Ohm+p.source_resistance_Ohm; c=p.capacitance_F;
g=1/r; e=1/p.esr_Ohm; d=1/p.adc_resistance_Ohm; leak=1/p.leak_resistance_Ohm;
a=g/(g+e+d); b=e/(g+e+d); rate=(e*(1-b)+leak)/c;
gain=e*a/(rate*c); vb=zeros(size(t)); vb(1)=initial;
heat_r=0; heat_esr=0; heat_adc=0; heat_leak=0; source=0;
for k=1:numel(t)-1
    dt=t(k+1)-t(k); alpha=exp(-rate*dt); u=vin(k);
    eq=gain*u; delta=vb(k)-eq; A=a*u+b*eq; D=b*delta;
    L1=-expm1(-rate*dt)/rate; L2=-expm1(-2*rate*dt)/(2*rate);
    vb(k+1)=eq+delta*alpha;
    source=source+u*((u-A)*dt-D*L1)/r;
    heat_r=heat_r+square_integral(u-A,-D,dt,L1,L2)/r;
    heat_esr=heat_esr+square_integral(A-eq,D-delta,dt,L1,L2)/p.esr_Ohm;
    heat_adc=heat_adc+square_integral(A,D,dt,L1,L2)/p.adc_resistance_Ohm;
    heat_leak=heat_leak+square_integral(eq,delta,dt,L1,L2)/p.leak_resistance_Ohm;
end
va=a*vin+b*vb; current=(vin-va)/r;
stored=0.5*c*(vb(end)^2-vb(1)^2);
energy=struct('source_J',source,'series_heat_J',heat_r,'esr_heat_J',heat_esr, ...
    'adc_heat_J',heat_adc,'leak_heat_J',heat_leak,'capacitor_change_J',stored, ...
    'balance_residual_J',source-heat_r-heat_esr-heat_adc-heat_leak-stored);
result=struct('t_s',t,'input_V',vin,'node_V',va,'capacitor_V',vb,'source_current_A',current, ...
    'charge_C',c*vb,'stored_energy_J',0.5*c*vb.^2,'tau_s',1/rate, ...
    'dc_gain_node',a+b*gain,'energy',energy,'parameters',p);
end
function value=square_integral(a,b,dt,l1,l2)
value=a*a*dt+2*a*b*l1+b*b*l2;
% Tiny negative roundoff is bounded; physical heat is nonnegative.
assert(value>=-1e-16); value=max(value,0);
end
