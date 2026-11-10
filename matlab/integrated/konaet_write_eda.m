function report = konaet_write_eda(output)
%KONAET_WRITE_EDA Esquema e PCB da mesma netlist; bibliotecas locais proprias.
folder=fullfile(output,'hardware'); if ~isfolder(folder), mkdir(folder); end
b=konaet_acquisition_board(); library=fullfile(folder,'KONAET_X02.pretty');
if ~isfolder(library), mkdir(library); end
modelpath=fullfile(folder,'models'); if ~isfolder(modelpath), mkdir(modelpath); end
write_schematic(b,folder); write_pcb(b,folder,library,modelpath);
write_text(fullfile(folder,'fp-lib-table'),sprintf('(fp_lib_table (lib (name "KONAET_X02")(type "KiCad")(uri "${KIPRJMOD}/KONAET_X02.pretty")(options "")(descr "KONAET local footprints")))\n'));
write_text(fullfile(folder,'sym-lib-table'),sprintf('(sym_lib_table (lib (name "KONAET")(type "KiCad")(uri "${KIPRJMOD}/KONAET.kicad_sym")(options "")(descr "KONAET local symbols")))\n'));
project=struct('meta',struct('filename',[b.basename '.kicad_pro'],'version',1), ...
    'net_settings',struct('version',3,'classes',{{struct('name','Default','clearance',0.20,'track_width',0.20, ...
    'via_diameter',0.6,'via_drill',0.3,'diff_pair_width',0.20,'diff_pair_gap',0.2)}}));
konaet_write_json(fullfile(folder,[b.basename '.kicad_pro']),project);
konaet_write_json(fullfile(folder,'board-source.json'),b);
refs=string({b.parts.ref})'; values=string({b.parts.value})'; mpns=string({b.parts.mpn})';
writetable(table(refs,values,mpns,'VariableNames',{'Reference','Value','ManufacturerPartCandidate'}),fullfile(folder,'bom.csv'));
report=struct('source_revision',getenv('GITHUB_SHA'),'status',b.status,'components',numel(b.parts), ...
    'adc',b.adc,'host',b.host,'manufacturing','NOT_FABRICATED','power','3V3 externally regulated; no heater or mains connection', ...
    'part_selection','Candidate MPNs require procurement and footprint review; no availability or physical validation claim');
konaet_write_json(fullfile(folder,'eda-report.json'),report);
end

function write_schematic(b,folder)
fid=fopen(fullfile(folder,[b.basename '.kicad_sch']),'w','n','UTF-8'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'(kicad_sch (version 20250114) (generator "konaet_matlab") (uuid "%s") (paper "A4")\n',b.root_uuid);
fprintf(fid,' (lib_symbols\n');
for p=b.parts
    count=size(p.pads_mm,1); height=(count-1)*2.54;
    fprintf(fid,' (symbol "KONAET:%s" (pin_names (offset 1)) (in_bom yes) (on_board yes)\n',p.ref);
    property(fid,'Reference',p.ref,0,2.54); property(fid,'Value',p.value,0,-height-5.08);
    property(fid,'Footprint',['KONAET_X02:' p.ref],0,-height-7.62);
    fprintf(fid,' (symbol "%s_0_1" (rectangle (start -5.08 1.27) (end 12.7 %.3f) (stroke (width 0.254) (type default)) (fill (type background))))\n',p.ref,-height-1.27);
    fprintf(fid,' (symbol "%s_1_1"\n',p.ref);
    for j=1:count
        type='passive';
        if strcmp(p.ref,'J1'), type='power_out'; end
        if strcmp(p.kind,'ic')
            if any(j==[2 9 10]), type='bidirectional'; elseif any(j==[3 8]), type='power_in'; else, type='passive'; end
        end
        names={'ADDR','ALERT_RDY','GND','AIN0','AIN1','AIN2','AIN3','VDD','SDA','SCL'};
        name=num2str(j); if strcmp(p.kind,'ic'), name=names{j}; end
        fprintf(fid,' (pin %s line (at -7.62 %.3f 0) (length 2.54) (name "%s" (effects (font (size 1.0 1.0)))) (number "%d" (effects (font (size 1.0 1.0)))))\n',type,-(j-1)*2.54,name,j);
    end
    fprintf(fid,' ))\n');
