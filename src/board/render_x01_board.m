function manifest = render_x01_board(b, folder)
%RENDER_X01_BOARD Montagem geometrica em mm, STL e animacao ilustrativa.
[v,f]=plate_mesh(b);
parts=struct('vertices',v,'faces',f,'color',[0.28 0.10 0.45]);
for k=1:numel(b.components)
    p=b.components(k); sz=p.body_mm; center=[p.xy_mm b.size_mm(3)+0.05+sz(3)/2];
    if strcmp(p.kind,'header'), center(2)=center(2)+mean(p.pads_mm(:,2)); col=[0.09 0.08 0.13];
    elseif strcmp(p.kind,'resistor'), col=[0.17 0.16 0.21]; else, col=[0.71 0.48 0.25]; end
    [v,f]=box(center,sz); parts(end+1)=struct('vertices',v,'faces',f,'color',col); %#ok<AGROW>
    for j=1:size(p.pads_mm,1)
        pos=p.xy_mm+p.pads_mm(j,:);
        if strcmp(p.kind,'header'), center=[pos b.size_mm(3)+2.2]; sz=[0.64 0.64 8];
        else, center=[pos b.size_mm(3)+0.28]; sz=[0.5 1.1 0.5]; end
        [v,f]=box(center,sz); parts(end+1)=struct('vertices',v,'faces',f,'color',[0.84 0.72 0.40]); %#ok<AGROW>
    end
end
stl=fullfile(folder,'x01-carrier.stl'); write_stl(parts,stl);
manifest.units='mm'; manifest.triangles=sum(arrayfun(@(p)size(p.faces,1),parts));
manifest.geometry='Board with four holes and generic component envelopes; not manufacturer-specific mechanical CAD';
manifest.stl_bytes=dir(stl).bytes;
assert(manifest.stl_bytes<10e6 && manifest.triangles>200);
fig=figure('Visible','off','Position',[20 20 1500 850],'Color',[0.035 0.025 0.065]);
guard=onCleanup(@() close(fig)); %#ok<NASGU>
ax=axes(fig,'Position',[0.02 0.14 0.69 0.72]); hold(ax,'on');
for k=1:numel(parts)
    p=parts(k); patch(ax,'Vertices',p.vertices,'Faces',p.faces,'FaceColor',p.color, ...
        'EdgeColor','none','FaceLighting','flat','AmbientStrength',0.65);
end
for k=1:numel(b.routes)
    r=b.routes(k); z=b.size_mm(3)+0.035;
    col=[0.83 0.61 0.23]; if strcmp(r.layer,'B.Cu'), z=-0.035; col=[0.36 0.51 0.61]; end
    plot3(ax,r.points_mm(:,1),r.points_mm(:,2),z*ones(size(r.points_mm,1),1),'-','Color',col,'LineWidth',2);
end
for k=1:numel(b.components)
    p=b.components(k);
    text(ax,p.xy_mm(1),p.xy_mm(2)-2.2,2,p.ref,'Color',[0.95 0.91 1], ...
        'FontSize',10,'FontWeight','bold','HorizontalAlignment','center');
end
text(ax,25,29,1.7,'KONAET  /  X-01','Color',[0.94 0.89 1],'FontSize',16,'FontWeight','bold','HorizontalAlignment','center');
axis(ax,'equal'); axis(ax,'off'); xlim(ax,[-3 53]); ylim(ax,[-4 39]); zlim(ax,[-2 12]);
view(ax,35,49); camlight(ax,'headlight'); material(ax,'dull');
annotation(fig,'textbox',[0.035 0.88 0.9 0.08],'String','KONAET  /  HARDWARE EM CODIGO', ...
    'Color',[0.97 0.94 1],'FontSize',27,'FontWeight','bold','EdgeColor','none');
annotation(fig,'textbox',[0.035 0.82 0.9 0.05],'String','X-01 SENSOR CARRIER   /   50 x 35 mm   /   2 camadas', ...
    'Color',[0.70 0.63 0.85],'FontSize',13,'EdgeColor','none');
