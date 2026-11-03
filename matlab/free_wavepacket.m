function [psi, probability, sigma_t] = free_wavepacket(x, sigma_0, k_0, t)
%FREE_WAVEPACKET Exact free-particle Gaussian packet in natural units.
%   hbar = m = 1. sigma_0 is the initial position standard deviation,
%   k_0 is the initial wave number, and t is time in the same unit system.

if sigma_0 <= 0
    error('sigma_0 precisa ser maior que zero.');
end

spread = 1 + 1i * t / (2 * sigma_0^2);
phase = -((x - k_0 * t).^2) ./ (4 * sigma_0^2 * spread) ...
    + 1i * k_0 .* x - 1i * (k_0^2 * t / 2);
normalization = (2 * pi * sigma_0^2)^(-1 / 4);

psi = normalization .* exp(phase) ./ sqrt(spread);
probability = abs(psi).^2;
sigma_t = sigma_0 * sqrt(1 + (t / (2 * sigma_0^2))^2);
end
