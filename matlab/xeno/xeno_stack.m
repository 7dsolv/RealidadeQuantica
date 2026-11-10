function [n, d_nm, bragg_nm] = xeno_stack(actuation, strain, p)
%XENO_STACK Lei constitutiva HIPOTETICA para laminas opticas sinteticas.
assert(actuation >= 0 && actuation <= 1 && strain >= 0 && strain <= 0.1);
nh = p.n_high-0.08*actuation;
dh = p.high_thickness_nm*(1+0.32*actuation)*(1-0.7*strain);
dl = p.low_thickness_nm*(1+0.16*actuation)*(1-0.3*strain);
n = repmat([nh p.n_low],1,p.optical_periods);
d_nm = repmat([dh dl],1,p.optical_periods);
bragg_nm = 2*(nh*dh+p.n_low*dl); % estimativa da banda; nao argmax(R)
end
