function u = su3_random_haar()
%SU3_RANDOM_HAAR Draw a numerically unitary 3-by-3 matrix with det(U)=1.

z = (randn(3) + 1i * randn(3)) / sqrt(2);
[q, r] = qr(z);
diagonal = diag(r);
phase = ones(3, 1);
nonzero = abs(diagonal) > 0;
phase(nonzero) = diagonal(nonzero) ./ abs(diagonal(nonzero));
u = q * diag(phase);

determinant = det(u);
if abs(determinant) > 0
    u(:, 1) = u(:, 1) * conj(determinant) / abs(determinant);
end
end
