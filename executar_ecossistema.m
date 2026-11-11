function report=executar_ecossistema(sovereign,bot,output)
%EXECUTAR_ECOSSISTEMA Bind actual scientific output to a verified .ko receipt.
root=fileparts(mfilename('fullpath'));
if nargin<3, output=fullfile(root,'artifacts','ecosystem'); end
assert(isfile(fullfile(sovereign,'ecosystem','matlab','test_ecosystem.m')), ...
    'Konaet:EcosystemSource','Use the Sovereign revision pinned by the workflow.');
assert(isfile(fullfile(bot,'tests','run_konaet_tests.m')), 'Konaet:EcosystemSource','KONAET contract suite required.');
addpath(fullfile(sovereign,'ecosystem','matlab'));
report=test_ecosystem(sovereign,root,bot,output);
end