labels={'01  AQUISICAO','J2: dois sinais analogicos externos','','02  FILTRAGEM RC', ...
    sprintf('R1/R2  %.6g kOhm',b.resistance_Ohm/1000),sprintf('C1/C2  %.6g uF',b.capacitance_F*1e6), ...
    sprintf('tau  %.3g ms  /  fc  %.3g Hz',b.resistance_Ohm*b.capacitance_F*1000,1/(2*pi*b.resistance_Ohm*b.capacitance_F)),'', ...
    '03  PROCESSAMENTO EXTERNO','J3: ADC + controlador separados','AnomalyNet: janelas de 32 amostras','','3D nativo no GitHub: girar e ampliar'};
annotation(fig,'textbox',[0.71 0.20 0.28 0.59],'String',labels,'Color',[0.88 0.83 0.97], ...
    'FontSize',14,'EdgeColor','none','FitBoxToText','off');
annotation(fig,'textbox',[0.035 0.035 0.94 0.055],'String', ...
    'PLACA CONCEITUAL  /  MCU E SENSORES EXTERNOS  /  NAO FABRICADA  /  GEOMETRIA GENERICA', ...
    'Color',[0.72 0.65 0.84],'FontSize',11,'EdgeColor','none');
exportgraphics(fig,fullfile(folder,'x01-board.png'),'Width',1800,'Height',1020,'Units','pixels','Padding','figure','BackgroundColor',fig.Color);
marker=plot3(ax,17,15.08,2.1,'o','MarkerSize',9,'MarkerFaceColor',[0.84 0.42 1],'MarkerEdgeColor','white');
gif=fullfile(folder,'x01-board-motion.gif'); frame=fullfile(folder,'animation-frame.png');
count=24;
for k=1:count
    phase=(k-1)/count;
    marker.XData=17+26*phase;
    view(ax,35+5*sin(phase*2*pi),49);
    exportgraphics(fig,frame,'Width',1200,'Height',680,'Units','pixels','Padding','figure','BackgroundColor',fig.Color);
    [pixels,map]=rgb2ind(imread(frame),128);
    if k==1, imwrite(pixels,map,gif,'gif','LoopCount',inf,'DelayTime',0.12);
    else, imwrite(pixels,map,gif,'gif','WriteMode','append','DelayTime',0.12); end
end
manifest.animation_frames=count; manifest.animation='Illustrated signal path, not live telemetry';
end

function [v,f]=plate_mesh(b)
% Constrained triangulation preserves the four circular mounting holes.
p=[0 0;b.size_mm(1) 0;b.size_mm(1:2);0 b.size_mm(2)]; edges=[1 2;2 3;3 4;4 1];
for k=1:size(b.holes_mm,1)
    n=24; a=-(0:n-1)'*2*pi/n; first=size(p,1)+1;
    p=[p;b.holes_mm(k,:)+b.hole_diameter_mm/2*[cos(a) sin(a)]]; %#ok<AGROW>
    ids=(first:first+n-1)'; edges=[edges;ids [ids(2:end);ids(1)]]; %#ok<AGROW>
end
tri=delaunayTriangulation(p,edges); top=tri.ConnectivityList(isInterior(tri),:);
p=tri.Points; n=size(p,1); v=[p zeros(n,1);p repmat(b.size_mm(3),n,1)];
f=[fliplr(top);top+n];
for k=1:size(edges,1)
    a=edges(k,1); z=edges(k,2);
    f=[f;a z z+n;a z+n a+n]; %#ok<AGROW>
end
end
function [v,f]=box(center,sz)
v=[-1 -1 -1;1 -1 -1;1 1 -1;-1 1 -1;-1 -1 1;1 -1 1;1 1 1;-1 1 1].*sz/2+center;
f=[1 3 2;1 4 3;5 6 7;5 7 8;1 2 6;1 6 5;2 3 7;2 7 6;3 4 8;3 8 7;4 1 5;4 5 8];
end
function write_stl(parts,path)
fid=fopen(path,'w'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'solid KONAET_X01_mm\n');
for k=1:numel(parts)
    p=parts(k);
    for j=1:size(p.faces,1)
        vertices=p.vertices(p.faces(j,:),:);
        normal=cross(vertices(2,:)-vertices(1,:),vertices(3,:)-vertices(1,:)); normal=normal/norm(normal);
        assert(all(isfinite(normal)));
        fprintf(fid,' facet normal %.8g %.8g %.8g\n  outer loop\n',normal);
        fprintf(fid,'   vertex %.8g %.8g %.8g\n',vertices.');
        fprintf(fid,'  endloop\n endfacet\n');
    end
end
fprintf(fid,'endsolid KONAET_X01_mm\n');
end
