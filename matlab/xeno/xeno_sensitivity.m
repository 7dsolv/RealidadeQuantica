function sweep = xeno_sensitivity(p, model, count)
%XENO_SENSITIVITY Cenarios hipoteticos; nao sao intervalos de confianca medidos.
if nargin < 3, count = 12; end
s = RandStream('mt19937ar','Seed',p.seed+77);
sweep.factors = [0.7+0.6*rand(s,count,1), 0.75+0.5*rand(s,count,1), -0.025+0.05*rand(s,count,1)];
sweep.bragg_nm = zeros(round(p.duration_s/p.sample_s)+1,count);
sweep.tracking_rmse_nm = zeros(count,1);
sweep.feedforward_rmse_nm = zeros(count,1);
sweep.energy_pi_J = zeros(count,1);
sweep.energy_feedforward_J = zeros(count,1);
for k = 1:count
    q=p; q.spectra=false;
    q.diffusivity_m2_s=p.diffusivity_m2_s*sweep.factors(k,1);
    q.young_Pa=p.young_Pa*sweep.factors(k,2);
    q.n_high=p.n_high+sweep.factors(k,3);
    r=xeno_simulate(q,model);
    sweep.bragg_nm(:,k)=r.bragg_nm;
    sweep.tracking_rmse_nm(k)=r.metrics.tracking_rmse_nm;
    sweep.energy_pi_J(k)=r.metrics.energy_J;
    q.closed_loop=false;
    baseline=xeno_simulate(q,model);
    sweep.feedforward_rmse_nm(k)=baseline.metrics.tracking_rmse_nm;
    sweep.energy_feedforward_J(k)=baseline.metrics.energy_J;
end
sweep.minimum_nm = min(sweep.bragg_nm,[],2);
sweep.maximum_nm = max(sweep.bragg_nm,[],2);
sweep.interpretation = 'range-across-synthetic-parameter-scenarios-not-confidence-interval';
sweep.pi_lower_error_count = sum(sweep.tracking_rmse_nm<sweep.feedforward_rmse_nm);
end
