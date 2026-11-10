function r = xeno_simulate(p, model)
%XENO_SIMULATE Gemeo numerico hipotetico; nao representa um material fabricado.
if nargin < 1, p = xeno_parameters(); end
if nargin < 2, model = xeno_calibration(p); end
assert(p.cells >= 2 && p.cells == floor(p.cells));
assert(p.length_m > 0 && p.diffusivity_m2_s > 0 && p.duration_s > 0 && p.sample_s > 0 && p.max_step_s > 0);
assert(p.optical_periods >= 1 && p.optical_periods == floor(p.optical_periods));
s = RandStream('mt19937ar','Seed',p.seed);
time = (0:p.sample_s:p.duration_s).'; count = numel(time);
assert(count >= 2);
dx = p.length_m/p.cells;
c = zeros(p.cells,2); theta = c; strain = 0; actuator = 0.2;
integral = 0; exchanged = 0;
r.time_s = time; r.depth_m = ((1:p.cells)-0.5).'*dx;
r.concentration = zeros(p.cells,2,count);
r.occupancy = zeros(p.cells,2,count);
r.boundary_mol_m3 = zeros(count,2);
names = {'pressure_Pa','strain','capacitance_F','contrast','actuator','command', ...
    'target_nm','bragg_nm','power_W','energy_J','mass_mol_m2','mass_error_mol_m2'};
for j = 1:numel(names), r.(names{j}) = zeros(count,1); end
r.estimate_normalized = zeros(count,2);
if p.spectra
    r.reflectance = zeros(numel(p.wavelength_nm),count);
    r.transmittance = r.reflectance;
else
    r.reflectance = []; r.transmittance = [];
end
c0 = 8.8541878128e-12*p.relative_permittivity*p.electrode_area_m2/p.dielectric_thickness_m;
for k = 1:count
    if k > 1
        interval = time(k)-time(k-1);
        steps = ceil(interval/min(p.max_step_s,0.24*dx^2/p.diffusivity_m2_s));
        h = interval/steps;
        for step = 1:steps
            middle = time(k-1)+(step-0.5)*h;
            [boundary,pressure] = xeno_stimulus(middle,p);
            [c,theta,flux] = xeno_transport_step(c,theta,boundary,h,p);
            exchanged = exchanged+flux;
            [strain,~] = xeno_mechanics(strain,pressure,h,p);
        end
        actuator = r.command(k-1)+(actuator-r.command(k-1))*exp(-interval/p.actuator_tau_s);
    end
    [boundary,pressure] = xeno_stimulus(time(k),p);
    cap = c0/(1-strain);
    occupancy = mean(theta,1);
    observed = min(max(mean(occupancy)+p.occupancy_noise_sd*randn(s),0),1);
    cap_ratio = cap/c0+p.capacitance_noise_sd*randn(s);
    estimate = min(max(xeno_features(observed,cap_ratio)*model.weights,0),1);
    target = 490+85*(0.65*estimate(1)+0.35*estimate(2));
    [n,d,bragg] = xeno_stack(actuator,strain,p);
    error_nm = target-bragg;
    feedforward = (target-p.design_nm)/100;
    if p.closed_loop
        raw = feedforward+p.kp_per_nm*error_nm+integral;
        % Anti-windup: integra somente quando nao aprofunda saturacao.
        if (raw >= 0 && raw <= 1) || (raw > 1 && error_nm < 0) || (raw < 0 && error_nm > 0)
            integral = integral+p.ki_per_nm_s*error_nm*p.sample_s;
        end
        command = min(max(feedforward+p.kp_per_nm*error_nm+integral,0),1);
    else
        command = min(max(feedforward,0),1);
    end
    r.concentration(:,:,k) = c; r.occupancy(:,:,k) = theta;
    r.boundary_mol_m3(k,:) = boundary; r.pressure_Pa(k) = pressure;
    r.strain(k) = strain; r.capacitance_F(k) = cap;
    r.contrast(k) = (occupancy(1)-occupancy(2))/(sum(occupancy)+1e-4);
    r.estimate_normalized(k,:) = estimate;
    r.actuator(k) = actuator; r.command(k) = command;
    r.target_nm(k) = target; r.bragg_nm(k) = bragg;
    r.power_W(k) = p.voltage_max_V^2/p.load_ohm*command^2;
    r.mass_mol_m2(k) = dx*sum(c+p.site_capacity_mol_m3*theta,'all');
    r.mass_error_mol_m2(k) = r.mass_mol_m2(k)-exchanged;
    if p.spectra
        [r.reflectance(:,k),r.transmittance(:,k)] = xeno_optics(p.wavelength_nm,n,d,p.n_incident,p.n_substrate);
    end
end
r.energy_J = cumtrapz(time,r.power_W);
r.calibration = model; r.parameters = p;
r.metrics.tracking_rmse_nm = sqrt(mean((r.target_nm-r.bragg_nm).^2));
r.metrics.max_mass_error_mol_m2 = max(abs(r.mass_error_mol_m2));
r.metrics.peak_strain = max(r.strain);
r.metrics.energy_J = r.energy_J(end);
if p.spectra
    r.metrics.optical_balance_error = max(abs(r.reflectance+r.transmittance-1),[],'all');
end
end
