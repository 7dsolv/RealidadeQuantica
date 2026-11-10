function evidence = executar_xeno(require_compiled, render_media)
%EXECUTAR_XENO Valida, calcula e exporta o prototipo numerico X-01.
if nargin<1, require_compiled=false; end
if nargin<2, render_media=true; end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
output=fullfile(root,'artifacts','xeno');
if ~isfolder(output), mkdir(output); end
addpath(fullfile(root,'tests'));
report=test_xeno(root,output,require_compiled);
p=xeno_parameters(); model=xeno_calibration(p);
r=xeno_simulate(p,model);
baseline=p; baseline.closed_loop=false; baseline.spectra=false;
uncontrolled=xeno_simulate(baseline,model);
sweep=xeno_sensitivity(p,model,12);
evidence.name=p.name; evidence.revision=getenv('GITHUB_SHA');
evidence.generated_utc=char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss'Z'"));
evidence.status='COMPUTATIONAL_PROTOTYPE';
evidence.data_origin='SYNTHETIC'; evidence.physical_material='NOT_FABRICATED';
evidence.tests=struct('passed',report.passed,'total',report.total,'compiled_required',require_compiled);
evidence.metrics=r.metrics;
evidence.metrics.feedforward_rmse_nm=uncontrolled.metrics.tracking_rmse_nm;
evidence.calibration=model;
evidence.sensitivity_scenarios=size(sweep.factors,1);
evidence.sensitivity_interpretation=sweep.interpretation;
evidence.comparison.controllers={'PI with feedforward','feedforward only'};
evidence.comparison.paired_scenarios=size(sweep.factors,1);
evidence.comparison.pi_lower_error_count=sweep.pi_lower_error_count;
evidence.comparison.pi_rmse_nm=sweep.tracking_rmse_nm;
evidence.comparison.feedforward_rmse_nm=sweep.feedforward_rmse_nm;
evidence.comparison.pi_energy_J=sweep.energy_pi_J;
evidence.comparison.feedforward_energy_J=sweep.energy_feedforward_J;
evidence.comparison.scope='same synthetic task, stimuli and noise; not an AGI benchmark';
write_json(fullfile(output,'parameters.json'),p);
write_json(fullfile(output,'evidence.json'),evidence);
trajectory=table_from_run(r);
writetable(trajectory,fullfile(output,'trajectory.csv'));
writematrix([r.depth_m squeeze(r.concentration(:,1,:))],fullfile(output,'depth_left_mol_m3.csv'));
writematrix([p.wavelength_nm r.reflectance],fullfile(output,'reflectance.csv'));
writematrix([p.wavelength_nm r.transmittance],fullfile(output,'transmittance.csv'));
writematrix([r.time_s sweep.bragg_nm],fullfile(output,'sensitivity_nm.csv'));
writematrix(sweep.factors,fullfile(output,'sensitivity_factors.csv'));
comparison=table((1:size(sweep.factors,1)).',sweep.tracking_rmse_nm,sweep.feedforward_rmse_nm, ...
    sweep.energy_pi_J,sweep.energy_feedforward_J,'VariableNames', ...
    {'scenario','pi_rmse_nm','feedforward_rmse_nm','pi_energy_J','feedforward_energy_J'});
writetable(comparison,fullfile(output,'controller_comparison.csv'));
save(fullfile(output,'x01.mat'),'p','r','model','sweep','uncontrolled','evidence');
fid=fopen(fullfile(output,'summary.txt'),'w','n','UTF-8'); assert(fid>=0);
guard=onCleanup(@() fclose(fid));
fprintf(fid,'KONAET XENOELEMENT X-01 | COMPUTATIONAL PROTOTYPE | SYNTHETIC DATA\n');
fprintf(fid,'Tests: %d/%d; physical material: NOT_FABRICATED\n',report.passed,report.total);
fprintf(fid,'Chemical mass residual: %.3e mol/m^2\n',r.metrics.max_mass_error_mol_m2);
fprintf(fid,'Optical R+T-1 maximum: %.3e\n',r.metrics.optical_balance_error);
fprintf(fid,'Bragg tracking RMSE: %.6f nm; feedforward: %.6f nm\n',r.metrics.tracking_rmse_nm,uncontrolled.metrics.tracking_rmse_nm);
fprintf(fid,'Synthetic held-out calibration RMSE (normalized c, P): %.6f %.6f\n',model.validation_rmse_normalized);
fprintf(fid,'Assumed electrical load energy: %.6f J, peak strain: %.6f\n',r.metrics.energy_J,r.metrics.peak_strain);
fprintf(fid,'Sensitivity: %d synthetic scenarios; range is not a measured confidence interval.\n',size(sweep.factors,1));
fprintf(fid,'Paired control comparison: PI has lower error in %d/%d scenarios; energy is reported separately.\n', ...
    sweep.pi_lower_error_count,size(sweep.factors,1));
clear guard;
if render_media, render_xeno(output,r,sweep,evidence); end
disp(fileread(fullfile(output,'summary.txt')));
end

function t = table_from_run(r)
theta=squeeze(mean(r.occupancy,1)).';
t=table(r.time_s,r.boundary_mol_m3(:,1),r.boundary_mol_m3(:,2),theta(:,1),theta(:,2), ...
    r.pressure_Pa,r.strain,r.capacitance_F,r.contrast,r.estimate_normalized(:,1), ...
    r.estimate_normalized(:,2),r.command,r.actuator,r.target_nm,r.bragg_nm,r.energy_J,r.mass_error_mol_m2, ...
    'VariableNames',{'time_s','boundary_left_mol_m3','boundary_right_mol_m3','theta_left', ...
    'theta_right','pressure_Pa','strain','capacitance_F','contrast','c_equiv_normalized', ...
    'pressure_estimate_normalized','command','actuator','target_nm','bragg_nm','energy_J','mass_error_mol_m2'});
end

function write_json(path,value)
fid=fopen(path,'w','n','UTF-8'); assert(fid>=0);
guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s\n',jsonencode(value,PrettyPrint=true));
end
