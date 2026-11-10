function report = konaet_circuit(output)
%KONAET_CIRCUIT Trajetoria e Monte Carlo de tolerancias, sem fingir ensaio.
p=konaet_rc_parameters(); t=(0:0.001:6.4)';
vin=1.65+0.04*sin(2*pi*0.4*t)+0.12*sin(2*pi*35*t)+1.1*(t>=3.8 & t<4.5);
trace=konaet_rc(t,vin,p,1.65);
s=RandStream('mt19937ar','Seed',66001); count=256; samples=zeros(count,7);
for k=1:count
    part=p; part.resistance_Ohm=p.resistance_Ohm*(0.99+0.02*rand(s));
    part.capacitance_F=p.capacitance_F*(0.8+0.4*rand(s))*(0.75+0.25*rand(s));
    part.source_resistance_Ohm=1000*rand(s); part.esr_Ohm=0.05+1.95*rand(s);
    part.adc_resistance_Ohm=5e6+20e6*rand(s); part.leak_resistance_Ohm=10e6+40e6*rand(s);
    step=konaet_rc([0;0.05;0.3],[3.3;3.3;3.3],part,0);
    samples(k,:)=[part.resistance_Ohm part.capacitance_F part.source_resistance_Ohm ...
        part.esr_Ohm step.tau_s step.dc_gain_node step.node_V(2)];
end
columns={'R_Ohm','C_effective_F','R_source_Ohm','ESR_Ohm','tau_s','dc_gain','step_at_50ms_V'};
writetable(array2table(samples,'VariableNames',columns),fullfile(output,'circuit-tolerances.csv'));
writetable(table(t,vin,trace.node_V,trace.capacitor_V,trace.source_current_A,trace.charge_C, ...
    'VariableNames',{'time_s','input_V','adc_node_V','capacitor_V','source_current_A','charge_C'}),fullfile(output,'circuit-trace.csv'));
report=struct('source_revision',getenv('GITHUB_SHA'),'parameters',p,'monte_carlo_cases',count, ...
    'monte_carlo_seed',66001,'nominal_tau_s',trace.tau_s,'dc_gain',trace.dc_gain_node, ...
    'tau_range_s',[min(samples(:,5)) max(samples(:,5))], ...
    'energy',trace.energy,'capacitor_bias_factor','Assumed 0.75..1, not manufacturer characterization', ...
    'measurement_status','SIMULATED_NOT_MEASURED');
konaet_write_json(fullfile(output,'circuit-report.json'),report);
save(fullfile(output,'circuit.mat'),'trace','samples','report');
end
