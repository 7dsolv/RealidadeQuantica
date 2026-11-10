# Resultados computacionais iniciais

Execução de referência em 10 de novembro de 2026, revisão `6254a8764549443c6f424a0b4bb8a9b262db5d81`, [registro reproduzível no GitHub Actions](https://github.com/7dsolv/RealidadeQuantica/actions/runs/42846271054). Dados sintéticos; nenhum material físico fabricado.

| Verificação ou métrica | Resultado |
| --- | --- |
| Casos numéricos, incluindo comparação Fortran e bancada FPGA | 26/26 aprovados |
| Ciclos da bancada SystemVerilog | 5.965 verificações aprovadas |
| Resíduo máximo de massa química | 2,372 × 10⁻²⁰ mol/m² |
| Máximo de \|R + T − 1\| | 3,331 × 10⁻¹⁵ |
| Erro RMS de seguimento, PI, trajetória nominal | 2,085958 nm |
| Erro RMS de seguimento, antecipação sem realimentação | 6,247859 nm |
| Redução relativa do erro RMS nominal | aproximadamente 66,6% |
| Calibração química: RMSE normalizado, validação separada | 0,022354 |
| Calibração tátil: RMSE normalizado, validação separada | 0,014619 |
| Energia da carga hipotética, PI nominal, 72 s | 0,016331 J |
| Deformação máxima nominal | 0,063095, aproximadamente 6,31% |
| Animação | 36 quadros, 1.600 × 1.040 pixels; cerca de 2,19 MB |

Os resíduos próximos à precisão de máquina verificam a consistência do método e do balanço, não a exatidão física de um material real.

Na [revisão de integração `dddb38c`](https://github.com/7dsolv/RealidadeQuantica/actions/runs/42847039903), os 26 casos numéricos passaram novamente. As **4/4 verificações do app** também passaram, incluindo alteração dos três campos, acionamento do recálculo e conferência da nova trajetória.

## Comparação pareada dos controladores

Nos 12 cenários previamente definidos no código, o PI apresentou menor erro em todos os cenários. A média do erro RMS foi **2,143337 nm** para PI e **7,210721 nm** para antecipação. A média da energia foi **0,017771 J** e **0,012542 J**, respectivamente. O ganho no erro veio acompanhado de maior consumo no circuito resistivo assumido.

Os mesmos estímulos, ruído e calibração são usados em cada par. Os resultados por cenário estão em [controller_comparison.csv](../assets/xeno/controller_comparison.csv), e os parâmetros de cada cenário ficam no artifact `sensitivity_factors.csv`. Não há seleção de apenas cenários favoráveis depois da execução.

Isso é uma avaliação de controle da variável óptica do X-01. Não é comparação com modelos comerciais, um benchmark de agente universal, avaliação ARC-AGI ou evidência de consciência. Uma calibração aprendida de dados sintéticos também não demonstra reconhecimento de moléculas reais.

## Inspeção e reprodução

O [relatório de testes](../assets/xeno/test-report.json), a [evidência](../assets/xeno/evidence.json) e o [manifesto visual](../assets/xeno/visual-manifest.json) registram a revisão usada em cada publicação. Os números acima são o resultado inicial de referência; as evidências publicadas podem apontar para revisões posteriores. A [verificação da interface](../assets/xeno/app-report.json) registra o exercício dos controles reais do app MATLAB.

Para recalcular, use as instruções no [README](README.md). Para avaliar um material físico, são necessárias as etapas do [plano experimental](VALIDATION_PLAN.md).
