function report = test_xeno(root, output, require_compiled)
%TEST_XENO Invariantes fisicos, solucoes analiticas e comparacao entre linguagens.
if nargin < 1, root = fileparts(fileparts(mfilename('fullpath'))); end
if nargin < 2, output = fullfile(root,'artifacts','xeno'); end
if nargin < 3, require_compiled = false; end
if ~isfolder(output), mkdir(output); end
addpath(fullfile(root,'matlab','xeno'));
p = xeno_parameters();
cases = {@reaction_mass,@reaction_equilibrium,@reaction_analytic,@reaction_zero, ...
    @diffusion_uniform,@diffusion_closed,@diffusion_balance,@diffusion_invalid_step, ...
    @mechanics_analytic,@mechanics_release,@mechanics_invalid, ...
    @optics_fresnel,@optics_balance,@optics_design,@optics_invalid, ...
    @calibration_holdout,@calibration_invalid,@seed_reproducibility, ...
    @coupled_bounds,@coupled_mass,@controller_tracking,@time_convergence,@space_convergence};
if require_compiled, cases = [cases {@fortran_comparison,@fpga_simulation}]; end
report.schema_version = 1;
report.revision = getenv('GITHUB_SHA');
report.mode = 'synthetic-numerical-validation';
report.physical_material = 'NOT_FABRICATED';
report.planned = numel(cases); report.passed = 0; report.failed = 0;
report.cases = struct('name',{},'passed',{},'duration_s',{},'message',{});
model = xeno_calibration(p);
full = xeno_simulate(p,model);
for k = 1:numel(cases)
    started = tic;
    name = func2str(cases{k}); ok = true; message = '';
    try
        cases{k}();
    catch err
        ok = false; message = err.message;
    end
    report.cases(k) = struct('name',name,'passed',ok,'duration_s',toc(started),'message',message);
    report.passed = report.passed+ok; report.failed = report.failed+~ok;
    fprintf('%s %s %s\n',string(ok),name,message);
