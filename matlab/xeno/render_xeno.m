function manifest = render_xeno(output,r,sweep,evidence)
%RENDER_XENO Graficos cientificos calculados; animacao reproduz uma trajetoria.
C.bg=[0.035 0.022 0.070]; C.panel=[0.070 0.054 0.115];
C.white=[0.94 0.93 0.98]; C.muted=[0.67 0.66 0.77];
C.violet=[0.74 0.41 1]; C.cyan=[0.30 0.91 0.86]; C.amber=[1 0.73 0.39];
f=figure('Visible','off','Color',C.bg,'Position',[40 40 1460 950],'InvertHardcopy','off');
guard=onCleanup(@() close(f));
layout=tiledlayout(f,2,2,'TileSpacing','compact','Padding','loose');
layout.OuterPosition=[0.015 0.055 0.97 0.83];
heading=annotation(f,'textbox',[0.035 0.93 0.93 0.05],'String','KONAET / XENOELEMENT X-01', ...
    'FontName','DejaVu Sans','FontSize',24,'FontWeight','bold','Color',C.white,'EdgeColor','none','Margin',0);
annotation(f,'textbox',[0.035 0.895 0.93 0.03], ...
    'String','SIMULAÇÃO SINTÉTICA / 72 s de experimento numérico / material não fabricado', ...
    'FontSize',12,'Color',C.muted,'FontName','DejaVu Sans','EdgeColor','none','Margin',0);
ax1=nexttile(layout); style(ax1,C);
depth=1e6*r.depth_m; p=r.parameters;
field=squeeze(mean(r.concentration,2));
im1=imagesc(ax1,r.time_s,depth,field); set(ax1,'YDir','reverse');
clim(ax1,[0 p.concentration_max_mol_m3]); colormap(ax1,turbo(256));
cb=colorbar(ax1); cb.Label.String='Concentração / mol m^{-3}'; cb.Color=C.muted;
title(ax1,'01 / TRANSPORTE E ADSORÇÃO','Color',C.white,'FontSize',15);
xlabel(ax1,'Tempo / s'); ylabel(ax1,'Profundidade / µm');
ax2=nexttile(layout); style(ax2,C);
im2=imagesc(ax2,r.time_s,p.wavelength_nm,r.reflectance); set(ax2,'YDir','normal');
clim(ax2,[0 1]); colormap(ax2,parula(256));
cb=colorbar(ax2); cb.Label.String='Refletância R'; cb.Color=C.muted;
hold(ax2,'on'); band=plot(ax2,r.time_s,r.bragg_nm,'Color',C.white,'LineWidth',1.5);
title(ax2,'02 / ESPECTRO DA MEMBRANA','Color',C.white,'FontSize',15);
xlabel(ax2,'Tempo / s'); ylabel(ax2,'Comprimento de onda / nm');
ax3=nexttile(layout); style(ax3,C); hold(ax3,'on');
theta=squeeze(mean(r.occupancy,1)).';
hleft=plot(ax3,r.time_s,theta(:,1),'Color',C.cyan,'LineWidth',2);
hright=plot(ax3,r.time_s,theta(:,2),'Color',C.violet,'LineWidth',2);
hp=plot(ax3,r.time_s,r.pressure_Pa/p.pressure_max_Pa,'--','Color',C.amber,'LineWidth',1.5);
ylim(ax3,[0 1]); xlim(ax3,[0 p.duration_s]);
title(ax3,'03 / QUÍMICA E TOQUE','Color',C.white,'FontSize',15);
xlabel(ax3,'Tempo / s'); ylabel(ax3,'Ocupação / pressão normalizada');
legend(ax3,{'Receptor esquerdo','Receptor direito','Pressão / P_{max}'},'TextColor',C.white,'Color',C.panel,'Location','northwest','FontSize',9);
ax4=nexttile(layout); style(ax4,C); hold(ax4,'on');
envelope=fill(ax4,[r.time_s;flipud(r.time_s)],[sweep.minimum_nm;flipud(sweep.maximum_nm)],C.violet, ...
    'FaceAlpha',0.18,'EdgeColor','none');
