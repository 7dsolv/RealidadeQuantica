# Do cálculo à validação física

O protótipo atual usa um analito abstrato e constantes hipotéticas. Este plano define quais evidências faltam antes de tratar a simulação como projeto de um material fabricável. Não é um protocolo de síntese biológica ou molecular.

| Etapa | Medir ou demonstrar | Como se liga ao modelo |
| --- | --- | --- |
| Definir aplicação e ambiente | Intervalo de concentração, temperatura, umidade, pressão, solvente e interferentes. | Define domínio de validade, unidades e critérios antes de ajustar o modelo. |
| Selecionar componentes físicos | Membrana, transdutor químico, transdutor tátil e mecanismo óptico compatíveis. | Substitui o rótulo genérico de material por uma arquitetura verificável. |
| Transporte | Perfis ou curvas de absorção e recuperação, com espessura e condições de contorno medidas. | Estima D e verifica se difusão 1D é adequada. |
| Ligação química | Curvas de equilíbrio e transientes de associação/dissociação, incluindo interferentes. | Estima capacidade, kon/koff e testa a hipótese de sítios independentes. |
| Mecânica | Curvas de carga/descarga, relaxação, fluência, dependência de frequência e ciclos. | Verifica se Kelvin–Voigt é suficiente e mede parâmetros ou escolhe outro modelo. |
| Capacitância | Razão C/C0 versus deformação, temperatura e frequência, com leitura elétrica calibrada. | Testa área constante, fringing e permissividade. |
| Óptica | Espessura e índices complexos em função da atuação e λ; R/T medidos em ângulos definidos. | Troca as leis constitutivas hipotéticas e inclui absorção/espalhamento quando necessários. |
| Atuador e circuito | Resposta temporal, tensão/corrente, histerese, estabilidade e aquecimento. | Troca tau e a carga resistiva ilustrativa por potência medida. |
| Calibração | Amostras físicas separadas por dispositivo, lote e sessão de coleta. | Impede que validação do mesmo lote seja apresentada como generalização física. |
| Integração | Vazamento entre modalidades, envelhecimento, repetibilidade, deriva e falhas. | Quantifica limites de controle e sensoriamento fora do cenário ideal. |

Os critérios de aceitação física devem ser registrados antes de observar os dados: erro tolerável, faixa de trabalho, repetibilidade e condições de falha. Os limiares dos testes numéricos atuais são tolerâncias de implementação, não especificações garantidas de um produto.

## Evidências computacionais disponíveis

O relatório de cada execução diferencia casos aprovados e falhas; dados e parâmetros ficam junto da revisão do código. Soluções analíticas e comparação entre linguagens verificam coerência interna. A sensibilidade em 12 cenários não substitui estimativa de incerteza baseada em medidas.

## Dependências deliberadamente abertas

Não foram selecionadas sequências de DNA/RNA, proteínas recombinantes, materiais certificados, fornecedor, circuito integrado, placa FPGA ou processo de fabricação. Tampouco foram demonstradas seletividade química, biocompatibilidade, estabilidade ambiental ou segurança de um dispositivo. Cada escolha exige requisitos e evidências próprias antes de fabricação.
