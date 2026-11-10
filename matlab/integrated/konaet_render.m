function manifest = konaet_render(root,output)
%KONAET_RENDER Imagens e GIF alimentados por valores do circuito e da rede.
data=load(fullfile(output,'benchmark.mat'),'m','q','result');
result=data.result; [m,q]=konaet_load_model(fullfile(output,'model'));
state=konaet_stream_init(91001); count=180; hidden=zeros(24,count); snapshots=cell(1,count);
for k=1:count
    controls=struct('noise_V',0.04,'step_V',1.1,'step_enabled',k>=46 && k<96,'dropout',k>=111 && k<=113);
    [state,view]=konaet_stream_step(state,m,q,controls);hidden(:,k)=view.hidden;snapshots{k}=view;
end
fault=find(state.time>=4.6 & state.time<9.6 & state.classes==1,1);
stream=struct('sample_rate_Hz',10,'samples',count,'source','synthetic voltage + nonideal RC + ideal quantized ADC', ...
    'event_start_s',4.6,'first_detected_s',[],'detection_delay_s',[], ...
    'normal_prefix_false_alarms',sum(state.classes(32:45)==1),'normal_prefix_decisions',14, ...
    'missing_reading_is_invalid',all(state.classes(111:113)==-1), ...
    'window_recovery','32 finite samples after the last missing read', ...
    'temperature_conversion','Illustrative mapping only; not physically calibrated');
if ~isempty(fault), stream.first_detected_s=state.time(fault);stream.detection_delay_s=state.time(fault)-4.6;end
konaet_write_json(fullfile(output,'stream-report.json'),stream);
writetable(table(state.time',state.input',state.node',state.current',state.charge',state.classes', ...
    'VariableNames',{'time_s','input_V','adc_node_V','current_uA','charge_uC','class'}),fullfile(output,'live-trace.csv'));
f=figure('Visible','off','Color',[0.035 0.02 0.06],'Position',[20 20 1600 1000]);
guard=onCleanup(@() close(f)); %#ok<NASGU>
tl=tiledlayout(f,2,2,'Padding','loose','TileSpacing','loose');
ax=nexttile;axis(ax,[0 10 0 7]);axis(ax,'off');hold(ax,'on');
plot(ax,[0.8 2.3],[4 4],'Color',[0.8 0.5 1],'LineWidth',3);
rectangle(ax,'Position',[2.3 3.7 2 0.6],'EdgeColor',[0.8 0.5 1],'LineWidth',2);
plot(ax,[4.3 8.8],[4 4],'Color',[0.8 0.5 1],'LineWidth',3);
plot(ax,[6.2 6.2],[4 2.8],'Color',[0.8 0.5 1],'LineWidth',3);
plot(ax,[5.6 6.8],[2.8 2.8],'Color',[0.8 0.5 1],'LineWidth',3);
plot(ax,[5.6 6.8],[2.55 2.55],'Color',[0.8 0.5 1],'LineWidth',3);
plot(ax,[6.2 6.2],[2.55 1.5],'Color',[0.8 0.5 1],'LineWidth',3);
text(ax,2.4,4.8,'10 kOhm + Rfonte','Color',[0.92 0.84 1],'FontSize',13);
text(ax,6.8,2.7,'4,7 uF + ESR + fuga','Color',[0.92 0.84 1],'FontSize',12);
source_text=text(ax,0.5,5.9,'','Color',[0.94 0.86 1],'FontSize',15,'FontWeight','bold');
node_text=text(ax,6.2,5.9,'','Color',[0.94 0.86 1],'FontSize',15,'FontWeight','bold');
charge_text=text(ax,0.5,0.65,'','Color',[0.3 0.88 0.77],'FontSize',14);
title(ax,'01 / CIRCUITO CALCULADO','Color',[0.98 0.92 1]);
hx=nexttile;bars=bar(hx,zeros(24,1),'FaceColor',[0.65 0.27 0.92]);
title(hx,'02 / 24 NEURONIOS KONAET','Color',[0.98 0.92 1]);xlabel(hx,'Neuronio');ylabel(hx,'ReLU INT8 reescalada');
sx=nexttile;hold(sx,'on');plot(sx,state.time,state.node,'Color',[0.35 0.25 0.45]);
line=plot(sx,nan,nan,'Color',[0.83 0.4 1],'LineWidth',2);position=xline(sx,0,'Color',[0.35 0.86 0.77]);
title(sx,'03 / ADC E DECISAO CAUSAL','Color',[0.98 0.92 1]);xlabel(sx,'Tempo / s');ylabel(sx,'No ADC / V');ylim(sx,[0 3.3]);xlim(sx,[0 18]);grid(sx,'on');
rx=nexttile;rounds=[result.experiments.round];reward=[result.experiments.reward];
plot(rx,rounds,reward,'o-','Color',[0.35 0.85 0.75],'LineWidth',2);grid(rx,'on');
xlabel(rx,'Experimento da busca UCB');ylabel(rx,'Utilidade no desenvolvimento');
title(rx,'04 / POLITICA APRENDE COM VALIDACAO','Color',[0.98 0.92 1]);
for a=[hx sx rx], a.Color=[0.07 0.04 0.11];a.XColor=[0.8 0.72 0.9];a.YColor=a.XColor;a.GridColor=[0.3 0.2 0.4];a.FontSize=12;end
heading=title(tl,'KONAET / DADOS DO CIRCUITO E DA REDE / EXECUCAO SIMULADA','Color',[0.98 0.93 1],'FontSize',22);
subtitle(tl,'Pesos proprios treinados do zero | PCB e RTL verificados separadamente | sem telemetria fisica','Color',[0.72 0.62 0.84]);
frame=fullfile(output,'live-frame.png');gif=fullfile(output,'konaet-live.gif');frames=48;
for k=1:frames
    j=round(1+(count-1)*(k-1)/(frames-1));value=snapshots{j};
    source_text.String=sprintf('Fonte %.3f V',value.input_V);node_text.String=sprintf('ADC %.3f V',value.node_V);
    charge_text.String=sprintf('I %.2f uA | Q %.3f uC | INT8 %d | FP32 %d',value.current_uA,value.charge_uC,value.class,value.fp32_class);
    bars.YData=hidden(:,j);line.XData=state.time(1:j);line.YData=state.node(1:j);position.Value=state.time(j);
    heading.String=sprintf('KONAET / t = %.1f s / CLASSE %d / SIMULACAO REPRODUZIVEL',state.time(j),value.class);
    exportgraphics(f,frame,'Width',1440,'Height',900,'Units','pixels','Padding','figure','BackgroundColor',f.Color);
    [pixels,map]=rgb2ind(imread(frame),128);
    if k==1,imwrite(pixels,map,gif,'gif','LoopCount',inf,'DelayTime',0.14);
    else,imwrite(pixels,map,gif,'gif','WriteMode','append','DelayTime',0.14);end
