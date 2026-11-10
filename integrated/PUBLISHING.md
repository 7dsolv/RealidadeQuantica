# Publicação e integridade

A App KONAET está autenticada nos dois repositórios. A [evidência original](../assets/integrated/publication-proof.json) registra a ativação real; a [checagem independente do pacote](https://github.com/7dsolv/konaet-bot/actions/workflows/verificar-identidade.yml) pode repeti-la. A autoria Git, isoladamente, não autentica a App.

## Da execução à main

1. O produtor captura os hashes dos arquivos de cálculo, dados, dependências, configuração, pinagem e estado de entrada antes de executar.
2. MATLAB, Fortran, RTL e ferramentas EDA geram e verificam a rodada. O artifact inclui fonte, runner, versões e manifesto.
3. O publicador confere esse manifesto contra a main atual. Se código ou estado do próprio módulo mudou durante a execução, ele rejeita os resultados e exige uma nova rodada.
4. A App abre ou atualiza uma PR com somente os caminhos gerados autorizados. Memória, modelo, escalas e mídias correspondentes seguem juntos.
5. O contrato de publicação compara novamente os inputs com a base da PR. A proteção da main exige CI; arquivos de código e política têm CODEOWNERS. Não há force push ou escrita direta do publicador na main.
6. O reconciliador só atualiza a base de propostas geradas se seus inputs ainda forem válidos. A integração automática depende dos checks obrigatórios.

Os manifests ficam em `assets/{integrated,offline,xeno,physics}/publication-source.json` e `publication-inputs.sha256` depois da primeira publicação desse protocolo. A revisão do produtor pode ser anterior à revisão mais recente da main quando apenas documentação ou saídas de outro módulo mudaram. Os hashes dos inputs, não essa coincidência de SHAs, determinam compatibilidade.

Sem a App configurada, a validação continua disponível e a publicação é omitida. Não há fallback que atribua a identidade KONAET ao token de outro bot.

## Modelos e pesquisa

O contrato de pesquisa cobre todos os arquivos MATLAB de inferência, treino, quantização, métricas e seleção, além da procedência dos dados e do protocolo. A continuidade revalida contagens, recompensas e a utilidade do melhor candidato no desenvolvimento original.

`model-bundle.json` liga os sete arquivos FP32/INT8/metadados à mesma semente e contrato. Um pacote legado sem esse manifesto precisa ser regenerado. Um hash detecta alteração e mistura acidental; ele não substitui a confiança na origem do código e da release.

## Distribuição

As Actions são fixadas em SHA completo; o lock registra versões diretas das ferramentas e R2026b. O artifact registra também a imagem do runner e os pacotes transitivos. A imagem inteira do sistema operacional não é reproduzida bit a bit.

As novas releases usam a configuração de imutabilidade do repositório: prepare o draft, anexe todos os arquivos e hashes, confira, então publique. Versões antigas não são reescritas. Uma release pública não comprova uma listagem no Marketplace.

O bitstream corresponde ao iCEBreaker iCE40UP5K-SG48 e à pinagem versionada. O workflow não grava placas conectadas. A aquisição usa blocos de 32 amostras a 10 Hz; o tempo de cálculo começa depois da última amostra. [Plano de ensaio físico](HARDWARE_VALIDATION.md).
