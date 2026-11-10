# KONAET / resultados do sistema offline

Os arquivos públicos identificam a revisão calculada. Os números abaixo descrevem uma **avaliação sintética**, não um ensaio de hardware ou comparação entre agentes universais.

| Verificação | Resultado |
| --- | --- |
| Adaptador e quantização | 10/10 testes, incluindo vetor do autor, referência Fortran e recarga do payload exportado. |
| Circuito e descrição da placa | 6/6 testes: solução de degrau, energia, passividade, ganho DC, parâmetros inválidos e consistência da fonte. |
| Avaliação pareada | 1.024 janelas; 512 normais e 512 anômalas; calibração separada em 512 janelas. |
| Acurácia FP32 / INT8 | 100% / 100% neste conjunto sintético. |
| Concordância FP32 / INT8 | 100% neste conjunto; zero entradas inválidas ou saturações ocultas. |
| Payload numérico INT8 | 920 bytes: 816 bytes de pesos e 104 de biases; escalas/runtime/buffers não incluídos. |
| RC nominal | τ = 47 ms; frequência de corte de 3,386275 Hz. |
| Balanço de energia RC | Resíduo absoluto inferior a 1,5 × 10⁻²⁰ J na trajetória ilustrada. |
| PCB | DRC KiCad 10: zero violações e zero conexões pendentes, conforme relatório completo. |

As matrizes de confusão FP32 e INT8 são ambas `[[512, 0], [0, 512]]`, com linhas indicando classe sintética real e colunas a previsão. Há 128 exemplos de cada anomalia: pico, queda de leitura, rampa e rajada de ruído. O [relatório Tiny](../assets/offline/tiny-report.json) publica também os resultados por tipo e as [previsões individuais](../assets/offline/tiny-predictions.csv) permitem auditar os totais.

Os casos são deliberadamente simples. Esse resultado não estima taxa de falha em sensores reais, generalização para outras temperaturas, robustez a todo ruído ou segurança. Não é comparável à acurácia divulgada pelo autor no conjunto original do AnomalyNet. A latência e a RAM/flash em MCU permanecem **não medidas**, e a integração física permanece **não implantada**.

O [DRC completo](../hardware/x01-carrier/kicad-report.json) preserva a versão da ferramenta, as severidades e os checks ignorados pela configuração padrão. Não foi feita comparação de paridade com esquema KiCad, pois o circuito está representado em SVG e netlist SPICE. Os courtyards descrevem envelopes genéricos; passar DRC não qualifica a placa para fabricação.

[Placa e montagem](../hardware/x01-carrier/README.md) · [Código e reprodução](README.md) · [Execuções](https://github.com/7dsolv/RealidadeQuantica/actions/workflows/offline.yml)