htarget=plot(ax4,r.time_s,r.target_nm,'--','Color',C.amber,'LineWidth',1.5);
hbragg=plot(ax4,r.time_s,r.bragg_nm,'Color',C.cyan,'LineWidth',2);
xlim(ax4,[0 p.duration_s]); ylim(ax4,[460 590]);
title(ax4,'04 / CONTROLE E SENSIBILIDADE','Color',C.white,'FontSize',15);
xlabel(ax4,'Tempo / s'); ylabel(ax4,'Centro de Bragg estimado / nm');
legend(ax4,{'12 cenários hipotéticos','Alvo do controlador','Resposta PI'},'TextColor',C.white,'Color',C.panel,'Location','northwest','FontSize',9);
footer=sprintf('%d/%d testes | massa: %.1e mol/m² | R+T−1: %.1e | calibração: validação sintética separada', ...
    evidence.tests.passed,evidence.tests.total,r.metrics.max_mass_error_mol_m2,r.metrics.optical_balance_error);
annotation(f,'textbox',[0.035 0.008 0.93 0.03],'String',footer,'Color',C.muted, ...
    'FontName','DejaVu Sans','FontSize',10,'EdgeColor','none','Margin',0);
for ax=[ax1 ax2 ax3 ax4], style(ax,C); xticks(ax,0:12:p.duration_s); end
xlim(ax1,[0 p.duration_s]); ylim(ax1,[0 p.length_m*1e6]);
xlim(ax2,[0 p.duration_s]); yticks(ax1,0:15:60); yticks(ax2,400:80:720);
drawnow;
exportgraphics(f,fullfile(output,'x01-dashboard.png'),'Width',1900,'Height',1240, ...
    'Units','pixels','Padding','figure','PreserveAspectRatio','on','BackgroundColor',C.bg);
frame_file=fullfile(output,'x01-frame.png'); gif_file=fullfile(output,'x01-motion.gif');
frames=36; selected=round(linspace(1,numel(r.time_s),frames));
[palette,lookup]=palette_map();
for j=1:frames
    k=selected(j); remaining=k+1:numel(r.time_s);
    a=field; a(:,remaining)=NaN; set(im1,'CData',a);
    a=r.reflectance; a(:,remaining)=NaN; set(im2,'CData',a);
    set(band,'XData',r.time_s(1:k),'YData',r.bragg_nm(1:k));
    set(hleft,'XData',r.time_s(1:k),'YData',theta(1:k,1));
    set(hright,'XData',r.time_s(1:k),'YData',theta(1:k,2));
    set(hp,'XData',r.time_s(1:k),'YData',r.pressure_Pa(1:k)/p.pressure_max_Pa);
    set(htarget,'XData',r.time_s(1:k),'YData',r.target_nm(1:k));
    set(hbragg,'XData',r.time_s(1:k),'YData',r.bragg_nm(1:k));
    set(envelope,'XData',[r.time_s(1:k);flipud(r.time_s(1:k))], ...
        'YData',[sweep.minimum_nm(1:k);flipud(sweep.maximum_nm(1:k))]);
    heading.String=sprintf('KONAET / XENOELEMENT X-01   ·   t = %04.1f s',r.time_s(k));
    drawnow;
    exportgraphics(f,frame_file,'Width',1600,'Height',1040,'Units','pixels', ...
        'Padding','figure','PreserveAspectRatio','on','BackgroundColor',C.bg);
    rgb=imread(frame_file);
    red=lookup(double(rgb(:,:,1))+1); green=lookup(double(rgb(:,:,2))+1);
    blue=floor(double(rgb(:,:,3))/64);
    indexed=uint8(red*32+green*4+blue);
    if j==1
        imwrite(indexed,palette,gif_file,'gif','LoopCount',inf,'DelayTime',0.16);
    else
        imwrite(indexed,palette,gif_file,'gif','WriteMode','append','DelayTime',0.16);
    end
