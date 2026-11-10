# KONAET / evidências e resultados

[Resumo da execução publicada](../assets/integrated/summary.json) · [Benchmark completo](../assets/integrated/benchmark.json) · [Experimentos escolhidos pelo agente](../assets/integrated/agent-experiments.json) · [Memória persistida](../state/konaet-research-memory.json)

O campo `source_revision` identifica o código de cada resultado. As imagens usam os valores dessa execução. Mudanças na política ou no candidato podem alterar os resultados de rodadas posteriores; os arquivos de release preservam o pacote exato de uma versão.

## Primeira referência de treinamento

Na [revisão `4c1b0fa`](https://github.com/7dsolv/RealidadeQuantica/actions/runs/42867747308), antes da integração final de PCB/painel, os 16 testes numéricos e 391 vetores RTL passaram. Os dois logits INT32 foram idênticos à referência MATLAB em todos os casos. Cada inferência consumiu **2.472 ciclos após a última entrada**. A seleção do candidato usou o desenvolvimento, sem acesso ao teste final.

| Conjunto | KONAET INT8: acurácia balanceada | AnomalyNet INT8: acurácia balanceada |
| --- | --- | --- |
| Sintético difícil, 2.048 janelas | 81,93% | 73,49% |
| Série real NAB: temperatura da máquina | 55,58% | 85,63% |
| Série real NAB: temperatura ambiente | 49,82% | 50,95% |

No sintético difícil, a KONAET detectou 72,66% das anomalias, com 8,79% de falsos positivos; a regra EWMA obteve 81,15% de acurácia balanceada, 63,09% de recall e 0,78% de falsos positivos. A rede pode ser melhor em recall e pior em falsos alarmes, conforme a tarefa e o custo do erro. O benchmark publica as três regras estatísticas e as quatro variantes neurais, inclusive cenários em que a KONAET perde.

Na série real da máquina, a KONAET teve recall de 28,87% e a versão AnomalyNet INT8 teve 90,85%. Na série ambiente houve excesso de falsos alarmes nos dois modelos. **Esses resultados ainda não sustentam implantação em sensores reais.** Tampouco demonstram superioridade sobre outros agentes de IA. As séries usam transformação afim e outro período de amostragem, com deslocamento de domínio em relação ao treino a 10 Hz.

Esse protocolo por janelas não é o score oficial NAB. Os dados reais não foram usados para selecionar os pesos. A normalização usa só o prefixo de calibração, e as janelas do teste se sobrepõem. As taxas não devem ser interpretadas como observações independentes de confiabilidade industrial.

## Evidência de implementação

- [Testes numéricos](../assets/integrated/test-report.json): gradiente, sementes, treino, separação dos conjuntos, pesos próprios, quantização, exportação, referência Fortran, dados reais, entradas inválidas, circuito, energia, memória e CSV.
- [App MATLAB](../assets/integrated/app-report.json): recálculo causal, degrau, falha, recuperação, reset e temporizador.
- [Vetores RTL](../assets/integrated/rtl/rtl-vectors.json) e [log](../assets/integrated/rtl.log): logits, decisão, limites dos acumuladores e protocolo de entrada.
- [ADC exaustivo](../assets/integrated/adc.log): todos os 65.536 códigos de 16 bits comparados com a fórmula inteira.
- [I²C](../assets/integrated/i2c.log) e [ADS1115](../assets/integrated/ads1115.log): bytes, ACK/NACK, ordem dos registros, cadência e recuperação de falha.
- [Circuito não ideal](../assets/integrated/circuit-report.json): balanço de energia e 256 cenários hipotéticos de tolerâncias.
- [KiCad ERC](../hardware/x02-acquisition/erc.json), [DRC e paridade](../hardware/x02-acquisition/drc.json): relatórios completos e configuração da placa.
- [nextpnr](../assets/integrated/nextpnr-report.json): recursos usados e estimativa de timing; não é medição física.

O tempo de cálculo derivado de ciclos e clock exclui aquisição da janela, conversão ADC, comunicação e inicialização. O núcleo trabalha com blocos de 32 amostras; a primeira decisão requer coletar a janela. Potência, latência no dispositivo, robustez eletromagnética e comportamento de sensores reais permanecem **não medidos**. A placa não foi fabricada.

## Critério de publicação

Todas as verificações precisam passar antes de publicar memória, pesos e imagens. O histórico conserva resultados anteriores e suas revisões. Retomar a pesquisa é demonstrado tanto por teste de estado quanto por ciclos publicados, com contagens e recompensas explícitas. Ganhar uma tarefa restrita não transforma o sistema em inteligência geral.
