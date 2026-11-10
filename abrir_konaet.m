function app = abrir_konaet(options)
%ABRIR_KONAET Painel MATLAB interativo: circuito causal e neuronios proprios.
arguments
    options.ModelFolder (1,:) char = ''
    options.Visible (1,:) char = 'on'
    options.AutoStart (1,1) logical = true
end
root=fileparts(mfilename('fullpath'));
addpath(fullfile(root,'matlab','integrated'),fullfile(root,'matlab','tiny'));
folder=options.ModelFolder; if isempty(folder), folder=fullfile(root,'assets','integrated','model'); end
assert(isfile(fullfile(folder,'model-card.json')),'Execute executar_konaet primeiro ou baixe os pesos publicados.');
[m,q]=konaet_load_model(folder); state=konaet_stream_init();
fig=uifigure('Name','KONAET / circuito e inteligencia local','Visible',options.Visible, ...
    'Color',[0.045 0.025 0.08],'Position',[50 50 1450 920]);
layout=uigridlayout(fig,[5 4]); layout.RowHeight={58,55,'1x','1x',50};
layout.ColumnWidth={'1x','1x','1x','1x'}; layout.BackgroundColor=fig.Color;
title=uilabel(layout,'Text','KONAET  /  CIRCUITO + NEURONIOS + MEMORIA', ...
    'FontSize',25,'FontWeight','bold','FontColor',[0.95 0.9 1]); title.Layout.Column=[1 4];
run=uibutton(layout,'Text','Pausar','Tag','konaet-run'); run.Layout.Row=2;run.Layout.Column=1;
reset=uibutton(layout,'Text','Reiniciar','Tag','konaet-reset');reset.Layout.Row=2;reset.Layout.Column=2;
step=uicheckbox(layout,'Text','Aplicar degrau +1,1 V','FontColor',[0.9 0.8 1],'Tag','konaet-step');step.Layout.Row=2;step.Layout.Column=3;
drop=uicheckbox(layout,'Text','Falha de leitura','FontColor',[0.9 0.8 1],'Tag','konaet-dropout');drop.Layout.Row=2;drop.Layout.Column=4;
ax=uiaxes(layout);ax.Layout.Row=3;ax.Layout.Column=[1 2];hold(ax,'on');
input_line=plot(ax,nan,nan,'Color',[0.60 0.52 0.72]); node_line=plot(ax,nan,nan,'Color',[0.82 0.4 1],'LineWidth',2);
title_axes(ax,'Tensao nos nos / RC + carga ADC');xlabel(ax,'Tempo / s');ylabel(ax,'V');ylim(ax,[0 3.3]);
legend(ax,{'Fonte sintetica','No ADC'},'TextColor',[0.9 0.85 1],'Color',fig.Color,'Location','northwest');
hx=uiaxes(layout);hx.Layout.Row=3;hx.Layout.Column=[3 4]; hidden=bar(hx,zeros(24,1),'FaceColor',[0.68 0.3 0.95]);
title_axes(hx,'24 neuronios ReLU / ativacao INT8 reescalada');xlabel(hx,'Neuronio');ylabel(hx,'Ativacao');
cx=uiaxes(layout);cx.Layout.Row=4;cx.Layout.Column=[1 2];hold(cx,'on');
current_line=plot(cx,nan,nan,'Color',[0.2 0.82 0.75],'LineWidth',1.5);
title_axes(cx,'Corrente da fonte');xlabel(cx,'Tempo / s');ylabel(cx,'uA');
dx=uiaxes(layout);dx.Layout.Row=4;dx.Layout.Column=[3 4]; decision_line=stairs(dx,nan,nan,'Color',[0.85 0.42 1],'LineWidth',2);
title_axes(dx,'Decisao / -1 invalido, 0 normal, 1 anomalia');xlabel(dx,'Tempo / s');ylabel(dx,'Classe');ylim(dx,[-1.2 1.2]);yticks(dx,[-1 0 1]);
status=uilabel(layout,'Text','Preparando janela de 32 amostras','FontColor',[0.87 0.78 0.98], ...
    'Tag','konaet-status','FontSize',14);status.Layout.Row=5;status.Layout.Column=[1 4];
loop=timer('ExecutionMode','fixedSpacing','Period',0.1,'BusyMode','drop','TimerFcn',@tick);
run.ButtonPushedFcn=@toggle;reset.ButtonPushedFcn=@restart;fig.CloseRequestFcn=@close_app;
fig.UserData=struct('step',@tick,'reset',@restart,'timer',loop);
app=fig;
if options.AutoStart, start(loop); else, run.Text='Iniciar'; end
    function tick(varargin)
        if ~isvalid(fig), return; end
        controls=struct('noise_V',0.04,'step_enabled',step.Value,'step_V',1.1,'dropout',drop.Value);
        [state,view]=konaet_stream_step(state,m,q,controls);
        range=max(1,numel(state.time)-299):numel(state.time);
        input_line.XData=state.time(range);input_line.YData=state.input(range);
        node_line.XData=state.time(range);node_line.YData=state.node(range);
        current_line.XData=state.time(range);current_line.YData=state.current(range);
        decision_line.XData=state.time(range);decision_line.YData=state.classes(range);
        hidden.YData=view.hidden;
        text=sprintf('t %.1f s | ADC %d | Carga %.3f uC | INT8 %d / FP32 %d | fonte simulada / sem atuacao fisica', ...
            state.time_s,view.code,view.charge_uC,view.class,view.fp32_class);
        if view.warmup, text=['Preenchendo janela | ' text]; end
        status.Text=text;fig.UserData.state=state;fig.UserData.view=view;
        drawnow limitrate;
    end
    function toggle(varargin)
        if strcmp(loop.Running,'on'), stop(loop);run.Text='Iniciar';
        else, start(loop);run.Text='Pausar';end
    end
    function restart(varargin)
        state=konaet_stream_init();tick();
    end
    function close_app(varargin)
        stop(loop);delete(loop);delete(fig);
    end
end
function title_axes(ax,text)
ax.Color=[0.075 0.045 0.115];ax.XColor=[0.82 0.75 0.9];ax.YColor=ax.XColor;
ax.GridColor=[0.4 0.3 0.5];ax.FontSize=12;grid(ax,'on');
title(ax,text,'Color',[0.96 0.9 1]);
end
