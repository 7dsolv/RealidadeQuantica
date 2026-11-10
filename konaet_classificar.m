function report = konaet_classificar(input_path,output_path,model_folder)
%KONAET_CLASSIFICAR CSV numerico local: linhas independentes de 32 temperaturas.
% Nao executa instrucoes dos arquivos, nao acessa rede nem controla atuadores.
root=fileparts(mfilename('fullpath'));addpath(fullfile(root,'matlab','integrated'),fullfile(root,'matlab','tiny'));
if nargin<2, output_path=fullfile(root,'artifacts','classification.json'); end
if nargin<3, model_folder=fullfile(root,'assets','integrated','model');end
[~,q]=konaet_load_model(model_folder);
windows=readmatrix(input_path);assert(ismatrix(windows) && size(windows,2)==32,'Cada linha precisa conter 32 temperaturas em C.');
[logits,pred,state]=tiny_int8(q,windows.');
report=struct('schema_version',1,'model','KONAET Sense 842 INT8', ...
    'source_revision',q.source_revision,'windows',size(windows,1),'classes',pred, ...
    'logits',logits.','representable',state.representable,'hidden_saturations',state.hidden_saturations, ...
    'actuation','NONE','class_definition','-1 invalid/outside numeric domain, 0 normal, 1 anomaly');
folder=fileparts(output_path);if ~isempty(folder) && ~isfolder(folder),mkdir(folder);end
konaet_write_json(output_path,report);
end