end
report.total = numel(report.cases); report.complete = report.total == report.planned;
fid = fopen(fullfile(output,'test-report.json'),'w','n','UTF-8'); assert(fid>=0);
guard = onCleanup(@() fclose(fid));
fprintf(fid,'%s\n',jsonencode(report,PrettyPrint=true)); clear guard;
assert(report.failed == 0, 'X-01: %d/%d testes falharam.',report.failed,report.total);
fprintf('X-01: %d/%d cenarios aprovados.\n',report.passed,report.total);

    function reaction_mass()
        c = [0 0.01 0.4 3]; t = [0.9 0.5 0.1 0];
        before = c+p.site_capacity_mol_m3*t;
        [a,b] = xeno_reaction(c,t,0.7,p.site_capacity_mol_m3,p.kon_m3_mol_s,p.koff_s);
        assert(max(abs(a+p.site_capacity_mol_m3*b-before)) < 1e-14);
        assert(all(a>=0) && all(b>=0 & b<=1));
    end
    function reaction_equilibrium()
        c = 0.12; t = p.kon_m3_mol_s*c/(p.kon_m3_mol_s*c+p.koff_s);
        [a,b] = xeno_reaction(c,t,12,p.site_capacity_mol_m3,p.kon_m3_mol_s,p.koff_s);
        assert(abs(a-c)+abs(b-t)<1e-13);
    end
    function reaction_analytic()
        c = 0.2; rate=p.kon_m3_mol_s*c+p.koff_s;
        exact=p.kon_m3_mol_s*c/rate*(1-exp(-rate*2));
        errors=zeros(1,2);
        for j=1:2
            h=0.1/2^(j-1); t=0;
            for it=1:round(2/h), [~,t]=xeno_reaction(c,t,h,0,p.kon_m3_mol_s,p.koff_s); end
            errors(j)=abs(t-exact);
        end
        assert(errors(2)<0.6*errors(1) && errors(2)<0.006);
    end
    function reaction_zero()
        [c,t]=xeno_reaction(zeros(3),zeros(3),1,0.2,2,0.1);
        assert(~any(c,'all') && ~any(t,'all'));
    end
    function diffusion_uniform()
        q=p; q.site_capacity_mol_m3=0;
        c=0.2*ones(p.cells,2); t=zeros(size(c));
        [a,~,flux]=xeno_transport_step(c,t,[0.2 0.2],0.001,q);
        assert(max(abs(a-c),[],'all')<1e-14 && flux==0);
    end
    function diffusion_closed()
        c=repmat(linspace(0,0.4,p.cells).',1,2); t=0.1*ones(size(c));
        before=sum(c+p.site_capacity_mol_m3*t,'all');
        for it=1:20, [c,t,flux]=xeno_transport_step(c,t,[NaN NaN],0.001,p); assert(flux==0); end
        assert(abs(sum(c+p.site_capacity_mol_m3*t,'all')-before)<1e-12);
    end
    function diffusion_balance()
        c=zeros(p.cells,2); t=c; h=0.001;
        [c,t,flux]=xeno_transport_step(c,t,[0.1 0.3],h,p);
        assert(abs(p.length_m/p.cells*sum(c+p.site_capacity_mol_m3*t,'all')-flux)<1e-18);
    end
    function diffusion_invalid_step()
        must_fail(@() xeno_transport_step(zeros(4,2),zeros(4,2),[0 0],100,p));
    end
    function mechanics_analytic()
        [a,c]=xeno_mechanics(0,9000,0.5,p);
        exact=9000/p.young_Pa*(1-exp(-0.5*p.young_Pa/p.viscosity_Pa_s));
        assert(abs(a-exact)<1e-14);
        [~,base]=xeno_mechanics(0,0,0,p);
        assert(abs(c/base-1/(1-a))<1e-13);
    end
    function mechanics_release()
        [a,~]=xeno_mechanics(0.05,0,0.5,p);
        assert(abs(a-0.05*exp(-2))<1e-14);
    end
    function mechanics_invalid()
        must_fail(@() xeno_mechanics(0,0.2*p.young_Pa,1,p));
    end
    function optics_fresnel()
        [R,T]=xeno_optics((400:10:700).',1,200,1,1.5);
        assert(max(abs(R-0.04))<1e-13 && max(abs(T-0.96))<1e-13);
    end
    function optics_balance()
        for u=[0 0.4 1]
            [n,d]=xeno_stack(u,0.05,p);
            [R,T]=xeno_optics(p.wavelength_nm,n,d,p.n_incident,p.n_substrate);
            assert(min([R;T])>=0 && max([R;T])<=1+1e-13 && max(abs(R+T-1))<1e-12);
        end
    end
    function optics_design()
        [n,d,b]=xeno_stack(0,0,p);
        [R,~]=xeno_optics((400:0.2:540).',n,d,1,1.5);
        [~,ix]=max(R); wavelengths=(400:0.2:540).';
        assert(abs(b-p.design_nm)<1e-12 && abs(wavelengths(ix)-b)<6);
        [~,~,shift]=xeno_stack(1,0,p); assert(shift>b+80);
    end
    function optics_invalid()
        must_fail(@() xeno_optics(0,[1.5 1.3],[80 90],1,1.5));
        must_fail(@() xeno_optics(500,[1.5 1.3],[80 -90],1,1.5));
    end
    function calibration_holdout()
        assert(model.training_seed~=model.validation_seed);
        assert(all(model.validation_rmse_normalized<0.08));
        assert(all(model.validation_rmse_normalized<model.constant_baseline_rmse));
    end
    function calibration_invalid()
        q=p; q.calibration_test_seed=q.calibration_train_seed;
        must_fail(@() xeno_calibration(q));
    end
    function seed_reproducibility()
        state=rng; q=p; q.duration_s=2; q.spectra=false;
        a=xeno_simulate(q,model); b=xeno_simulate(q,model);
        assert(isequal(a,b) && isequal(state,rng));
    end
    function coupled_bounds()
        assert(all(isfinite(full.bragg_nm)) && all(full.command>=0 & full.command<=1));
        assert(all(full.actuator>=0 & full.actuator<=1) && all(full.strain<0.1));
        assert(min(full.concentration,[],'all')>=0 && min(full.occupancy,[],'all')>=0);
        assert(max(full.occupancy,[],'all')<=1 && all(abs(full.contrast)<=1));
        assert(all(diff(full.energy_J)>=0) && full.energy_J(end)>0);
    end
    function coupled_mass()
        assert(full.metrics.max_mass_error_mol_m2<1e-14);
        assert(full.metrics.optical_balance_error<1e-12);
    end
    function controller_tracking()
        q=p; q.spectra=false; q.closed_loop=false;
        base=xeno_simulate(q,model);
        assert(full.metrics.tracking_rmse_nm<base.metrics.tracking_rmse_nm);
        assert(full.metrics.tracking_rmse_nm<8);
    end
    function time_convergence()
        q=p; q.spectra=false; q.max_step_s=p.max_step_s/2;
        fine=xeno_simulate(q,model);
        assert(max(abs(fine.occupancy-full.occupancy),[],'all')<0.003);
        assert(max(abs(fine.strain-full.strain))<0.001);
    end
    function space_convergence()
        q=p; q.cells=2*p.cells; q.spectra=false;
        fine=xeno_simulate(q,model);
        assert(max(abs(squeeze(mean(fine.occupancy,1))-squeeze(mean(full.occupancy,1))),[],'all')<0.008);
    end
    function fortran_comparison()
        data=readmatrix(fullfile(output,'optics_fortran.csv'));
        [n,d]=xeno_stack(0.4,0.03,p);
        [R,T]=xeno_optics(data(:,1),n,d,p.n_incident,p.n_substrate);
        error=max(abs([R T]-data(:,2:3)),[],'all');
        assert(error<1e-12, 'MATLAB/Fortran: erro %.3g',error);
    end
    function fpga_simulation()
        log=fileread(fullfile(output,'fpga.log'));
        assert(contains(log,'XENO_FUSION_PASS checks=5965'));
    end
end

function must_fail(callback)
failed=false;
try, callback(); catch, failed=true; end
assert(failed,'Entrada invalida foi aceita.');
end
