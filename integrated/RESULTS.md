# KONAET / evidências e resultados

[Resumo da execução publicada](../assets/integrated/summary.json) · [Benchmark completo](../assets/integrated/benchmark.json) · [Experimentos escolhidos pelo agente](../assets/integrated/agent-experiments.json) · [Memória persistida](../state/konaet-research-memory.json)

O campo `source_revision` identifica o código de cada resultado. As imagens usam os valores dessa execução. Mudanças na política ou no candidato podem alterar os resultados de rodadas posteriores; os arquivos de release preservam o pacote exato de uma versão.

## Avaliação ampliada de 10/11/2026

A [execução completa da correção](https://github.com/7dsolv/RealidadeQuantica/actions/runs/42906445449)
passou em **26 testes numéricos, 6 do app, 391 vetores RTL, 65.536 códigos ADC e
3 cenários de integração completa ADC → inferência → LEDs**, além de ERC/DRC e
roteamento. Esses números representam contratos de software e simulação.

O novo contrato de pesquisa reiniciou o ciclo e escolheu outro candidato somente
pelo desenvolvimento original. Portanto, a mudança em relação à referência
histórica abaixo não isola o efeito de um único algoritmo. No sintético difícil,
a KONAET INT8 marcou 80,71%; na série já conhecida da máquina, 69,69% contra
85,63% da AnomalyNet. O intervalo de 95% por bootstrap da KONAET nessa série foi
59,76–79,38%, condicional aos dados e ao tamanho de bloco declarado.

| Série real | KONAET INT8: BA | AnomalyNet INT8: BA | KONAET_CONTEXT: BA | Cobertura das entradas |
| --- | ---: | ---: | ---: | ---: |
| Máquina — retrospectiva | 69,69% | 85,63% | 50,30% | 100% |
| Ambiente — retrospectiva | 49,61% | 50,95% | 50,00% | 100% |
| CPU ASG — nova série | 0,00% | 0,00% | 0,00% | **0%** |
| Latência EC2 — nova série | 38,65% | 38,37% | 48,70% | 97,49% |
| Táxis NYC — nova série | 49,67% | 50,00% | 51,94% | 100% |
| CPU EC2 5f5533 — nova série | 48,86% | 46,14% | 33,43% | 99,00% |

BA é acurácia balanceada, contando abstenções como casos não resolvidos.
**Zero falsos positivos com cobertura zero não significa detecção correta.**
A normalização declarada da CPU ASG produz janelas fora do domínio; nenhum
método resolve esses casos. A série permanece publicada. Quando não existem
cinco janelas de calibração representáveis, as regras também se abstêm, sem
inventar um limiar ou modificar o corte temporal depois de ver os resultados.

O [protocolo](evaluation-protocol.json) fixou quatro novas séries antes da primeira
execução do comparador, prefixo de 20%, janela 32, passo 8 e 256 réplicas de
bootstrap. O comparador contextual é uma regra MATLAB separada dos 842 pesos
neurais e da FPGA. Seu 100% no sintético simples é restrito àquele conjunto;
seu desempenho real inclui os resultados baixos da tabela. Não foi ajustado aos
rótulos futuros após esta execução. Os oito métodos, decisões por janela,
recall, falsos positivos, cobertura e intervalos ficam no benchmark completo.

Esses resultados não demonstram superioridade geral. Para avançar, o projeto
precisa tratar a transferência de domínio com dados de treinamento apropriados
e avaliar a próxima hipótese em outras séries ainda não usadas para ajustes.

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