end
fprintf(fid,' )\n');
for p=b.parts
    pos=p.schematic_xy_mm; height=(size(p.pads_mm,1)-1)*2.54;
    fprintf(fid,' (symbol (lib_id "KONAET:%s") (at %.3f %.3f 0) (unit 1) (in_bom yes) (on_board yes) (dnp no) (uuid "%s")\n',p.ref,pos,p.uuid);
    property(fid,'Reference',p.ref,pos(1),pos(2)-3.81); property(fid,'Value',p.value,pos(1),pos(2)+height+5.08);
    property(fid,'Footprint',['KONAET_X02:' p.ref],pos(1),pos(2)+height+7.62);
    for j=1:size(p.pads_mm,1), fprintf(fid,' (pin "%d" (uuid "%s"))\n',j,konaet_uuid([p.ref ' pin ' num2str(j)])); end
    fprintf(fid,' (instances (project "%s" (path "/%s" (reference "%s") (unit 1)))) )\n',b.basename,b.root_uuid,p.ref);
    for j=1:numel(p.nets)
        y=pos(2)+(j-1)*2.54; pin=[pos(1)-7.62 y]; endpoint=[pos(1)-15.24 y];
        if p.nets(j)==0 || startsWith(b.nets{p.nets(j)+1},'unconnected-')
            fprintf(fid,' (no_connect (at %.3f %.3f) (uuid "%s"))\n',pin,konaet_uuid([p.ref ' no connect ' num2str(j)]));
        else
            fprintf(fid,' (wire (pts (xy %.3f %.3f) (xy %.3f %.3f)) (stroke (width 0) (type default)) (uuid "%s"))\n',pin,endpoint,konaet_uuid([p.ref ' wire ' num2str(j)]));
            fprintf(fid,' (global_label "%s" (shape bidirectional) (at %.3f %.3f 0) (effects (font (size 0.85 0.85)) (justify left)) (uuid "%s"))\n',b.nets{p.nets(j)+1},endpoint,konaet_uuid([p.ref ' net ' num2str(j)]));
        end
    end
end
fprintf(fid,' (text "KONAET X02 / ADC ADS1115 + host FPGA externo / 3V3 / prototipo nao fabricado" (at 25 25 0) (effects (font (size 1.6 1.6)) (justify left)) (uuid "%s"))\n',konaet_uuid('x02 heading'));
fprintf(fid,' (sheet_instances (path "/" (page "1")))\n)\n');
clear guard;
% Reuse exactly the embedded symbols as the local library, avoiding drift.
text=fileread(fullfile(folder,[b.basename '.kicad_sch']));
first=regexp(text,'\(lib_symbols','once');depth=0;quoted=false;last=first;
for j=first:numel(text)
    if text(j)=='"', quoted=~quoted; end
    if ~quoted
        if text(j)=='(',depth=depth+1;elseif text(j)==')',depth=depth-1;end
    end
    if depth==0,last=j;break;end
end
body=text(first+numel('(lib_symbols'):last-1);body=strrep(body,'"KONAET:','"');
write_text(fullfile(folder,'KONAET.kicad_sym'),sprintf('(kicad_symbol_lib (version 20250114) (generator "konaet_matlab")\n%s\n)\n',body));
end

function property(fid,name,value,x,y)
hide=''; if strcmp(name,'Footprint'), hide=' hide'; end
fprintf(fid,' (property "%s" "%s" (at %.3f %.3f 0) (effects (font (size 1 1))%s))\n',name,value,x,y,hide);
end

function write_pcb(b,folder,library,modelpath)
fid=fopen(fullfile(folder,[b.basename '.kicad_pcb']),'w','n','UTF-8'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'(kicad_pcb (version 20240108) (generator "konaet_matlab") (general (thickness 1.6)) (paper "A4")\n');
fprintf(fid,' (layers (0 "F.Cu" signal) (1 "In1.Cu" signal) (2 "In2.Cu" signal) (31 "B.Cu" signal) (34 "B.Paste" user) (35 "F.Paste" user) (36 "B.SilkS" user) (37 "F.SilkS" user) (38 "B.Mask" user) (39 "F.Mask" user) (44 "Edge.Cuts" user) (47 "F.CrtYd" user) (49 "F.Fab" user)) (setup (pad_to_mask_clearance 0))\n');
for k=1:numel(b.nets), fprintf(fid,' (net %d "%s")\n',k-1,b.nets{k}); end
origin=[100 60]; corners=[0 0;b.size_mm(1) 0;b.size_mm(1:2);0 b.size_mm(2);0 0];
for j=1:4, fprintf(fid,' (gr_line (start %.3f %.3f) (end %.3f %.3f) (stroke (width 0.05) (type default)) (layer "Edge.Cuts"))\n',corners(j,:)+origin,corners(j+1,:)+origin); end
for p=b.parts
    content=footprint(p,b,origin,false);
    fprintf(fid,'%s',content);
    write_text(fullfile(library,[p.ref '.kicad_mod']),footprint(p,b,[0 0],true));
    write_model(p,fullfile(modelpath,[p.ref '.wrl']));
end
for j=1:size(b.holes_mm,1)
    fprintf(fid,' (footprint "KONAET_MOUNT" (layer "F.Cu") (at %.3f %.3f) (attr board_only exclude_from_pos_files exclude_from_bom) (pad "" np_thru_hole circle (at 0 0) (size 2.2 2.2) (drill 2.2) (layers "*.Cu" "*.Mask")))\n',b.holes_mm(j,:)+origin);
