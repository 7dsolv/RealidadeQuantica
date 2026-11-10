function report = executar_offline(compiled)
%EXECUTAR_OFFLINE Inferencia, circuito e PCB: nenhum acesso a rede no MATLAB.
if nargin<1, compiled=false; end
root=fileparts(mfilename('fullpath'));
addpath(fullfile(root,'matlab','tiny'),fullfile(root,'src','board'),fullfile(root,'src','circuit'));
out=fullfile(root,'artifacts','offline');
report.tiny=evaluate_tiny(root,out,compiled);
report.board=build_x01_board(root,fullfile(out,'board'));
report.chain=simulate_signal_chain(root,out);
fprintf('Offline: Tiny %d/%d; circuito %d/%d. DRC nativo em etapa separada.\n', ...
    report.tiny.passed,report.tiny.total,report.board.passed,report.board.total);
end
