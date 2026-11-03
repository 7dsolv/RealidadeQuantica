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

O usuário `github-actions[bot]` pertence à infraestrutura do GitHub e não pode ser renomeado. A identidade própria é uma GitHub App chamada **Konaet**. O slug confirmado pelo GitHub determina o login do bot; a Action exige o slug `konaet` e consulta o ID real de `konaet[bot]` antes de publicar.

O pacote reutilizável está em [`7dsolv/konaet-bot`](https://github.com/7dsolv/konaet-bot), com a [configuração na raiz](https://github.com/7dsolv/konaet-bot/blob/main/github-app.json), helper MATLAB e workflow de commit/push/pull request para aprovação humana.

1. Use o [cadastro oficial já preenchido](https://github.com/settings/apps/new?name=Konaet&description=Automacao%20Konaet%20com%20identidade%20propria%2C%20commits%20e%20propostas%20para%20revisao%20humana.&url=https%3A%2F%2Fgithub.com%2F7dsolv%2Fkonaet-bot&public=true&webhook_active=false&contents=write&pull_requests=write) na sessão da conta **7dsolv** e conclua **Create GitHub App**.
2. A configuração pública usa Webhooks desativados e permissões **Contents** e **Pull requests: Read and write**. O GitHub confirma a disponibilidade do nome ao enviar o formulário.
3. Instale a App nos repositórios `7dsolv/RealidadeQuantica` e `7dsolv/konaet-bot` e gere uma chave privada.
4. Em **Settings → Secrets and variables → Actions**, crie a variável `KONAET_APP_CLIENT_ID` com o Client ID do app e o segredo `KONAET_APP_PRIVATE_KEY` com o arquivo de chave privada.

Depois, execute **Verificar identidade real da App** no pacote `konaet-bot`. O workflow do laboratório publica somente com a App autenticada; enquanto o cadastro estiver pendente, os modelos executam e geram artifacts, e o job de publicação fica desativado. Não cole a chave privada no chat nem no repositório. Os commits antigos do bot padrão permanecem no histórico e podem continuar na lista de contribuidores; os próximos passam a usar a identidade da App depois da ativação.

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
