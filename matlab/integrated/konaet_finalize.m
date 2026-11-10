function summary = konaet_finalize(output)
%KONAET_FINALIZE Evidencias reais das ferramentas, sem inferir medições fisicas.
read=@(name)jsondecode(fileread(fullfile(output,name)));
benchmark=read('benchmark.json');tests=read('test-report.json');app=read('app-report.json');
rtl_log=fileread(fullfile(output,'rtl.log'));
match=regexp(rtl_log,'KONAET_RTL_PASS cases=(\d+) cycles_min=(\d+) cycles_max=(\d+)','tokens','once');assert(~isempty(match));
cycles=str2double(match{3}); assert(contains(fileread(fullfile(output,'i2c.log')),'KONAET_I2C_PASS'));
assert(contains(fileread(fullfile(output,'adc.log')),'KONAET_ADC_PASS cases=65536'));
assert(contains(fileread(fullfile(output,'ads1115.log')),'KONAET_ADS1115_PASS'));
pnr=read('nextpnr-report.json');clock_names=fieldnames(pnr.fmax);frequency=[];
for k=1:numel(clock_names)
    value=pnr.fmax.(clock_names{k});assert(value.achieved>=value.constraint);
    if contains(clock_names{k},'clk'),frequency(end+1)=value.achieved;end %#ok<AGROW>
end
assert(~isempty(frequency));
fields=fieldnames(pnr.utilization);
for k=1:numel(fields),u=pnr.utilization.(fields{k});assert(u.used<=u.available);end
eda=read(fullfile('hardware','drc.json'));erc=read(fullfile('hardware','erc.json'));
assert(isempty(eda.unconnected_items) && isempty(eda.schematic_parity));
assert(~has_errors(eda.violations));
erc_count=0;
for k=1:numel(erc.sheets)
    assert(~has_errors(erc.sheets(k).violations));erc_count=erc_count+numel(erc.sheets(k).violations);
end
assert(tests.failed==0 && app.failed==0);
summary=struct('schema_version',1,'source_revision',getenv('GITHUB_SHA'),'numerical_tests',tests.passed, ...
    'app_tests',app.passed,'rtl_cases',str2double(match{1}),'adc_codes_exhaustive',65536, ...
    'i2c_ack_nack_cases',4,'adc_protocol','4 valid samples, 10 Hz scaled cadence, NACK recovery', ...
    'rtl_cycles_after_last_input',cycles,'reference_clock_Hz',12000000, ...
    'rtl_compute_latency_at_12MHz_us',cycles/12, ...
    'place_route_achieved_clock_MHz',min(frequency),'utilization',pnr.utilization, ...
    'pcb_violations',numel(eda.violations),'pcb_unconnected',numel(eda.unconnected_items), ...
    'schematic_parity_issues',numel(eda.schematic_parity),'erc_violations',erc_count, ...
    'quantized_agreement',benchmark.quantized_agreement,'physical_power','NOT_MEASURED', ...
    'physical_latency','NOT_MEASURED','manufacturing','NOT_FABRICATED', ...
    'clock_results','Tool timing estimate and RTL cycle count, not measured device benchmark');
konaet_write_json(fullfile(output,'summary.json'),summary);
fid=fopen(fullfile(output,'summary.txt'),'w','n','UTF-8');assert(fid>=0);guard=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'KONAET / pesos proprios / agente de pesquisa com memoria\n');
fprintf(fid,'Testes numericos: %d | app: %d | RTL: %d | codigos ADC: 65536\n',summary.numerical_tests,summary.app_tests,summary.rtl_cases);
fprintf(fid,'Clock alvo 12 MHz; estimativa de roteamento %.2f MHz. Calculo RTL %.2f us apos ultima entrada.\n',summary.place_route_achieved_clock_MHz,summary.rtl_compute_latency_at_12MHz_us);
fprintf(fid,'DRC: %d | desconectados: %d | paridade: %d | ERC: %d\n',summary.pcb_violations,summary.pcb_unconnected,summary.schematic_parity_issues,summary.erc_violations);
fprintf(fid,'Potencia e latencia fisica nao medidas. PCB nao fabricada. Ver benchmark completo, inclusive resultados desfavoraveis.\n');
end
function value=has_errors(items)
value=false;if isempty(items),return;end
value=any(strcmp({items.severity},'error'));
end
