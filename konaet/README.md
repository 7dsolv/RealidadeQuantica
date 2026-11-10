# KONAET

**[App KONAET](https://github.com/apps/konaet)** · [Laboratório e animações](../README.md) · [Execuções](https://github.com/7dsolv/RealidadeQuantica/actions/workflows/simulacoes.yml)

**Identidade do agente experimental do repositório Realidade Quântica.**

Konaet é o nome do modelo MATLAB e da memória que evolui junto com os ciclos científicos deste projeto. A página pública desta identidade fica dentro do próprio repositório: ela não depende de um perfil GitHub separado.

A página da App é **[github.com/apps/konaet](https://github.com/apps/konaet)**. O endereço `github.com/konaet[bot]` retorna 404; ele não é o endereço da App. A App está cadastrada como privada, e esta página do repositório apresenta publicamente o agente e seus resultados.

## Estado público

- **Memória persistente:** [`state/konaet_memory.csv`](../state/konaet_memory.csv)
- **Núcleo MATLAB:** [`matlab/konaet_agent.m`](../matlab/konaet_agent.m)
- **Animação publicada:** [`assets/realidade-quantica-viva.gif`](../assets/realidade-quantica-viva.gif)
- **Ciclos e registros:** [GitHub Actions](https://github.com/7dsolv/RealidadeQuantica/actions/workflows/simulacoes.yml)

O ciclo automático roda aproximadamente uma vez por hora. Ele lê o estado anterior, executa os modelos, incorpora as observações à memória e escolhe parâmetros limitados para a rodada seguinte. A memória é persistida e a animação do repositório é publicada diariamente e após pushes. Os commits dos resultados têm autoria atribuída à conta `konaet[bot]`.

## Pesquisa e treinamento da Konaet

A pesquisa de modelos neurais está no repositório separado [`7dsolv/Konaet-IA`](https://github.com/7dsolv/Konaet-IA). Consulte o [histórico e os gates de treinamento](https://github.com/7dsolv/Konaet-IA/blob/main/docs/TRAINING.md), a [trilha Forge](https://github.com/7dsolv/Konaet-IA/blob/main/docs/FORGE.md) e os [resultados de avaliação](https://github.com/7dsolv/Konaet-IA/tree/main/training/evaluations).

Os dois projetos compartilham a identidade Konaet, mas têm funções diferentes: este repositório contém um agente MATLAB estreito, com estado recorrente e política numérica para os experimentos; o Konaet-IA contém pesquisa de modelos e pipelines próprios. Não foram importados pesos ou respostas do Konaet-IA para este laboratório. A extensão [offline com PCB 3D](../offline/README.md) incorpora separadamente os pesos AnomalyNet de Eoin Jordan, sob Apache-2.0, e os executa em MATLAB/Fortran. Não há runtime Python no projeto. Os relatórios do projeto de IA distinguem o experimento Seed derivado de modelo-base do candidato Forge iniciado do zero e registram quais gates ainda faltam. “Treinamento” não significa aprendizado geral automático a cada ciclo científico.

## Identidade do bot no GitHub

O usuário `github-actions[bot]` pertence à infraestrutura do GitHub e não pode ser renomeado. A App própria **KONAET** já está registrada, e sua conta `konaet[bot]` tem ID `352182232`. O workflow confere login, ID e tipo `Bot` na API antes de atribuir a autoria dos resultados a essa conta.

Na configuração atual, os commits usam `konaet[bot]` como autor e `github-actions[bot]` como committer, pois o envio usa o token do GitHub Actions. Atribuição de autoria é metadado do Git; não comprova autenticação da App ou assinatura criptográfica. O modo usado aparece no resumo de cada execução. As contribuições antigas continuam no histórico e podem permanecer na lista de contribuidores.

O pacote reutilizável está em [`7dsolv/konaet-bot`](https://github.com/7dsolv/konaet-bot), com a [configuração na raiz](https://github.com/7dsolv/konaet-bot/blob/main/github-app.json), helper MATLAB e workflow de commit/push/pull request para aprovação humana.

Para ativar também a autenticação pela App:

1. Na [App KONAET](https://github.com/settings/apps/konaet), mantenha Webhooks desativados e as permissões **Contents** e **Pull requests: Read and write**.
2. Instale-a nos repositórios `7dsolv/RealidadeQuantica` e `7dsolv/konaet-bot` e gere uma chave privada.
3. Em **Settings → Secrets and variables → Actions**, configure primeiro o segredo `KONAET_APP_PRIVATE_KEY` e depois a variável `KONAET_APP_CLIENT_ID` com o Client ID da App.

Depois, execute **Verificar identidade real da App** no pacote `konaet-bot`. Com as credenciais configuradas, autor, committer e autenticação passam a usar a App KONAET. Uma falha nessa autenticação interrompe a publicação, sem trocar silenciosamente para o token do Actions. A chave privada pertence aos Secrets, não ao código do repositório.

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
