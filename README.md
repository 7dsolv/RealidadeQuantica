# Realidade Quântica

### Um laboratório computacional para explorar campos, ondas, matéria e expansão cósmica.

![Status do laboratório](https://github.com/7dsolv/RealidadeQuantica/actions/workflows/simulacoes.yml/badge.svg?branch=main)

O projeto reúne modelos científicos em **MATLAB, Fortran, Q# e SystemVerilog**, com demonstração de aritmética para FPGA. A interface interativa é feita em MATLAB; o GitHub Actions executa os cálculos em lote e publica a imagem mais recente aqui no README. O repositório não usa HTML, JavaScript ou Python.

## Painel da última execução

![Painel científico da última execução: SU(3), invariância de gauge, pacote quântico e cosmologia FLRW](assets/realidade-quantica-dashboard.png)

Quando o workflow termina com sucesso na branch `main`, o GitHub atualiza esta imagem junto com os resultados da rodada. É um painel de snapshots por execução, não uma visualização contínua ou interativa.

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

O workflow **Rodar laboratório científico** inicia em cada push para `main`, pull request ou manualmente em **Actions → Rodar laboratório científico → Run workflow**. O job compila o Fortran, simula o multiplicador SystemVerilog e executa o MATLAB em modo batch, sem abrir a interface gráfica.

O MATLAB verifica a invariância de gauge, as restrições das matrizes SU(3), a normalização da onda e a concordância MATLAB/Fortran. Uma falha acima da tolerância interrompe o job. O resumo da execução aparece na página da Action; em **Artifacts → resultados-do-laboratorio** ficam o painel PNG, CSVs, log SystemVerilog e dados `.mat`.

No app local, o botão **Comparar com Fortran** compila e executa o módulo se `gfortran` estiver instalado. O workflow faz essa compilação automaticamente antes de chamar `executar_pipeline(true)`. Para rodar o pipeline MATLAB sozinho, use `executar_pipeline`; a comparação Fortran é opcional nessa chamada.

### Rodar o Q# pelo navegador

Na página do repositório, pressione `.` para abrir github.dev. Instale ou ative a extensão **Microsoft Quantum Development Kit**, abra `qsharp/ramsey_interferometry.qs` e use **Run** acima de `Main`. O QDK fornece um simulador quântico local para os arquivos Q# e documenta suporte ao VS Code para Web ([guia oficial do simulador](https://learn.microsoft.com/en-us/azure/quantum/qdk-simulator-vscode), [compatibilidade com github.dev](https://github.com/microsoft/qdk/wiki/Installation)).

O runner MATLAB da MathWorks licencia automaticamente MATLAB em repositórios públicos, exceto produtos como MATLAB Coder e MATLAB Compiler. Para um repositório privado, configure o segredo `MLM_LICENSE_TOKEN` ([detalhes de licença](https://github.com/matlab-actions/setup-matlab#licensing)).

## Como as tecnologias se conectam

```text
MATLAB        interface visual, SU(3), pacote de onda, cosmologia e relatório
Fortran       cálculo independente da densidade de probabilidade
Q#            circuito Ramsey de um qubit no simulador do QDK
SystemVerilog multiplicador complexo Q1.15 sintetizável e banco de demonstração
GitHub Actions execução em lote, validações numéricas e artefatos para download
```

## Estrutura

```text
RealidadeQuantica/
├── .github/workflows/simulacoes.yml
├── abrir_laboratorio.m
├── fortran/free_wavepacket.f90
├── matlab/
│   ├── executar_pipeline.m
│   ├── friedmann_background.m
│   ├── run_su3_lattice.m
│   └── outros modelos MATLAB
├── qsharp/ramsey_interferometry.qs
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
