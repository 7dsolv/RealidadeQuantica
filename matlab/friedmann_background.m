function model = friedmann_background(omega_m, omega_r, omega_lambda, point_count)
%FRIEDMANN_BACKGROUND Homogeneous FLRW expansion in units of H0.
%   Curvature is inferred from Omega_k = 1 - Omega_m - Omega_r - Omega_L.
%   No perturbations, structure formation, or radiation transfer are modeled.

if nargin < 4
    point_count = 1400;
end
if point_count < 100 || point_count ~= round(point_count)
    error('point_count deve ser um inteiro de pelo menos 100.');
end
if omega_m < 0 || omega_r < 0
    error('Omega_m e Omega_r devem ser nao negativos.');
end

omega_k = 1 - omega_m - omega_r - omega_lambda;
scale_factor = logspace(-5, 0, point_count).';
inverse_a = 1 ./ scale_factor;
expansion_squared = omega_r .* inverse_a.^4 ...
    + omega_m .* inverse_a.^3 ...
    + omega_k .* inverse_a.^2 ...
    + omega_lambda;

if any(expansion_squared <= 0) || any(~isfinite(expansion_squared))
    error('Os parametros escolhidos produzem H(a)^2 <= 0 na faixa simulada.');
end

expansion_rate = sqrt(expansion_squared);
integrand = 1 ./ (scale_factor .* expansion_rate);
dimensionless_time = cumtrapz(scale_factor, integrand);
deceleration = (omega_r .* inverse_a.^4 ...
    + 0.5 .* omega_m .* inverse_a.^3 - omega_lambda) ./ expansion_squared;

model.scale_factor = scale_factor;
model.dimensionless_time = dimensionless_time;
model.expansion_rate = expansion_rate;
model.deceleration = deceleration;
model.omega_m = omega_m;
model.omega_r = omega_r;
model.omega_lambda = omega_lambda;
model.omega_k = omega_k;
model.age_hubble_units = dimensionless_time(end);
model.present_deceleration = deceleration(end);
end
