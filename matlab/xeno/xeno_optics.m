function [R, T] = xeno_optics(wavelength_nm, n, d_nm, n0, ns)
%XENO_OPTICS Matriz caracteristica, incidencia normal, indices reais sem perda.
% n/d descrevem camadas finitas na ordem de incidencia. Sem cor RGB inventada.
validateattributes(wavelength_nm, {'double'}, {'vector','real','finite','positive'});
validateattributes(n, {'double'}, {'vector','real','finite','positive'});
validateattributes(d_nm, {'double'}, {'vector','real','finite','positive','numel',numel(n)});
assert(isscalar(n0) && isfinite(n0) && n0 > 0 && isscalar(ns) && isfinite(ns) && ns > 0);
w = wavelength_nm(:);
a = ones(size(w)); b = zeros(size(w)); c = b; d = a;
for layer = 1:numel(n)
    phase = 2*pi*n(layer)*d_nm(layer)./w;
    co = cos(phase); si = 1i*sin(phase);
    an = a.*co + b.*(si*n(layer));
    bn = a.*(si/n(layer)) + b.*co;
    cn = c.*co + d.*(si*n(layer));
    dn = c.*(si/n(layer)) + d.*co;
    a = an; b = bn; c = cn; d = dn;
end
denominator = n0*a+n0*ns*b+c+ns*d;
r = (n0*a+n0*ns*b-c-ns*d)./denominator;
t = 2*n0./denominator;
R = abs(r).^2;
T = (ns/n0)*abs(t).^2;
end
