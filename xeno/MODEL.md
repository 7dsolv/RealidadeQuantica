# Modelo matemático X-01

Versão computacional inicial, 10 de novembro de 2026. Todas as constantes de material são **hipóteses de projeto**, sem ajuste a um experimento físico. O código usa MATLAB base, sem toolbox de aprendizado ou óptica.

## 1. Transporte e ligação

Cada um dos dois canais laterais tem profundidade \(L=60\,\mu m\), coordenada \(x\), concentração livre \(c\,[mol\,m^{-3}]\) e ocupação \(\theta\in[0,1]\). Os canais são independentes, sem transporte lateral entre eles.

\[
\partial_t c=D\partial_{xx}c-B\partial_t\theta,
\qquad
\partial_t\theta=k_{on}c(1-\theta)-k_{off}\theta.
\]

Aqui \(D=6\times10^{-11}\,m^2/s\), \(B=0.18\,mol/m^3\), \(k_{on}=1.6\,m^3/(mol\,s)\) e \(k_{off}=0.10\,s^{-1}\). Logo \(K_d=k_{off}/k_{on}=0.0625\,mol/m^3\), \(\theta_{eq}=c/(c+K_d)\), e a escala difusiva \(L^2/D=60\,s\). Nenhum desses valores é atribuído a reflectina ou a um receptor animal real.

Na entrada, \(c(0,t)=c_{ext}(t)\); no fundo, \(\partial_x c(L,t)=0\). O início tem \(c=\theta=0\). Os estímulos são dois pulsos \(s(t;a,b)=\sin^2[\pi(t-a)/(b-a)]\) no intervalo \((a,b)\), nulos fora dele. Com \(s_1=s(t;5,31)\), \(s_2=s(t;37,63)\) e \(c_{max}=0.35\,mol/m^3\):

\[
c_{ext,L}=c_{max}(0.95s_1+0.25s_2),\quad
c_{ext,R}=c_{max}(0.40s_1+0.90s_2).
\]

### Discretização conservativa

São usados 25 volumes centrados por canal. O fluxo interno é \(J_{i+1/2}=-D(c_{i+1}-c_i)/\Delta x\); na entrada, \(J_{1/2}=2D(c_{ext}-c_1)/\Delta x\). O passo explícito atualiza \(c_i\leftarrow c_i+h(J_{i-1/2}-J_{i+1/2})/\Delta x\). O limite \(Dh/\Delta x^2\leq0.24\) fica abaixo de \(1/3\), necessário para a positividade na célula de entrada.

Na reação local, \(m=c+B\theta\) fica fixo. Euler implícito resulta em \(ay^2-by+d=0\), onde \(y=\theta_{novo}\), \(a=hk_{on}B\), \(b=1+hk_{on}(m+B)+hk_{off}\), \(d=\theta_{antigo}+hk_{on}m\). A raiz estável é:

\[
y=\frac{2d}{b+\sqrt{b^2-4ad}},\qquad c_{novo}=m-By.
\]

A massa por área, somada sobre os dois canais, é \(M=\Delta x\sum(c+B\theta)\). O código compara \(M(t)-M(0)\) com o fluxo integrado nas fronteiras. A soma inclui as duas áreas unitárias de canal; não é a massa total de um dispositivo com geometria fabricada. O fracionamento transporte/reação é de primeira ordem no tempo, e o refinamento numérico é testado.

## 2. Mecânica e capacitância

Compressão positiva, homogênea e pequena. O modelo Kelvin–Voigt obedece \(\eta\dot\epsilon+E\epsilon=P(t)\), com \(E=180\,kPa\), \(\eta=45\,kPa\,s\) e \(\tau_m=0.25\,s\). Para pressão constante no subpasso:

\[
\epsilon_{novo}=P/E+(\epsilon_{antigo}-P/E)e^{-hE/\eta}.
\]

A pressão é \(P=P_{max}[0.70s(t;14,26)+0.95s(t;44,57)]\), \(P_{max}=12\,kPa\). O modelo rejeita pressão de equilíbrio acima de 10% de deformação. O capacitor ideal tem área fixa \(A=1\,mm^2\), espessura \(d_0=200\,\mu m\) e permissividade relativa 3:

\[
C=\frac{\epsilon_0\epsilon_r A}{d_0(1-\epsilon)}.
\]

Despreza efeito de Poisson na área, fringing, dependência da permissividade com deformação, histerese e dano.

## 3. Calibração sintética e percepção

Uma regressão ridge estima duas quantidades normalizadas: concentração equivalente de equilíbrio e pressão. A entrada contém a ocupação média dos canais \(\bar\theta\) e \(z=10(C/C_0-1)\):

\[
X=[1,\bar\theta,\bar\theta^2,\bar\theta^3,\bar\theta^4,z,z^2],
\qquad W=(X^TX+\lambda NP)^{-1}X^TY.
\]

