function write_x01_kicad(b, folder)
%WRITE_X01_KICAD PCB nativa; footprints e modelos genericos locais.
if ~isfolder(folder), mkdir(folder); end
models=fullfile(folder,'models'); if ~isfolder(models), mkdir(models); end
fid=fopen(fullfile(folder,'x01-carrier.kicad_pcb'),'w','n','UTF-8'); assert(fid>=0);
guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'(kicad_pcb (version 20240108) (generator "konaet_matlab")\n');
fprintf(fid,' (general (thickness %.3f)) (paper "A4")\n',b.size_mm(3));
fprintf(fid,' (layers (0 "F.Cu" signal) (31 "B.Cu" signal) (34 "B.Paste" user) (35 "F.Paste" user)\n');
fprintf(fid,' (36 "B.SilkS" user) (37 "F.SilkS" user) (38 "B.Mask" user) (39 "F.Mask" user)\n');
fprintf(fid,' (44 "Edge.Cuts" user) (46 "B.CrtYd" user) (47 "F.CrtYd" user) (48 "B.Fab" user) (49 "F.Fab" user))\n');
fprintf(fid,' (setup (pad_to_mask_clearance 0))\n');
for k=1:numel(b.nets), fprintf(fid,' (net %d "%s")\n',k-1,b.nets{k}); end
origin=[100 60];
corners=[0 0;b.size_mm(1) 0;b.size_mm(1:2);0 b.size_mm(2);0 0];
for k=1:4
    a=corners(k,:)+origin; z=corners(k+1,:)+origin;
    fprintf(fid,' (gr_line (start %.4f %.4f) (end %.4f %.4f) (stroke (width 0.05) (type default)) (layer "Edge.Cuts"))\n',a,z);
end
fprintf(fid,' (gr_text "KONAET X-01 / CONCEPT" (at 125 89) (layer "F.SilkS") (effects (font (size 0.85 0.85) (thickness 0.15))))\n');
for k=1:numel(b.components)
    p=b.components(k); xy=p.xy_mm+origin;
    fprintf(fid,' (footprint "Konaet_%s" (layer "F.Cu") (at %.4f %.4f)\n',p.ref,xy);
    fprintf(fid,'  (property "Reference" "%s" (at 0 -2.0 0) (layer "F.SilkS") (effects (font (size 0.8 0.8) (thickness 0.12))))\n',p.ref);
    fprintf(fid,'  (property "Value" "%s" (at 0 0 0) (layer "F.Fab") hide (effects (font (size 0.8 0.8) (thickness 0.12))))\n',p.value);
    isheader=strcmp(p.kind,'header');
    if isheader, fprintf(fid,'  (attr through_hole)\n'); else, fprintf(fid,'  (attr smd)\n'); end
    for j=1:size(p.pads_mm,1)
        n=p.net_codes(j); pos=p.pads_mm(j,:);
        if isheader
            shape='circle'; if j==1, shape='rect'; end
            fprintf(fid,'  (pad "%d" thru_hole %s (at %.4f %.4f) (size 1.7 1.7) (drill 1.0) (layers "*.Cu" "*.Mask") (net %d "%s"))\n',j,shape,pos,n,b.nets{n+1});
        else
            sz=[0.95 1.45]; if abs(diff(p.pads_mm(:,2)))>0, sz=fliplr(sz); end
            fprintf(fid,'  (pad "%d" smd rect (at %.4f %.4f) (size %.4f %.4f) (layers "F.Cu" "F.Paste" "F.Mask") (net %d "%s"))\n',j,pos,sz,n,b.nets{n+1});
        end
    end
    % Courtyard conservador dos envelopes genericos, com margem de 0,25 mm.
    lower=min(p.pads_mm,[],1)-[0.85 0.85]; upper=max(p.pads_mm,[],1)+[0.85 0.85];
    body_center=[0 0]; if isheader, body_center(2)=mean(p.pads_mm(:,2)); end
    lower=min(lower,body_center-p.body_mm(1:2)/2)-0.25;
    upper=max(upper,body_center+p.body_mm(1:2)/2)+0.25;
    fprintf(fid,'  (fp_rect (start %.4f %.4f) (end %.4f %.4f) (stroke (width 0.05) (type default)) (fill none) (layer "F.CrtYd"))\n',lower,upper);
    % Generic shapes, authored here; no stock footprint/3D library required.
    fprintf(fid,'  (model "${KIPRJMOD}/models/%s.wrl" (offset (xyz 0 0 0)) (scale (xyz 1 1 1)) (rotate (xyz 0 0 0)))\n )\n',p.ref);
    write_model(p,fullfile(models,[p.ref '.wrl']));
end
for k=1:size(b.holes_mm,1)
    fprintf(fid,' (footprint "Konaet_Mount" (layer "F.Cu") (at %.4f %.4f) (attr board_only exclude_from_pos_files exclude_from_bom)\n',b.holes_mm(k,:)+origin);
    fprintf(fid,'  (pad "" np_thru_hole circle (at 0 0) (size 2.2 2.2) (drill %.2f) (layers "*.Cu" "*.Mask")))\n',b.hole_diameter_mm);
end
for k=1:numel(b.routes)
    r=b.routes(k);
    for j=1:size(r.points_mm,1)-1
        fprintf(fid,' (segment (start %.4f %.4f) (end %.4f %.4f) (width %.3f) (layer "%s") (net %d))\n',r.points_mm(j,:)+origin,r.points_mm(j+1,:)+origin,r.width_mm,r.layer,r.net);
    end
end
for k=1:size(b.vias_mm,1)
    fprintf(fid,' (via (at %.4f %.4f) (size 0.8) (drill 0.4) (layers "F.Cu" "B.Cu") (net 2))\n',b.vias_mm(k,:)+origin);
end
fprintf(fid,')\n');
end

function write_model(p,path)
fid=fopen(path,'w'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'#VRML V2.0 utf8\n# KONAET generic envelope, dimensions in KiCad legacy 0.1 inch units\n');
sz=p.body_mm; center=[0 0 sz(3)/2+0.05];
if strcmp(p.kind,'header'), center(2)=mean(p.pads_mm(:,2)); color=[0.06 0.045 0.09];
elseif strcmp(p.kind,'resistor'), color=[0.13 0.12 0.17]; else, color=[0.65 0.42 0.22]; end
vrml_box(fid,center,sz,color);
for j=1:size(p.pads_mm,1)
    if strcmp(p.kind,'header')
        vrml_box(fid,[p.pads_mm(j,:) 2.2],[0.64 0.64 8],[0.85 0.72 0.30]);
    else
        vrml_box(fid,[p.pads_mm(j,:) 0.28],[0.5 1.1 0.5],[0.75 0.76 0.79]);
    end
end
end
function vrml_box(fid,center,sz,color)
% KiCad VRML uses 0.1 inch units; Y is opposite the PCB editor axis.
center(2)=-center(2);
fprintf(fid,'Transform { translation %.6f %.6f %.6f children [ Shape { appearance Appearance { material Material { diffuseColor %.4f %.4f %.4f } } geometry Box { size %.6f %.6f %.6f } } ] }\n',center/2.54,color,sz/2.54);
end
