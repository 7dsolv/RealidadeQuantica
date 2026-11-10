# Fontes, autoria e antecedentes

Levantamento inicial em **10 de novembro de 2026**. A busca cobre exemplos diretamente relacionados, não uma pesquisa exaustiva de literatura, de famílias de patentes ou de marcas. Não conclui liberdade de operação nem patenteabilidade.

## Fontes primárias consultadas

| Fonte | Relação com o X-01 | O que o X-01 não reproduz |
| --- | --- | --- |
| DeMartini, Krogstad e Morse, 2013, [PNAS, doi:10.1073/pnas.1217260110](https://pmc.ncbi.nlm.nih.gov/articles/PMC3574947/) | Iridescência regulada por fluxo de água em estruturas biológicas; motivação para camadas ópticas ajustáveis. | Não usa suas micrografias, dados ou uma parametrização de reflectina medida. |
| Chou et al., 2015, [Nature Communications, doi:10.1038/ncomms9011](https://pmc.ncbi.nlm.nih.gov/articles/PMC4560774/) | Demonstra pele eletrônica extensível com mudança de cor controlada por toque. É um antecedente direto da ideia geral. | A pilha óptica idealizada do X-01 não é o dispositivo eletrocrômico desse artigo. |
| van Giesen et al., 2020, [Cell, doi:10.1016/j.cell.2020.09.008](https://pmc.ncbi.nlm.nih.gov/articles/pmid/33125889/) | Base molecular de percepção química por contato em polvos. | Não copia receptores, sequências, constantes cinéticas ou comportamento biológico. |
| Kang et al., 2023, [Nature, doi:10.1038/s41586-023-05808-z](https://www.nature.com/articles/s41586-023-05808-z) | Especialização de receptores quimiotáteis em polvos e lulas. | O analito abstrato e os dois canais de Langmuir não são uma reprodução desses receptores. |
| Lin et al., 2025, [Advanced Materials, doi:10.1002/adma.202411005](https://escholarship.org/uc/item/9hv4t776) | Controle eletroquímico de propriedades ópticas de filmes de reflectina. | O circuito resistivo e a atuação escalar do X-01 não modelam sua eletroquímica. |
| Byrnes, [Multilayer optical calculations, arXiv:1603.02720v5](https://arxiv.org/abs/1603.02720v5) | Formalismo e convenções de óptica de camadas. | Nenhum código do pacote Python associado foi incorporado. As implementações MATLAB e Fortran foram escritas neste projeto. |

A analogia com a língua bifurcada é **amostragem espacial de sinais**, não uma alegação de que a língua sozinha reconhece moléculas. O X-01 não depende de uma proteína de serpente específica; não apresenta uma lista molecular como se ela estivesse completa.

## Documentos de patentes encontrados

| Documento | Tema relevante | Implicação para o projeto |
| --- | --- | --- |
| [US10035175B2 — Dynamic infrared-reflective materials based on reflectin films](https://patents.google.com/patent/US10035175B2/en) | Filmes de reflectina com resposta óptica infravermelha ajustável. | Materiais ópticos bioinspirados já têm antecedentes patenteados. O X-01 não afirma direitos sobre reflectina, filmes ou processos. |
| [US20240319024A1 — Self-Powered Smart Skins for Multimodal Static and Dynamic Tactile Perception](https://patents.google.com/patent/US20240319024A1/en) | Sensoriamento tátil multimodal e processamento assistido por aprendizado. | Combinar sensores e processamento estatístico também não basta para provar novidade. |

Esses números identificam documentos publicados. Não foi realizada análise jurídica das reivindicações, validade, vigência, famílias ou cobertura territorial. A existência ou ausência de um resultado nesta busca não resolve esses pontos.

## O que foi criado aqui

- Código MATLAB da cadeia acoplada, experimentos sintéticos, calibração, controlador, app, testes e composição dos gráficos.
- Implementação Fortran independente da matriz óptica e módulo demonstrativo SystemVerilog.
- Documentação de equações, unidades, condições de contorno, hipóteses, validação e procedência dos resultados.

Os métodos científicos empregados — Fick, Langmuir, Kelvin–Voigt, matrizes de transferência, regressão ridge e controle PI — são métodos conhecidos e são identificados como tais. Implementar métodos conhecidos com código próprio não transforma o método ou o conceito em invenção inédita.

O núcleo físico X-01 não incorpora código, imagens, tabelas de dados ou pesos dos artigos citados; eles são citados pela contribuição científica, sem reutilizar suas figuras. A extensão [offline](../offline/README.md), adicionada separadamente, incorpora pesos AnomalyNet de Eoin Jordan e seu vetor numérico de referência, com [procedência e licença Apache-2.0](../models/anomalynet/NOTICE.txt). O texto anexado pelo proprietário foi tratado como contexto de projeto, não como evidência de novidade ou fonte de parâmetros medidos.

O nome **XENOELEMENT** é um rótulo de projeto; não foi feita busca completa de disponibilidade de marca. A licença do repositório continua sendo decisão do proprietário, conforme o README principal. Nenhuma licença de software foi inferida a partir das licenças dos artigos.

## Antes de alegar invenção ou lançar um produto

Definir uma implementação física concreta; pesquisar reivindicações e famílias por território; comparar experimentalmente com dispositivos anteriores; documentar autoria e procedência de cada componente; verificar disponibilidade do nome e licenças dos materiais/arquivos eventualmente usados. A versão atual demonstra apenas uma implementação computacional testável.
