function X = xeno_features(theta, capacitance_ratio)
%XENO_FEATURES Base polinomial fixa; nenhuma rede neural pre-treinada.
t = theta(:); z = (capacitance_ratio(:)-1)*10;
X = [ones(size(t)), t, t.^2, t.^3, t.^4, z, z.^2];
end