end
for r=b.routes
    for j=1:size(r.points_mm,1)-1
        fprintf(fid,' (segment (start %.3f %.3f) (end %.3f %.3f) (width %.3f) (layer "%s") (net %d))\n',r.points_mm(j,:)+origin,r.points_mm(j+1,:)+origin,r.width_mm,r.layer,r.net);
    end
end
for j=1:size(b.vias,1)
    fprintf(fid,' (via (at %.3f %.3f) (size 0.6) (drill 0.3) (layers "F.Cu" "B.Cu") (net %d))\n',b.vias(j,1:2)+origin,b.vias(j,3));
end
fprintf(fid,' (gr_text "KONAET X02 / 3V3 / ADC + FPGA HOST" (at 135 104) (layer "F.SilkS") (effects (font (size 0.9 0.9) (thickness 0.12))))\n)\n');
end

function content=footprint(p,b,origin,islib)
file=[tempname '.txt']; fid=fopen(file,'w'); assert(fid>=0);
if islib, name=p.ref; position=[0 0]; else, name=['KONAET_X02:' p.ref]; position=p.xy_mm+origin; end
fprintf(fid,' (footprint "%s" (layer "F.Cu") (at %.3f %.3f)\n',name,position);
if ~islib, fprintf(fid,' (path "/%s") (uuid "%s")\n',p.uuid,konaet_uuid(['pcb ' p.ref])); end
fprintf(fid,' (property "Reference" "%s" (at 0 -3 0) (layer "F.SilkS") (effects (font (size 0.8 0.8) (thickness 0.12))))\n',p.ref);
fprintf(fid,' (property "Value" "%s" (at 0 0 0) (layer "F.Fab") hide (effects (font (size 0.8 0.8) (thickness 0.12))))\n',p.value);
if p.drill_mm>0, fprintf(fid,' (attr through_hole)\n'); else, fprintf(fid,' (attr smd)\n'); end
for j=1:size(p.pads_mm,1)
    if p.drill_mm>0, kind='thru_hole'; layers='"*.Cu" "*.Mask"'; drill=sprintf('(drill %.3f)',p.drill_mm);
    else, kind='smd'; layers='"F.Cu" "F.Paste" "F.Mask"'; drill=''; end
    fprintf(fid,' (pad "%d" %s rect (at %.3f %.3f) (size %.3f %.3f) %s (layers %s)',j,kind,p.pads_mm(j,:),p.pad_size_mm,drill,layers);
    if ~islib && p.nets(j)>0, fprintf(fid,' (net %d "%s")',p.nets(j),b.nets{p.nets(j)+1}); end
    fprintf(fid,')\n');
end
center=[mean(p.pads_mm(:,1)) mean(p.pads_mm(:,2))];
lower=min(min(p.pads_mm-p.pad_size_mm/2,[],1),center-p.body_mm(1:2)/2)-0.25;
upper=max(max(p.pads_mm+p.pad_size_mm/2,[],1),center+p.body_mm(1:2)/2)+0.25;
fprintf(fid,' (fp_rect (start %.3f %.3f) (end %.3f %.3f) (stroke (width 0.05) (type default)) (fill none) (layer "F.CrtYd"))\n',lower,upper);
fprintf(fid,' (model "${KIPRJMOD}/models/%s.wrl" (offset (xyz 0 0 0)) (scale (xyz 1 1 1)) (rotate (xyz 0 0 0)))\n )\n',p.ref);
fclose(fid); content=fileread(file); % Temp diagnostic retained by OS cleanup.
end

function write_model(p,path)
fid=fopen(path,'w'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'#VRML V2.0 utf8\n# KONAET authored approximate part envelope, not vendor STEP\n');
center=[mean(p.pads_mm(:,1)) -mean(p.pads_mm(:,2)) p.body_mm(3)/2+0.05];
color=[0.18 0.14 0.22]; if strcmp(p.kind,'capacitor'), color=[0.62 0.40 0.22]; end
box(fid,center,p.body_mm,color);
for j=1:size(p.pads_mm,1)
    pos=p.pads_mm(j,:); pos(2)=-pos(2);
    if p.drill_mm>0, size_mm=[0.64 0.64 8]; z=2;
    else, size_mm=[p.pad_size_mm 0.2]; z=0.1; end
    box(fid,[pos z],size_mm,[0.7 0.7 0.72]);
end
end
function box(fid,center,sz,color)
fprintf(fid,'Transform { translation %.6f %.6f %.6f children [ Shape { appearance Appearance { material Material { diffuseColor %.3f %.3f %.3f } } geometry Box { size %.6f %.6f %.6f } } ] }\n',center/2.54,color,sz/2.54);
end
function write_text(path,text)
fid=fopen(path,'w','n','UTF-8'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',text);
end