end
copyfile(frame_file,fullfile(output,'x01-motion-preview.png'));
delete(frame_file);
clear guard;
draw_architecture(output,C);
info=imfinfo(gif_file); file=dir(gif_file);
assert(numel(info)==frames && file.bytes<8*1024^2);
assert(all([info.Width]==info(1).Width) && all([info.Height]==info(1).Height));
manifest.revision=evidence.revision;
manifest.generator='matlab/xeno/render_xeno.m';
manifest.frames=frames; manifest.frame_delay_s=0.16;
manifest.simulation_duration_s=p.duration_s;
manifest.gif_bytes=file.bytes; manifest.live_telemetry=false;
manifest.data_origin='synthetic'; manifest.physical_material='NOT_FABRICATED';
fid=fopen(fullfile(output,'visual-manifest.json'),'w','n','UTF-8'); assert(fid>=0);
guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s\n',jsonencode(manifest,PrettyPrint=true));
end

function style(ax,C)
set(ax,'Color',C.panel,'XColor',C.muted,'YColor',C.muted,'GridColor',C.muted, ...
    'GridAlpha',0.12,'FontName','DejaVu Sans','FontSize',11,'Box','off');
grid(ax,'on');
end

function [map,lookup]=palette_map()
levels=[0 .035 .075 .14 .24 .40 .65 1];
index=(0:255).';
map=[reshape(levels(floor(index/32)+1),[],1), ...
    reshape(levels(mod(floor(index/4),8)+1),[],1),mod(index,4)/3];
[~,idx]=min(abs((0:255)'/255-levels),[],2); lookup=reshape(idx-1,256,1);
end

function draw_architecture(output,C)
f=figure('Visible','off','Color',C.bg,'Position',[40 40 1500 780]);
guard=onCleanup(@() close(f)); %#ok<NASGU>
ax=axes(f,'Position',[0 0 1 1],'XLim',[0 1500],'YLim',[0 780]); axis(ax,'off'); hold(ax,'on');
rectangle(ax,'Position',[1 1 1498 778],'FaceColor',C.bg,'EdgeColor',C.panel);
txt(ax,65,710,'KONAET / XENOELEMENT X-01',32,C.white);
txt(ax,65,659,'Uma cadeia calculável de estímulo, percepção e resposta.',19,C.muted);
xs=[65 550 1035];
titles={'ESTÍMULOS','PERCEPÇÃO','RESPOSTA'};
lines={{'Dois canais químicos','Difusão + adsorção','Conservação de massa'}, ...
    {'Pressão e capacitância','Regressão ridge calibrada','Teste sintético separado'}, ...
    {'Controle PI com limites','Lâminas ópticas + R/T','Consumo elétrico assumido'}};
colors={C.cyan,C.violet,C.amber};
for j=1:3
    x=xs(j); color=colors{j};
    rectangle(ax,'Position',[x 238 400 330],'Curvature',0.04,'FaceColor',C.panel,'EdgeColor',color,'LineWidth',1.2);
    txt(ax,x+24,520,sprintf('0%d / %s',j,titles{j}),20,color);
    for k=1:3, txt(ax,x+24,456-(k-1)*67,lines{j}{k},18,C.white); end
    if j<3
        plot(ax,[x+400 x+480],[390 390],'Color',color,'LineWidth',2);
        plot(ax,x+474,390,'>','Color',color,'MarkerFaceColor',color,'MarkerSize',7);
    end
end
plot(ax,[1235 1235 750 750],[238 180 180 238],'Color',C.violet,'LineWidth',1.2);
txt(ax,820,153,'realimentação óptica simulada',16,C.violet);
txt(ax,65,93,'MATLAB / física e gráficos     FORTRAN / óptica independente     SYSTEMVERILOG / fusão fixa',15,C.white);
txt(ax,65,48,'DADOS SINTÉTICOS · SEM MATERIAL FABRICADO · Q# NÃO É NECESSÁRIO PARA ESTE MODELO CLÁSSICO',12,C.muted);
exportgraphics(ax,fullfile(output,'x01-architecture.png'),'Resolution',115,'BackgroundColor',C.bg);
exportgraphics(ax,fullfile(output,'x01-architecture.svg'),'BackgroundColor',C.bg);
end

function txt(ax,x,y,value,size,color)
text(ax,x,y,value,'FontName','DejaVu Sans','FontSize',size,'FontWeight','bold', ...
    'Color',color,'Interpreter','none','VerticalAlignment','middle');
end