O código usa resolução de sistema linear (`\`), sem calcular a inversa explicitamente. \(P\) não penaliza o intercepto, \(\lambda=10^{-5}\), e \(N=800\). O teste tem outras 300 amostras, seed 2901 em vez de 901. O ruído gaussiano é assumido: desvio 0.003 em ocupação e 0.001 na razão capacitiva. Estimativas usadas no controlador são limitadas a \([0,1]\).

A validação compara RMSE normalizado com o preditor constante da média do treino. **A calibração é de equilíbrio**: aplicada à trajetória transitória, a saída química representa concentração equivalente da ocupação média, não identifica o analito nem reconstrói a concentração externa instantânea. A ocupação lenta introduz atraso. Não há treinamento neural geral, base molecular ou aprendizado de outras IAs.

O contraste lateral é \(g=(\bar\theta_L-\bar\theta_R)/(\bar\theta_L+\bar\theta_R+10^{-4})\). Ele registra a diferença entre canais; não demonstra navegação biológica ou discriminação de espécies químicas.

## 4. Atuador e controle

O alvo é \(\lambda_* =490+85(0.65\hat c+0.35\hat P)\,nm\). A variável de atuação \(a\in[0,1]\) segue \(\tau_a\dot a+a=u\), \(\tau_a=0.8\,s\). O PI usa erro \(e=\lambda_*-\lambda_B\), antecipação \((\lambda_*-470)/100\), \(K_p=0.006\,nm^{-1}\) e \(K_i=0.010\,(nm\,s)^{-1}\). O integrador só avança se não aprofundar a saturação. A atuação é exata sob comando constante entre amostras de 0.2 s.

As leis ópticas abaixo são hipóteses constitutivas, sem alegar correspondência a uma membrana real. Com \(n_{H0}=1.65\), \(n_L=1.34\), \(d_{H0}=470/(4n_{H0})\,nm\), \(d_{L0}=470/(4n_L)\,nm\):

\[
n_H=n_{H0}-0.08a,\quad
d_H=d_{H0}(1+0.32a)(1-0.7\epsilon),\quad
d_L=d_{L0}(1+0.16a)(1-0.3\epsilon).
\]

O centro de Bragg aproximado \(\lambda_B=2(n_Hd_H+n_Ld_L)\) fecha a malha. Ele não é, em geral, exatamente o máximo do espectro de uma pilha finita. A comparação PI/antecipação usa os mesmos estímulos, ruído e modelo de calibração.

## 5. Óptica de camadas

Há seis períodos H/L, incidência normal, meios externos reais \(n_0=1\), \(n_s=1.5\), sem absorção nem espalhamento. Para cada camada \(j\):

\[
\delta_j=2\pi n_jd_j/\lambda,\qquad
M_j=\begin{pmatrix}\cos\delta_j&i\sin\delta_j/n_j\\i n_j\sin\delta_j&\cos\delta_j\end{pmatrix},\quad M=\prod_jM_j.
\]

\[
Q=n_0M_{11}+n_0n_sM_{12}+M_{21}+n_sM_{22},
\quad r=\frac{n_0M_{11}+n_0n_sM_{12}-M_{21}-n_sM_{22}}Q,
\quad t=\frac{2n_0}Q.
\]

As grandezas de potência são \(R=|r|^2\), \(T=(n_s/n_0)|t|^2\), com \(R+T=1\). O modelo avalia 380–780 nm em passos de 2 nm. Os testes verificam Fresnel, passividade e concordância com a implementação Fortran por multiplicação de matrizes complexas. Os índices são constantes em λ; dispersão e absorção reais exigem medidas e outro modelo.

## 6. Energia, sensibilidade e hardware

Um circuito ilustrativo usa \(V_{max}=3\,V\), \(R_{carga}=5\,k\Omega\), potência \(P_e=(V_{max}u)^2/R_{carga}\) e energia \(\int P_e dt\). Isso é uma carga assumida, sem representar o circuito eletroquímico de reflectina nem incluir toda a eletrônica.

Os 12 cenários variam \(D\) em ±30%, \(E\) em ±25% e \(n_{H0}\) em ±0.025. As escolhas uniformes têm seed fixa e não são distribuições inferidas de experimentos. A faixa exibida é apenas mínimo/máximo dos cenários amostrados.

O SystemVerilog calcula \(q=\lfloor(3q_c+q_t+2)/4\rfloor\) para entradas unsigned de 12 bits. A saída registrada tem um ciclo de latência, `valid` e reset síncrono. Essa fusão fixa não é a regressão nem o PI MATLAB, e não foi sintetizada ou medida em FPGA física. A bancada verifica aritmética, limites, monotonicidade, retenção e reset.
