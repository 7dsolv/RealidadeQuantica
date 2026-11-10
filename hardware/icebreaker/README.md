# KONAET / alvo FPGA iCEBreaker

Alvo: **iCE40UP5K-SG48**, clock externo de **12 MHz**, reset no botão, saída normal/anomalia nos LEDs. SCL e SDA usam Pmod 1A, pinos FPGA 4 e 2; o mapeamento completo está em [`konaet.pcf`](konaet.pcf).

O workflow compila os testbenches Icarus, sintetiza com Yosys, roteia com nextpnr e empacota o bitstream com icepack. O [resumo publicado](../../assets/integrated/summary.json) identifica contagens, recursos e timing do pacote. O bitstream fica em [`assets/integrated/konaet-ice40.bin`](../../assets/integrated/konaet-ice40.bin).

A FPGA lê o ADC externo por I²C e coleta blocos de 32 amostras de AIN0. Uma classe inválida ou falha de I²C acende o indicador de falha/anomalia; esse comportamento é demonstrativo e não constitui proteção de segurança. O LED de normal só acende após resultado válido. O painel MATLAB usa janela deslizante, portanto a cadência de decisão não é a mesma dos blocos de hardware.

Os testes incluem os dois logits inteiros, vetores extremos/aleatórios, reset parcial, entrada inválida, ACK/NACK, leitura/escrita, sequência ADS1115, cadência e recuperação de erro. O conversor ADC é verificado em todos os 65.536 códigos. Os limites de acumuladores são exportados e conferidos antes de gerar ROMs.

O clock e o tempo de cálculo publicados são estimativas de timing e contagem RTL. Nenhuma placa foi programada ou medida nesta entrega. Conferir versão do host, alimentação 3,3 V e pinagem antes de um ensaio físico. O código não é apropriado para controle de aquecimento ou função de segurança sem um projeto e validação próprios.

Fontes: [iCEBreaker](https://github.com/icebreaker-fpga/icebreaker) · [pinagem de referência YosysHQ](https://github.com/YosysHQ/icestorm/blob/main/examples/icebreaker/icebreaker.pcf) · [ADS1115](https://www.ti.com/lit/ds/symlink/ads1115.pdf)
