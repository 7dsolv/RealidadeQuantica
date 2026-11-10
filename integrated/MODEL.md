# Contrato numérico e de avaliação

## Aprendizagem

As janelas têm 32 entradas, normalizadas por `x = (T − 50)/20`. O modelo computa `h = max(W1 x + b1, 0)` e `z = W2 h + b2`; a decisão é o índice do maior logit, com empate em normal. Treinamento minimiza entropia cruzada com regularização L2 dos pesos. Adam mantém momentos de primeira e segunda ordem; clipping limita a norma do gradiente a 5. Não há transferência de pesos de terceiros.

O teste valida numericamente o gradiente com diferenças centrais, a repetibilidade do RNG local, a redução da perda e a igualdade do modelo exportado/recarregado. O arquivo Fortran independente lê os tensores FP32 e compara os logits. Esses testes verificam implementação, não garantem generalização.

Na quantização simétrica, pesos e ativações usam INT8 e bias/MAC usam INT32. As escalas são calculadas no conjunto separado de calibração. Requantização da primeira camada usa multiplicador inteiro Q30 e saturação em 127. Exportamos ROMs e limites superiores conservadores dos acumuladores. O testbench inclui vetores aleatórios inteiros e extremos; entradas `−128` são sinalizadas inválidas. O payload contém 920 bytes de pesos/biases, além das escalas e metadados.

## Métricas

`Recall = TP/(TP+FN)`, `FPR = FP/(FP+TN+abstenções normais)`. A acurácia balanceada é a média de recall e fração dos normais resolvidos corretamente. Uma abstenção nunca conta como acerto ou normal; por isso cobertura também é publicada. Limiares das regras são o percentil empírico 99 em janelas normais de calibração.

Os rótulos sintéticos descrevem injeções conhecidas; as menores injeções podem ficar escondidas pelo ruído. O teste difícil é congelado antes da seleção e inclui amplitudes menores, variação de base e ruído. As séries NAB usam o rótulo do ponto final de cada janela e passo de oito amostras. Esse protocolo difere da pontuação oficial NAB, que considera detecção temporal e penalidades próprias.

## Circuito não ideal

Sejam `R = Rfiltro + Rfonte`, `r = ESR`, `Ra = carga ADC`, `Rl = fuga`, `v` a tensão no capacitor ideal e `u` a fonte. Defina `g = 1/R`, `e = 1/r`, `d = 1/Ra`, `l = 1/Rl`, `a = g/(g+e+d)` e `b = e/(g+e+d)`. A tensão no nó ADC é `vo = a u + b v` e:

\[
\frac{dv}{dt}=\frac{ea}{C}u-\frac{e(1-b)+l}{C}v.
\]

O estado é integrado exatamente para `u` constante em cada intervalo. Integramos trabalho da fonte, calor em `R`, ESR, carga ADC e fuga; comparamos sua soma com `Δ(Cv²/2)`. O Monte Carlo usa distribuições hipotéticas explícitas, sem estimar probabilidades de falha de um produto real.

## ADC e execução

O ADS1115 é configurado em single-shot, entrada AIN0 versus GND, faixa ±4,096 V, 128 SPS e endereço `0x48`. A interface espera 10 ms após a configuração antes de ler dois bytes. A cadência é um contador independente de 10 Hz. O modelo digital não testa efeitos analógicos da placa ou limites de sincronização externos.

O código de conversão usa `V = code × 125 µV` e a hipótese `T = 50 + 20(V − 1,65)`. Portanto `q = round((code − 13200) × 127 / 16000)`. A divisão sequencial conserva o arredondamento simétrico e é comparada exaustivamente contra a fórmula inteira para todo o domínio de 16 bits. Fora de ±127, a saída é `−128`, que invalida a janela. Falha I²C descarta um bloco incompleto e mantém o indicador inválido até uma nova decisão válida.
