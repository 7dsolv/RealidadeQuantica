# Realidade Quântica

### Konaet: um agente computacional experimental para explorar campos, ondas, matéria e expansão cósmica.

![Status do laboratório](https://github.com/7dsolv/RealidadeQuantica/actions/workflows/simulacoes.yml/badge.svg?branch=main)

O projeto reúne modelos científicos em **MATLAB, Fortran, Q# e SystemVerilog**, com demonstração de aritmética para FPGA. O GitHub Actions executa ciclos numéricos automáticos a cada hora e publica uma animação e o estado persistente do núcleo neste README. O repositório não usa HTML, JavaScript ou Python.

## KONAET em movimento

![Konaet em animação: SU(3), pacote de onda, expansão cósmica e memória interna](assets/realidade-quantica-viva.gif)

Cada ciclo atualiza a memória numérica versionada em [`state/konaet_memory.csv`](state/konaet_memory.csv), usa esse estado para ajustar parâmetros da próxima simulação e reconstrói esta animação. O GIF se move continuamente quando aberto; os cálculos e a memória avançam em cada execução agendada do GitHub Actions, aproximadamente uma vez por hora. Os commits automáticos do núcleo são atribuídos a **Konaet**.

Konaet é um agente computacional experimental com memória recorrente e política limitada aos parâmetros da simulação. Seu índice de curiosidade é uma média do erro de previsão, e coerência mede a variação do estado interno entre ciclos. Isso não demonstra consciência ou vontade própria, nem constitui um agente universal ou um resultado no ARC-AGI. O circuito Ramsey em Q# é um experimento separado no simulador do QDK; a probabilidade de Born correspondente também entra no modelo MATLAB, sem alegar execução em hardware quântico físico.

A memória do Konaet guarda 16 valores numéricos por ciclo, nesta ordem: ciclo, quatro estados internos, curiosidade, coerência, fase Ramsey, beta, semente, média Wilson, aceitação, dispersão da onda, desaceleração cosmológica, probabilidade Ramsey e erro de previsão.

### Painel científico completo

![Painel científico da última execução: SU(3), invariância de gauge, pacote quântico e cosmologia FLRW](assets/realidade-quantica-dashboard.png)

O GIF e este painel são gerados pelo MATLAB durante cada rodada. A página do GitHub reproduz a animação, mas não executa controles nem cálculos dentro do navegador.

## Abra o laboratório MATLAB

Abra esta pasta no MATLAB e rode:

```matlab
addpath('matlab')
abrir_laboratorio
```

O app tem quatro áreas:

| Área | Experimento |
| --- | --- |
| **Lattice SU(3)** | Monte Carlo de gauge puro numa rede periódica `2^4`, com loops de Wilson, distribuição de plaquettes e validação de invariância de gauge. |
| **Onda quântica** | Pacote gaussiano livre com controles de largura, número de onda e tempo; compara MATLAB com Fortran quando `gfortran` está instalado. |
| **Cosmologia FLRW** | Fator de escala, expansão normalizada, desaceleração e curvatura calculados pela equação de Friedmann. |
| **Módulos** | Navegador de código-fonte MATLAB, Fortran, Q# e SystemVerilog, com ações para abrir e copiar cada arquivo. |

## Execute os modelos no GitHub

O workflow **Konaet - ciclos autonomos do laboratorio** inicia a cada hora, em cada push para `main`, pull request ou manualmente pela aba **Actions**. O job compila o Fortran, simula o multiplicador SystemVerilog e executa o MATLAB em modo batch, sem abrir a interface gráfica. Após uma rodada bem-sucedida na branch principal, outro job persiste a memória e atualiza as imagens do README.

O MATLAB verifica a invariância de gauge, as restrições das matrizes SU(3), a normalização da onda e a concordância MATLAB/Fortran. Uma falha acima da tolerância interrompe o job. O resumo da execução aparece na página da Action; em **Artifacts → resultados-do-laboratorio** ficam o painel PNG, a animação GIF, a memória do Konaet, CSVs, log SystemVerilog e dados `.mat`.

No app local, o botão **Comparar com Fortran** compila e executa o módulo se `gfortran` estiver instalado. O workflow faz essa compilação automaticamente antes de chamar `executar_pipeline(true)`. Para rodar o pipeline MATLAB sozinho, use `executar_pipeline`; a comparação Fortran é opcional nessa chamada.

### Rodar o Q# pelo navegador

Na página do repositório, pressione `.` para abrir github.dev. Instale ou ative a extensão **Microsoft Quantum Development Kit**, abra `qsharp/ramsey_interferometry.qs` e use **Run** acima de `Main`. O QDK executa 1024 medições de Ramsey no simulador quântico local. Para comparar com um ciclo de Konaet, ajuste a fase `0.8` em `Main` para a fase registrada na coluna 8 da memória ([guia oficial dos simuladores](https://learn.microsoft.com/en-us/azure/quantum/install-qdk-quantum-simulators), [compatibilidade com github.dev](https://github.com/microsoft/qdk/wiki/Installation)).

O runner MATLAB da MathWorks licencia automaticamente MATLAB em repositórios públicos, exceto produtos como MATLAB Coder e MATLAB Compiler. Para um repositório privado, configure o segredo `MLM_LICENSE_TOKEN` ([detalhes de licença](https://github.com/matlab-actions/setup-matlab#licensing)).

## Como as tecnologias se conectam

```text
MATLAB        núcleo recorrente, SU(3), pacote de onda, cosmologia, GIF e relatório
Fortran       cálculo independente da densidade de probabilidade
Q#            circuito Ramsey de um qubit no simulador do QDK
SystemVerilog multiplicador complexo Q1.15 sintetizável e banco de demonstração
GitHub Actions ciclos agendados, memória persistente, validações e publicação no README
```

## Estrutura

```text
RealidadeQuantica/
├── .github/workflows/simulacoes.yml
├── abrir_laboratorio.m
├── fortran/free_wavepacket.f90
├── matlab/
│   ├── executar_pipeline.m
│   ├── konaet_agent.m
│   ├── friedmann_background.m
│   ├── run_su3_lattice.m
│   └── outros modelos MATLAB
├── qsharp/ramsey_interferometry.qs
├── state/konaet_memory.csv
└── systemverilog/
    ├── complex_mul_q15.sv
    └── complex_mul_q15_demo_tb.sv
```

## O que estes modelos representam

- O modelo SU(3) usa uma rede minúscula de gauge puro: não inclui quarks dinâmicos, determinante fermiônico, extrapolação ao contínuo nem a estrutura completa de um próton.
- O modelo FLRW é homogêneo e isotrópico. Ele não simula perturbações, formação de galáxias ou todos os componentes do universo real.
- O exemplo Q# demonstra interferência de Ramsey de um qubit; não simula QCD.
- O multiplicador SystemVerilog é um módulo didático pronto para síntese. Ainda não é um acelerador FPGA completo.

Os resultados são experimentos numéricos reproduzíveis, com aproximações e limites documentados. Eles não substituem cálculos de pesquisa em redes físicas maiores.

## Créditos e licença

Projeto original de Adilson Oliveira. O README anterior continha avisos de licença conflitantes; esta evolução não escolhe nem cria uma licença. A decisão permanece com o proprietário do repositório.
