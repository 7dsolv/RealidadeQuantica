function [boundary, pressure] = xeno_stimulus(t, p)
%XENO_STIMULUS Duas amostras quimicas laterais e pressao sinteticas.
a = pulse(t,5,31); b = pulse(t,37,63);
boundary = p.concentration_max_mol_m3*[0.95*a+0.25*b, 0.40*a+0.90*b];
pressure = p.pressure_max_Pa*(0.70*pulse(t,14,26)+0.95*pulse(t,44,57));
end

function y = pulse(t,start,finish)
y = 0;
if t > start && t < finish, y = sin(pi*(t-start)/(finish-start))^2; end
end
