# KONAET / selos e evidências

Os selos do README apontam para execuções, releases e licenças reais. O selo de um workflow representa o resultado daquele workflow; seu alcance está na tabela abaixo. A [release integrada 0.2.0](https://github.com/7dsolv/RealidadeQuantica/releases/tag/integrated-v0.2.0) preserva os arquivos e hashes de uma execução completa.

## O que foi verificado

| Verificação | Evidência pública | Alcance |
| --- | --- | --- |
| Treino e cálculo | [17 testes numéricos](../assets/integrated/test-report.json) | Gradientes, sementes, pesos próprios, quantização, referência Fortran, dados, circuito e memória. |
| Painel MATLAB | [6 testes do app](../assets/integrated/app-report.json) | Controles, temporizador, falha, recuperação e recálculo causal. |
| Inferência SystemVerilog | [391 casos RTL](../assets/integrated/rtl.log) | Dois logits e decisão idênticos à referência inteira, com teste de protocolo. |
| Conversão ADC | [65.536 códigos](../assets/integrated/adc.log) | Todo o domínio de 16 bits comparado à escala inteira especificada. |
| Comunicação | [I²C](../assets/integrated/i2c.log) e [ADS1115](../assets/integrated/ads1115.log) | ACK/NACK, ordem dos registros, cadência e recuperação no testbench. |
| FPGA | [Relatório de roteamento](../assets/integrated/nextpnr-report.json) | Alvo de 12 MHz atingido; estimativa de 20,17 MHz. Não é medição física. |
| Esquema e placa | [ERC](../hardware/x02-acquisition/erc.json), [DRC e paridade](../hardware/x02-acquisition/drc.json) | Zero violações, conexões pendentes ou divergências no conjunto de regras definido. |
| Pesquisa persistente | [Memória](../state/konaet-research-memory.json) e [experimentos](../assets/integrated/agent-experiments.json) | Na ativação autenticada de 10/11/2026, terceiro ciclo retomado; contagens avançaram de `[4,4,4]` para `[6,6,6]`. |
| Publicação | [Execução de produção](https://github.com/7dsolv/RealidadeQuantica/actions/runs/42874651866) | Validação e publicação de memória, candidato e mídias concluídas. |
| Publicação autenticada pela App | [Registro público](../assets/integrated/publication-proof.json) e [execução real](https://github.com/7dsolv/RealidadeQuantica/actions/runs/42883960821) | App autenticada; publicação com autor e committer `konaet[bot]`. |
| Integridade do pacote | [SHA256SUMS](https://github.com/7dsolv/RealidadeQuantica/releases/download/integrated-v0.2.0/SHA256SUMS.txt) | Os arquivos baixados podem ser comparados aos hashes da release. |

Todos os resultados identificam sua revisão de origem. As verificações do circuito e da interface são simulações e checagens de ferramentas. A placa não foi fabricada; potência, latência no dispositivo e confiabilidade em sensores reais permanecem sem medição. Um ERC/DRC limpo não qualifica sozinho uma placa para fabricação.

## Identidade e credenciais

O [workflow de identidade real](https://github.com/7dsolv/konaet-bot/actions/workflows/verificar-identidade.yml) é separado dos testes offline e dos ciclos numéricos. Ele só confirma autenticação depois de obter um token da App KONAET e verificar sua identidade e seu escopo. A existência do nome `konaet[bot]` no autor Git não substitui essa prova.

A ativação foi concluída em **10/11/2026**. As credenciais estão configuradas nos dois repositórios. A [verificação real da App](https://github.com/7dsolv/konaet-bot/actions/runs/42883494662) confirmou `konaet[bot]`, ID `352182232`, com token restrito ao repositório esperado. O laboratório passou novamente em todas as verificações e publicou o [commit `c71036b`](https://github.com/7dsolv/RealidadeQuantica/commit/c71036b5f7fdbf9d76c615d0037d6d407c67d123) com autor e committer KONAET, usando o token da App. [Evidência da publicação](../assets/integrated/publication-proof.json).

O bot também criou uma [PR real de integração](https://github.com/7dsolv/konaet-bot/pull/2), com alteração restrita ao arquivo permitido; os testes passaram, a conta `7dsolv` revisou e incorporou a proposta. As publicações anteriores que usaram o token do Actions continuam registradas no histórico. O [ativador MATLAB](https://github.com/7dsolv/konaet-bot/blob/main/docs/ACTIVATION.md) permite reproduzir a configuração; chaves privadas não são incluídas no pacote.

## Conquistas do perfil

**Pull Shark** estava visível no [perfil 7dsolv](https://github.com/7dsolv?tab=achievements) durante a inspeção. Outras conquistas e badges de programas são concedidos pelo GitHub conforme atividades e critérios próprios. [Referência oficial](https://docs.github.com/en/account-and-profile/reference/profile-reference).

Os resultados de engenharia não são uma certificação do GitHub. Não há evidência de que a KONAET seja o melhor agente de uma geração: os [benchmarks publicados](RESULTS.md) incluem casos em que ela perde para a referência. Uma avaliação mais ampla exige tarefas comparáveis, dados externos bloqueados e resultados reproduzíveis.