end
exportgraphics(f,fullfile(output,'konaet-live.png'),'Width',1800,'Height',1125,'Units','pixels','Padding','figure','BackgroundColor',f.Color);
clear guard;
render_benchmark(result,output);
manifest=struct('frames',frames,'frame_pixels',[1440 900],'gif_bytes',dir(gif).bytes, ...
    'animation_data','computed voltage, current, capacitor charge and hidden activations, not decorative particle motion', ...
    'source_revision',getenv('GITHUB_SHA'),'physical_live_telemetry',false);
info=imfinfo(gif);assert(numel(info)==frames && all([info.Width]==1440) && all([info.Height]==900));
assert(manifest.gif_bytes<8*1024^2);konaet_write_json(fullfile(output,'visual-report.json'),manifest);
end
function render_benchmark(result,output)
records=result.records; suites=unique({records.suite},'stable');models=unique({records.model},'stable');values=nan(numel(models),numel(suites));
for k=1:numel(records)
    a=find(strcmp(models,records(k).model));b=find(strcmp(suites,records(k).suite));values(a,b)=records(k).metrics.balanced_accuracy;
end
f=figure('Visible','off','Color','white','Position',[20 20 1500 850]);guard=onCleanup(@() close(f)); %#ok<NASGU>
ax=axes(f,'Position',[0.18 0.32 0.73 0.56]);imagesc(ax,values,[0 1]);
colormap(ax,interp1([0 0.5 1],[0.95 0.92 0.98;0.7 0.48 0.85;0.27 0.08 0.43],linspace(0,1,256)));colorbar(ax);
labels=strrep(strrep(suites,'.csv',''),'_',' ');
labels(1:3)={'Sintetico dificil','Sintetico simples','Ruido forte'};
xticks(ax,1:numel(suites));xticklabels(ax,labels);xtickangle(ax,25);
yticks(ax,1:numel(models));yticklabels(ax,models);ax.TickLabelInterpreter='none';ax.FontSize=12;
for a=1:numel(models),for b=1:numel(suites)
    color=[0.15 0.07 0.25];if values(a,b)>0.7,color=[1 1 1];end
    text(ax,b,a,sprintf('%.1f%%',100*values(a,b)),'Color',color,'FontSize',11,'FontWeight','bold','HorizontalAlignment','center');
end,end
title(ax,'KONAET / ACURACIA BALANCEADA / MESMO DOMINIO DE ENTRADA','FontSize',18);
annotation(f,'textbox',[0.18 0.05 0.73 0.1],'String', ...
    'Teste final separado da escolha. Abstencoes contam como erros. NAB: janelas temporais normalizadas; nao e o score oficial NAB nem um ensaio fisico KONAET.', ...
    'FontSize',12,'EdgeColor','none');
exportgraphics(f,fullfile(output,'benchmark.png'),'Width',2100,'Height',1190,'Units','pixels','Padding','figure','BackgroundColor','white');
end
