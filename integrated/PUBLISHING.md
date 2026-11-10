# Publicação e limites de ativação

**Ativação atual:** em 10/11/2026, a App KONAET foi autenticada e publicou o [ciclo integrado](https://github.com/7dsolv/RealidadeQuantica/actions/runs/42883960821) como `konaet[bot]`. [Registro auditável](../assets/integrated/publication-proof.json). O caminho alternativo descrito abaixo continua disponível quando um mantenedor não configura sua App.

O workflow gera o candidato, as métricas, as ROMs, o app, a placa, os testes e os relatórios. A publicação exige que todas essas verificações passem. Arquivos gerados são copiados de uma lista explícita, sem enviar diretórios temporários ou credenciais. A memória de pesquisa e os pesos correspondentes são publicados no mesmo commit para a próxima rodada.

Os workflows usam a App KONAET quando `KONAET_APP_CLIENT_ID` e `KONAET_APP_PRIVATE_KEY` estão configurados. Sem essas credenciais, a publicação autorizada usa o GITHUB_TOKEN, com autor `konaet[bot]` e committer `github-actions[bot]`. Isso não é assinatura criptográfica pela App. A verificação de autenticação real permanece separada e não deve ser marcada como aprovada por causa de uma execução com fixture ou token do Actions.

A Action reutilizável vive em `7dsolv/konaet-bot`; a publicação no Marketplace exige uma listagem acessível. Uma release pública deste laboratório ou da Action não confirma sozinha a listagem. Credenciais privadas e eventual aceite de contrato do Marketplace não podem ser derivados do código.

O bitstream é destinado ao iCEBreaker iCE40UP5K-SG48 e aos pinos registrados em `hardware/icebreaker/konaet.pcf`. Não fazemos upload para hardware conectado automaticamente. Antes de um ensaio físico, conferir versão da placa, tensão de 3,3 V, pinagem e sensor escolhido. Potência e latência física não foram medidas. O sistema não controla aquecedores ou equipamentos de segurança.
