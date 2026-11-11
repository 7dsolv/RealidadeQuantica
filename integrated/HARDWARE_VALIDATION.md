# X02: protocolo de ensaio físico

**Estado: NOT_RUN.** Nenhuma placa foi fabricada ou medida nesta implementação. Este documento fixa o plano de aceitação; não é um relatório de resultados.

## Configuração rastreável

Registre revisão do esquema/PCB/BOM, revisão da placa iCEBreaker, bitstream e hashes do modelo, lote dos componentes, instrumentos e suas calibrações. A primeira bancada usa apenas alimentação isolada de 3,3 V e fonte de sinais limitada ao domínio do ADC. Não há ligação a aquecedores, rede elétrica ou equipamento de segurança.

Confira encapsulamentos, footprints, montagem, tensão máxima e pinagem contra os datasheets dos componentes efetivamente comprados. As geometrias 3D do repositório são envelopes ilustrativos.

## Aquisição e resposta

| Ensaio | Registro exigido | Critério proposto |
| --- | --- | --- |
| Alimentação e conexão | Corrente de repouso, tensões, curto e sequência de reset | Dentro das especificações dos componentes reais |
| RC e ADC | Entrada medida por instrumento e código ADC em vários pontos, incluindo bordas | Erro dentro do orçamento calculado com tolerâncias e calibração do sensor escolhido |
| I²C | Captura dos bytes, endereços, ACK/NACK e recuperação | Igual ao protocolo documentado; falha invalida o resultado |
| Janela e inferência | 32 códigos capturados, INT8 resultante, dois logits e LEDs | Igual à referência inteira para o mesmo bloco e modelo |
| Falha e retomada | Sensor desconectado, NACK e reinício | Sem apresentar leitura inválida como normal; novo bloco completo antes da retomada |
| Latência e energia | Analisador lógico e corrente durante aquisição/cálculo | Informar distribuição e incerteza; não substituir por estimativas do roteador |
| Operação prolongada | Amostras, descartes, resets, temperatura e horas de funcionamento | Publicar todos os incidentes e o limite estatístico que a duração permite |

A aquisição nominal é de 10 Hz em blocos de 32 amostras: aproximadamente 3,2 s por bloco. Os 2.472 ciclos de inferência são contados depois da última entrada; não representam a latência completa.

A conversão ilustrativa de tensão para temperatura precisa ser substituída pela calibração de um sensor real. Compare o detector e as referências com dados de dispositivos separados do treinamento, sem consultar rótulos do teste para ajustar limiares.

## Relatório a publicar

Inclua dados brutos, scripts MATLAB de análise, incertezas, fotos da montagem, identificação dos instrumentos, diferenças entre hardware e simulação e todas as falhas. Campos sem medição permanecem `NOT_MEASURED`. A aprovação do CI não aprova automaticamente este protocolo.

## Conferir uma captura real

`konaet_validate_bench` recebe CSVs medidos e metadados, confere o bundle do
modelo, a sequência das 32 amostras, o quantizador, os dois logits INT32 e a
classe. Calcula separadamente o tempo após a última entrada e desde a primeira
amostra. As colunas são:

- `samples.csv`: `window_id,sample_index,adc_code,quantized_int8,sample_time_s`.
- `decisions.csv`: `window_id,logit0_int32,logit1_int32,class_code,decision_time_s,energy_mJ`.
- `metadata.json`: `schema_version: 1`, `physical_capture: true`, `board_serial`,
  `pcb_revision`, `instrument_id`, `calibration_reference`, `operator`,
  `capture_utc` e `model_bundle_sha256`.

```matlab
addpath('matlab/integrated','matlab/tiny');
konaet_validate_bench('samples.csv','decisions.csv','metadata.json', ...
    'assets/integrated/model','artifacts/bench');
```

O estado `CAPTURE_COMPARED` verifica a consistência dos arquivos fornecidos.
Não autentica o instrumento nem comprova que um arquivo veio de hardware;
essas evidências precisam de revisão independente. Esse comparador cobre
janelas válidas. Falhas de sensor, calibração, segurança e durabilidade continuam
no protocolo completo acima. O CI usa apenas uma fixture sintética claramente
identificada e mantém `hardware_qualified: false`.
