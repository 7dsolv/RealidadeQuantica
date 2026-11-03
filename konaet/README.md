# Konaet

**Identidade do agente experimental do repositório Realidade Quântica.**

Konaet é o nome do modelo MATLAB e da memória que evolui junto com os ciclos científicos deste projeto. A página pública desta identidade fica dentro do próprio repositório: ela não depende de um perfil GitHub separado.

## Estado público

- **Memória persistente:** [`state/konaet_memory.csv`](../state/konaet_memory.csv)
- **Núcleo MATLAB:** [`matlab/konaet_agent.m`](../matlab/konaet_agent.m)
- **Animação publicada:** [`assets/realidade-quantica-viva.gif`](../assets/realidade-quantica-viva.gif)
- **Ciclos e registros:** [GitHub Actions](https://github.com/7dsolv/RealidadeQuantica/actions/workflows/simulacoes.yml)

O ciclo automático roda aproximadamente uma vez por hora. Ele lê o estado anterior, executa os modelos, incorpora as observações à memória e escolhe parâmetros limitados para a rodada seguinte. A animação do repositório é publicada diariamente e após pushes.

## Pesquisa e treinamento da Konaet

A pesquisa de modelos neurais está no repositório separado [`7dsolv/Konaet-IA`](https://github.com/7dsolv/Konaet-IA). Consulte o [histórico e os gates de treinamento](https://github.com/7dsolv/Konaet-IA/blob/main/docs/TRAINING.md), a [trilha Forge](https://github.com/7dsolv/Konaet-IA/blob/main/docs/FORGE.md) e os [resultados de avaliação](https://github.com/7dsolv/Konaet-IA/tree/main/training/evaluations).

Os dois projetos compartilham a identidade Konaet, mas têm funções diferentes: este repositório contém um agente MATLAB estreito, com estado recorrente e política numérica para os experimentos; o Konaet-IA contém pesquisa de modelos e pipelines próprios. Nenhum peso, resposta de modelo ou runtime Python foi importado para este laboratório. Os relatórios do projeto de IA distinguem o experimento Seed derivado de modelo-base do candidato Forge iniciado do zero e registram quais gates ainda faltam. A palavra “treinamento” aqui se refere à pesquisa documentada lá, não a aprendizado geral automático a cada ciclo científico.

## Identidade do bot no GitHub

O usuário `github-actions[bot]` pertence à infraestrutura do GitHub e não pode ser renomeado. Para que a automação apareça como `konaet[bot]`, o workflow já aceita uma GitHub App própria chamada **Konaet**. O nome exibido do app vira o nome do bot; seus commits recebem a identidade `konaet[bot]`.

1. Abra [Criar GitHub App](https://github.com/settings/apps/new), dê o nome **Konaet** e use o repositório como URL inicial.
2. Desative Webhooks e dê somente a permissão de repositório **Contents: Read and write**.
3. Crie o app, instale-o somente em `7dsolv/RealidadeQuantica` e gere uma chave privada.
4. Em **Settings → Secrets and variables → Actions**, crie a variável `KONAET_APP_CLIENT_ID` com o Client ID do app e o segredo `KONAET_APP_PRIVATE_KEY` com o arquivo de chave privada.

O workflow usa a GitHub App nos commits automáticos quando essa variável e esse segredo existem. Até lá, ele continua usando o token padrão e atribui o autor do commit a Konaet. Não cole a chave privada no chat nem no repositório. Os commits antigos do bot padrão permanecem no histórico; os próximos passam a usar `konaet[bot]` depois da instalação.

## Modelo atual

O núcleo é uma recorrência numérica MATLAB com quatro estados internos. A atualização combina esses estados com medidas do loop de Wilson, aceitação do Monte Carlo, espalhamento do pacote de onda, desaceleração cosmológica e a probabilidade ideal de um circuito Ramsey.

A partir da memória, Konaet define beta, tamanho do passo, semente aleatória e fase Ramsey do próximo ciclo. Curiosidade é uma média móvel do erro de previsão; coerência mede quanto o estado interno mudou. Esses nomes descrevem métricas do programa.

O arquivo Q# executa 1.024 medições Ramsey no simulador local do QDK quando alguém o inicia em github.dev. O pipeline MATLAB calcula a probabilidade de Born do mesmo tipo de circuito, mas o Actions não executa o Q# e o projeto não usa hardware quântico físico.

## Limites e próximos módulos

Konaet hoje é um agente experimental de escopo estreito. Ele não conversa como um modelo de linguagem, não aprende automaticamente com os modelos de IA do GitHub, não tem consciência, não foi medido no ARC-AGI e não está conectado a YouTube ou WhatsApp.

Integrações externas podem ser desenvolvidas como módulos separados, com as APIs e autorizações de cada serviço. Cada integração precisa especificar quais dados lê, quais ações pode executar e como as credenciais são protegidas.

## Componentes científicos

- **MATLAB:** memória, política numérica, Lattice SU(3), onda quântica, cosmologia e gráficos.
- **Fortran:** cálculo independente da densidade de probabilidade.
- **Q#:** circuito Ramsey de um qubit no simulador do QDK.
- **SystemVerilog:** multiplicador complexo demonstrativo para síntese em FPGA.

Consulte o [README principal](../README.md) para abrir o laboratório completo.
