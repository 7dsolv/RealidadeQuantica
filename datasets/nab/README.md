# Duas séries do Numenta Anomaly Benchmark

Origem: [numenta/NAB](https://github.com/numenta/NAB), revisão fixada em [`source.json`](source.json). A [licença e aviso de copyright fornecidos pelo repositório](LICENSE.txt) acompanham os arquivos. Os CSVs, intervalos completos e descrição original são cópias sem alteração; os SHA-256 são verificados no MATLAB antes do uso.

`selected-labels.json` apenas seleciona os intervalos das duas séries, preservando seus valores. `machine_temperature_system_failure.csv` é uma medição de sensor em equipamento industrial; `ambient_temperature_system_failure.csv` é uma medição de ambiente de escritório, conforme a [descrição original](UPSTREAM-DATA.md).

O adaptador ordena timestamps e agrega valores de horários duplicados pela mediana, registrando quantidades no relatório. A normalização afim usa somente o primeiro 20% da série, fora dos intervalos rotulados. O teste usa o período seguinte com uma margem de 31 amostras. Cada janela tem 32 valores, avança oito amostras e recebe o rótulo do último ponto. Não treinamos a rede nem escolhemos hiperparâmetros usando esses dados.

Este uso testa deslocamento de domínio. O período de amostragem original é preservado e não é 10 Hz; não rebatizamos os valores originais como Celsius físicos após normalizar. A avaliação **não usa a pontuação oficial NAB**, e janelas sobrepostas não são casos independentes. Consulte os [resultados e limites](../../integrated/RESULTS.md).
