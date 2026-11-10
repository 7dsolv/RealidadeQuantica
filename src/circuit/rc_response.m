function [v, energy] = rc_response(t, input_V, resistance_Ohm, capacitance_F, initial_V)
%RC_RESPONSE Solucao exata RC para entrada constante em cada intervalo.
% input_V(k,:) vale em [t(k),t(k+1)); SI: s, V, Ohm, F, J.
assert(isvector(t) && numel(t)>=2 && all(isfinite(t)) && all(diff(t)>0));
t=t(:); assert(size(input_V,1)==numel(t) && all(isfinite(input_V),'all'));
assert(isscalar(resistance_Ohm) && isfinite(resistance_Ohm) && resistance_Ohm>0);
assert(isscalar(capacitance_F) && isfinite(capacitance_F) && capacitance_F>0);
if nargin<5, initial_V=zeros(1,size(input_V,2)); end
assert(numel(initial_V)==size(input_V,2) && all(isfinite(initial_V)));
v=zeros(size(input_V)); v(1,:)=initial_V(:).';
source=zeros(1,size(v,2)); heat=source;
tau=resistance_Ohm*capacitance_F;
for k=1:numel(t)-1
    a=exp(-(t(k+1)-t(k))/tau); u=input_V(k,:); d=v(k,:)-u;
    v(k+1,:)=u+d*a;
    source=source+capacitance_F*u.*(v(k+1,:)-v(k,:));
    heat=heat+0.5*capacitance_F*d.^2*(1-a*a);
end
energy.source_J=source;
energy.resistor_heat_J=heat;
energy.capacitor_change_J=0.5*capacitance_F*(v(end,:).^2-v(1,:).^2);
energy.balance_residual_J=source-heat-energy.capacitor_change_J;
end
