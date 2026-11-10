function [c, theta, exchanged] = xeno_transport_step(c, theta, boundary, h, p)
%XENO_TRANSPORT_STEP FVM 1D: Dirichlet na entrada, fluxo zero no fundo.
% NaN em boundary seleciona fluxo zero tambem na entrada (teste fechado).
dx = p.length_m/size(c,1);
mu = p.diffusivity_m2_s*h/dx^2;
assert(size(c,1) >= 2 && size(c,2) == numel(boundary));
assert(mu >= 0 && mu <= 1/3, 'Passo viola positividade do transporte.');
flux = zeros(size(c,1)+1, size(c,2));
open = ~isnan(boundary);
flux(1,open) = 2*p.diffusivity_m2_s*(boundary(open)-c(1,open))/dx;
flux(2:end-1,:) = -p.diffusivity_m2_s*diff(c,1,1)/dx;
c = c + h*(flux(1:end-1,:)-flux(2:end,:))/dx;
assert(all(c(:) > -1e-12), 'Concentracao negativa no transporte.');
c = max(c,0);
exchanged = h*sum(flux(1,:)-flux(end,:)); % mol / m^2
[c,theta] = xeno_reaction(c,theta,h,p.site_capacity_mol_m3,p.kon_m3_mol_s,p.koff_s);
end
