function bundle = konaet_model_bundle(folder,write_bundle)
%KONAET_MODEL_BUNDLE Binds FP32, INT8, scales and candidate in one manifest.
names={'fc1_weight.f32','fc1_bias.f32','fc2_weight.f32','fc2_bias.f32', ...
    'model-card.json','quantization.json','konaet-int8.bin'};
path=fullfile(folder,'model-bundle.json');
if write_bundle
    card=jsondecode(fileread(fullfile(folder,'model-card.json')));
    bundle=struct('schema_version',1,'training_seed',card.training_seed, ...
        'research_contract',card.research_contract,'files',struct('name',{},'sha256',{}));
    for k=1:numel(names)
        bundle.files(k)=struct('name',names{k},'sha256',konaet_sha256(fullfile(folder,names{k})));
    end
    konaet_write_json(path,bundle);
else
    assert(isfile(path),'Konaet:MissingBundle','Pacote legado: regenere o modelo ou baixe a release atual.');
    bundle=jsondecode(fileread(path));
    assert(bundle.schema_version==1 && numel(bundle.files)==numel(names),'Konaet:InvalidBundle','Manifesto invalido.');
    assert(isequal(sort({bundle.files.name}),sort(names)),'Konaet:InvalidBundle','Lista de arquivos inesperada.');
    for k=1:numel(names)
        entry=bundle.files(strcmp({bundle.files.name},names{k}));
        assert(isscalar(entry) && strcmp(entry.sha256,konaet_sha256(fullfile(folder,names{k}))), ...
            'Konaet:InvalidBundle','Arquivos misturados ou metadados alterados: %s',names{k});
    end
end
end
