function model = xeno_calibration(p)
%XENO_CALIBRATION Regressao ridge com calibracao/validacao SINTETICAS separadas.
assert(p.calibration_train_seed ~= p.calibration_test_seed, 'Seeds de treino e teste devem diferir.');
[X,Y] = samples(p.calibration_train_seed,p.calibration_train_count,p);
[V,Z] = samples(p.calibration_test_seed,p.calibration_test_count,p);
penalty = eye(size(X,2)); penalty(1,1) = 0;
model.weights = (X.'*X+p.ridge*size(X,1)*penalty)\(X.'*Y);
predicted = V*model.weights;
model.validation_rmse_normalized = sqrt(mean((predicted-Z).^2,1));
model.constant_baseline_rmse = sqrt(mean((mean(Y,1)-Z).^2,1));
model.training_seed = p.calibration_train_seed;
model.validation_seed = p.calibration_test_seed;
model.training_count = size(X,1);
model.validation_count = size(V,1);
model.data_origin = 'synthetic-equilibrium-calibration';
end

function [X,Y] = samples(seed,count,p)
s = RandStream('mt19937ar','Seed',seed);
cn = rand(s,count,1); pn = rand(s,count,1);
concentration = p.concentration_max_mol_m3*cn;
theta = p.kon_m3_mol_s*concentration./(p.kon_m3_mol_s*concentration+p.koff_s);
strain = pn*p.pressure_max_Pa/p.young_Pa;
cap = 1./(1-strain);
theta = min(max(theta+p.occupancy_noise_sd*randn(s,count,1),0),1);
cap = cap+p.capacitance_noise_sd*randn(s,count,1);
X = xeno_features(theta,cap);
Y = [cn pn];
end
