function report = simulate_signal_chain(root,output)
%SIMULATE_SIGNAL_CHAIN RC -> ADC ideal 10 Hz -> janela 32 -> detector local.
b=x01_board(); data=load(fullfile(output,'tiny-model.mat'),'m','q');
t=(0:0.001:6.4)';
input=1.65+0.04*sin(2*pi*0.4*t)+0.12*sin(2*pi*35*t)+1.1*(t>=3.8 & t<4.5);
[filtered,energy]=rc_response(t,input,b.resistance_Ohm,b.capacitance_F,1.65);
sample_t=(0:0.1:6.3)'; sample_v=filtered(round(sample_t/0.001)+1);
temperature=50+20*(sample_v-1.65); % CONVERSAO ILUSTRATIVA, nao calibracao de sensor
windows=zeros(32,numel(temperature)-31);
for k=1:size(windows,2), windows(:,k)=temperature(k:k+31); end
[~,fp]=tiny_fp32(data.m,windows); [~,quant,status]=tiny_int8(data.q,windows);
assert(all(input>=0 & input<=b.supply_V));
assert(all(status.representable) && all(isfinite(temperature)));
assert(size(windows,2)==33 && max(abs(diff(sample_t)-0.1))<1e-14);
report.source_revision=getenv('GITHUB_SHA'); report.input='Synthetic voltage, ideal RC, ideal sampler';
report.voltage_temperature_mapping='T_C = 50 + 20 * (V - 1.65); illustrative, NOT_SENSOR_CALIBRATION';
report.sample_rate_Hz=10; report.window_samples=32; report.windows=size(windows,2);
report.fp32_int8_agreement=mean(fp==quant); report.int8_anomaly_windows=sum(quant==1);
report.invalid_windows=sum(~status.representable); report.actuation='NONE';
report.energy_balance_residual_J=max(abs(energy.balance_residual_J));
writetable(table(sample_t,sample_v,temperature,'VariableNames',{'time_s','sampled_V','illustrative_C'}),fullfile(output,'signal-samples.csv'));
decision_t=sample_t(32:end);
writetable(table(decision_t,fp.',quant.','VariableNames',{'last_sample_s','fp32_class','int8_class'}),fullfile(output,'signal-decisions.csv'));
fid=fopen(fullfile(output,'signal-chain.json'),'w','n','UTF-8'); assert(fid>=0);
guard=onCleanup(@() fclose(fid)); fprintf(fid,'%s\n',jsonencode(report,PrettyPrint=true)); clear guard;
fig=figure('Visible','off','Position',[20 20 1350 850],'Color','white'); guard=onCleanup(@() close(fig)); %#ok<NASGU>
tl=tiledlayout(fig,3,1,'Padding','loose','TileSpacing','loose');
ax=nexttile; plot(ax,t,input,'Color',[0.7 0.65 0.75]); hold(ax,'on');
plot(ax,t,filtered,'Color',[0.48 0.12 0.75],'LineWidth',1.8); grid(ax,'on');
ylabel(ax,'Tensao / V'); legend(ax,{'Entrada sintetica','Saida RC'},'Location','northwest');
ax2=nexttile; plot(ax2,sample_t,temperature,'o-','Color',[0.48 0.12 0.75],'MarkerSize',3); grid(ax2,'on');
ylabel(ax2,'Temperatura ilustrativa / C'); title(ax2,'Amostragem ideal 10 Hz / conversao V -> C hipotetica');
ax3=nexttile; stairs(ax3,decision_t,quant,'Color',[0.48 0.12 0.75],'LineWidth',2); hold(ax3,'on');
plot(ax3,decision_t,fp,'x','Color',[0.1 0.55 0.55]); grid(ax3,'on');
ylim(ax3,[-0.25 1.25]); yticks(ax3,[0 1]); yticklabels(ax3,{'Normal','Anomalia'});
xlabel(ax3,'Tempo do ultimo ponto da janela / s'); ylabel(ax3,'Decisao');
legend(ax3,{'INT8','FP32'},'Location','eastoutside');
title(tl,'KONAET / CADEIA COMPUTACIONAL OFFLINE / SEM ATUACAO FISICA');
set([ax ax2 ax3],'Color','white','XColor',[0.17 0.12 0.22],'YColor',[0.17 0.12 0.22],'FontSize',12);
exportgraphics(fig,fullfile(output,'signal-chain.png'),'Width',1600,'Height',1000,'Units','pixels','Padding','figure','BackgroundColor','white');
end
