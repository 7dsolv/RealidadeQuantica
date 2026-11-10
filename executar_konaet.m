function report = executar_konaet()
%EXECUTAR_KONAET Pesquisa integrada, circuito, modelos, app e evidencias.
root=fileparts(mfilename('fullpath'));
addpath(fullfile(root,'matlab','integrated'),fullfile(root,'matlab','tiny'),fullfile(root,'tests'));
output=fullfile(root,'artifacts','integrated');
report.benchmark=konaet_benchmark(root,output);
data=load(fullfile(output,'benchmark.mat'),'q','hard_x');
report.rtl=konaet_export_rtl(data.q,data.hard_x,output);
report.circuit=konaet_circuit(output); report.eda=konaet_write_eda(output);
report.tests=test_konaet_integrated(root,output);
report.app=test_konaet_app(root,output);report.visual=konaet_render(root,output);
fprintf('KONAET: %d testes numericos, %d app; PCB e FPGA verificadas pela CLI no workflow.\n',report.tests.passed,report.app.passed);
end
