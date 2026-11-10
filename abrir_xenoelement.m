function fig = abrir_xenoelement(run_on_open)
%ABRIR_XENOELEMENT App MATLAB, sem HTML/JS; controles de hipoteses sinteticas.
if nargin<1, run_on_open=true; end
root=fileparts(mfilename('fullpath')); addpath(fullfile(root,'matlab','xeno'));
C.bg=[0.035 0.022 0.070]; C.panel=[0.070 0.054 0.115]; C.white=[0.94 0.93 0.98];
C.muted=[0.68 0.65 0.78]; C.violet=[0.74 0.41 1]; C.cyan=[0.30 0.91 0.86];
fig=uifigure('Name','KONAET | XENOELEMENT X-01','Color',C.bg,'Position',[70 50 1400 900]);
g=uigridlayout(fig,[3 2],'RowHeight',{68,'1x',38},'ColumnWidth',{250,'1x'},'BackgroundColor',C.bg);
head=uilabel(g,'Text','KONAET / XENOELEMENT X-01','FontSize',25,'FontWeight','bold','FontColor',C.white);
head.Layout.Row=1; head.Layout.Column=[1 2];
panel=uigridlayout(g,[10 1],'RowHeight',{30,22,36,22,36,22,36,44,62,'1x'},'BackgroundColor',C.panel);
panel.Layout.Row=2; panel.Layout.Column=1;
uilabel(panel,'Text','HIPÓTESES DE PROJETO','FontWeight','bold','FontColor',C.violet);
uilabel(panel,'Text','Difusividade / 10^{-11} m²/s','Interpreter','tex','FontColor',C.muted);
D=uieditfield(panel,'numeric','Limits',[2 12],'Value',6);
uilabel(panel,'Text','Módulo elástico / kPa','FontColor',C.muted);
E=uieditfield(panel,'numeric','Limits',[140 300],'Value',180);
uilabel(panel,'Text','Estímulo químico máximo / mol m^{-3}','Interpreter','tex','FontColor',C.muted);
chem=uieditfield(panel,'numeric','Limits',[0.05 0.6],'Value',0.35);
button=uibutton(panel,'Text','SIMULAR X-01','BackgroundColor',C.violet,'ButtonPushedFcn',@run_model);
status=uilabel(panel,'Text','Parâmetros hipotéticos. Calibração sintética, sem medidas físicas.','WordWrap','on','FontColor',C.muted);
uilabel(panel,'Text',['A cor do gráfico representa refletância, não uma previsão RGB do material. ' ...
    'O botão executa o modelo e atualiza as curvas; não acessa sensores reais.'],'WordWrap','on','FontColor',C.muted,'VerticalAlignment','top');
plots=uigridlayout(g,[2 2],'BackgroundColor',C.panel); plots.Layout.Row=2; plots.Layout.Column=2;
ax=gobjects(1,4);
for k=1:4
    ax(k)=uiaxes(plots,'Color',C.panel,'XColor',C.muted,'YColor',C.muted,'FontSize',11);
    ax(k).Layout.Row=ceil(k/2); ax(k).Layout.Column=mod(k-1,2)+1;
end
foot=uilabel(g,'Text','PROTÓTIPO COMPUTACIONAL / DADOS SINTÉTICOS / material não fabricado', ...
    'FontColor',C.muted,'FontSize',11); foot.Layout.Row=3; foot.Layout.Column=[1 2];
if run_on_open, run_model(); end

    function run_model(varargin)
        button.Enable='off'; status.Text='Calculando transporte, óptica e controle...'; drawnow;
        cleanup=onCleanup(@() enable_button()); %#ok<NASGU>
        try
            p=xeno_parameters(); p.diffusivity_m2_s=D.Value*1e-11;
            p.young_Pa=E.Value*1000; p.concentration_max_mol_m3=chem.Value;
            r=xeno_simulate(p);
            imagesc(ax(1),r.time_s,1e6*r.depth_m,squeeze(mean(r.concentration,2)));
            ax(1).YDir='reverse'; title(ax(1),'Concentração / mol m^{-3}','Color',C.white);
            xlabel(ax(1),'Tempo / s'); ylabel(ax(1),'Profundidade / µm'); colorbar(ax(1));
            imagesc(ax(2),r.time_s,p.wavelength_nm,r.reflectance); ax(2).YDir='normal';
            title(ax(2),'Refletância espectral','Color',C.white); xlabel(ax(2),'Tempo / s'); ylabel(ax(2),'λ / nm'); colorbar(ax(2));
            theta=squeeze(mean(r.occupancy,1)).';
            plot(ax(3),r.time_s,theta,'LineWidth',1.8);
            title(ax(3),'Ocupação dos dois receptores','Color',C.white); xlabel(ax(3),'Tempo / s'); ylim(ax(3),[0 1]);
            plot(ax(4),r.time_s,[r.target_nm r.bragg_nm],'LineWidth',1.8);
            title(ax(4),'Alvo e centro de Bragg / nm','Color',C.white); xlabel(ax(4),'Tempo / s');
            for j=1:4, grid(ax(j),'on'); end
            status.Text=sprintf('RMSE: %.2f nm\nMassa: %.1e mol/m²\nR+T−1: %.1e', ...
                r.metrics.tracking_rmse_nm,r.metrics.max_mass_error_mol_m2,r.metrics.optical_balance_error);
            fig.UserData=r;
        catch err
            status.Text=err.message;
            uialert(fig,err.message,'Modelo X-01');
        end
    end
    function enable_button()
        if isvalid(button), button.Enable='on'; end
    end
end
