function report = build_x01_board(root, output)
%BUILD_X01_BOARD Gera PCB, STL, BOM, circuito e evidencias a partir da src.
if ~isfolder(output), mkdir(output); end
addpath(fullfile(root,'src','circuit'));
b=x01_board(); write_json(fullfile(output,'board-source.json'),b);
write_x01_kicad(b,output);
refs=string({b.components.ref}).'; values=string({b.components.value}).';
kinds=string({b.components.kind}).'; xy=vertcat(b.components.xy_mm);
writetable(table(refs,values,kinds,xy(:,1),xy(:,2),'VariableNames', ...
    {'Reference','Value','Kind','X_mm','Y_mm'}),fullfile(output,'bom.csv'));
write_circuit(b,fullfile(output,'x01-rc.cir'));
write_diagram(b,fullfile(output,'x01-circuit.svg'));
report.revision=getenv('GITHUB_SHA'); report.status=b.status;
report.nominal_tau_s=b.resistance_Ohm*b.capacitance_F;
report.nominal_cutoff_Hz=1/(2*pi*report.nominal_tau_s);
report.tolerance_tau_s=report.nominal_tau_s* ...
    [(1-b.resistor_tolerance)*(1-b.capacitor_tolerance), ...
    (1+b.resistor_tolerance)*(1+b.capacitor_tolerance)];
report.tolerances='Illustrative 1% R, 20% C; no specific purchased part or DC-bias model';
tests={@step_solution,@energy_conservation,@passivity,@dc_gain,@invalid_parameters,@source_consistency};
report.tests=struct('name',{},'passed',{},'message',{}); report.passed=0; report.failed=0;
for k=1:numel(tests)
    ok=true; message=''; try, tests{k}(); catch err, ok=false; message=err.message; end
    report.tests(k)=struct('name',func2str(tests{k}),'passed',ok,'message',message);
    report.passed=report.passed+ok; report.failed=report.failed+~ok;
    fprintf('%s %s %s\n',string(ok),func2str(tests{k}),message);
end
t=(0:0.001:1.4)'; input=1.4+0.65*(t>=0.3)+0.16*sin(2*pi*35*t);
[v,energy]=rc_response(t,input,b.resistance_Ohm,b.capacitance_F,1.4);
report.energy_balance_residual_J=max(abs(energy.balance_residual_J));
writetable(table(t,input,v,'VariableNames',{'time_s','input_V','filtered_V'}),fullfile(output,'rc-response.csv'));
render_rc(t,input,v,report,output);
report.mesh=render_x01_board(b,output);
report.native_kicad='Checked separately by kicad-cli; see kicad-report.json';
report.total=numel(tests); write_json(fullfile(output,'board-report.json'),report);
assert(report.failed==0,'Placa: %d testes falharam.',report.failed);

    function step_solution()
        tau=report.nominal_tau_s; t=[0;tau/7;tau;3*tau;10*tau];
        z=rc_response(t,ones(size(t))*3.3,b.resistance_Ohm,b.capacitance_F,0);
        assert(max(abs(z-3.3*(1-exp(-t/tau))))<3e-15);
    end
    function energy_conservation()
        t=(0:0.0007:0.9)'; u=[1+sin(17*t) 2+cos(11*t)];
        [~,e]=rc_response(t,u,b.resistance_Ohm,b.capacitance_F,[0 1]);
        assert(max(abs(e.balance_residual_J))<2e-18);
    end
    function passivity()
        t=[0;0.004;0.1;1];
        [z,e]=rc_response(t,zeros(size(t)),b.resistance_Ohm,b.capacitance_F,3.3);
        assert(all(diff(z)<0) && e.resistor_heat_J>=0);
        assert(abs(e.resistor_heat_J+e.capacitor_change_J)<1e-18);
    end
    function dc_gain()
        t=[0;0.01;0.1]; z=rc_response(t,ones(size(t))*1.7,b.resistance_Ohm,b.capacitance_F,1.7);
        assert(all(z==1.7));
    end
    function invalid_parameters()
        rejected=false; try, rc_response([0;1],[0;1],-10,1e-6); catch, rejected=true; end
        assert(rejected);
        rejected=false; try, rc_response([0;0],[0;1],10,1e-6); catch, rejected=true; end
        assert(rejected);
    end
    function source_consistency()
        assert(numel(unique({b.components.ref}))==8);
        assert(sum(strcmp({b.components.kind},'resistor'))==2);
        assert(sum(strcmp({b.components.kind},'capacitor'))==3);
        assert(isequal(b.components(strcmp(refs,'R1')).net_codes,[3 5]));
        for p=b.components
            assert(all(p.net_codes>0 & p.net_codes<numel(b.nets)));
            assert(all(p.xy_mm>0 & p.xy_mm<b.size_mm(1:2)));
        end
    end
end

function render_rc(t,u,v,report,folder)
f=figure('Visible','off','Position',[20 20 1300 700],'Color','white');
guard=onCleanup(@() close(f)); %#ok<NASGU>
tl=tiledlayout(f,2,1,'Padding','loose','TileSpacing','loose');
ax=nexttile; plot(ax,t,u,'Color',[0.65 0.60 0.71]); hold(ax,'on');
plot(ax,t,v,'Color',[0.47 0.12 0.73],'LineWidth',2); grid(ax,'on');
xlabel(ax,'Tempo / s'); ylabel(ax,'Tensao / V'); legend(ax,{'Entrada sintetica','Saida RC'},'Location','southeast');
title(ax,'KONAET / dois canais RC identicos, um canal ilustrado');
freq=logspace(-1,3,500); gain=1./sqrt(1+(2*pi*freq*report.nominal_tau_s).^2);
ax2=nexttile; semilogx(ax2,freq,20*log10(gain),'Color',[0.47 0.12 0.73],'LineWidth',2);
grid(ax2,'on'); xline(ax2,report.nominal_cutoff_Hz,'--');
xlabel(ax2,'Frequencia / Hz'); ylabel(ax2,'Ganho / dB');
title(ax2,sprintf('R = 10 kOhm | C = 4,7 uF | tau = 47 ms | fc = %.3f Hz',report.nominal_cutoff_Hz));
title(tl,'MODELO IDEAL / sem carga ADC, ESR, fuga, tolerancia dinamica ou parasitas');
set([ax ax2],'Color','white','XColor',[0.16 0.12 0.22],'YColor',[0.16 0.12 0.22],'FontSize',12);
exportgraphics(f,fullfile(folder,'rc-response.png'),'Width',1600,'Height',860,'Units','pixels','Padding','figure','BackgroundColor','white');
end
function write_circuit(b,path)
fid=fopen(path,'w'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'* KONAET X-01 ideal passive RC channels; SPICE netlist, not firmware\n');
fprintf(fid,'VLEFT RAW_L 0 PULSE(0 3.3 0 1u 1u 0.5 1)\nVRIGHT RAW_R 0 DC 1.65\n');
fprintf(fid,'R1 RAW_L ADC_L %.12g\nR2 RAW_R ADC_R %.12g\n',b.resistance_Ohm,b.resistance_Ohm);
fprintf(fid,'C1 ADC_L 0 %.12g\nC2 ADC_R 0 %.12g\n',b.capacitance_F,b.capacitance_F);
fprintf(fid,'VSUPPLY VCC 0 DC 3.3\nC3 VCC 0 100n\n.tran 1m 1\n.end\n');
end
function write_diagram(b,path)
fid=fopen(path,'w','n','UTF-8'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'<svg xmlns="http://www.w3.org/2000/svg" width="1500" height="650" viewBox="0 0 1500 650">\n');
fprintf(fid,'<rect width="1500" height="650" fill="#0c0718"/><g font-family="DejaVu Sans,sans-serif" fill="#f5edff">\n');
fprintf(fid,'<text x="60" y="65" font-size="30" font-weight="bold">KONAET / COMPONENTES COMO FONTE</text>\n');
fprintf(fid,'<text x="60" y="105" font-size="18" fill="#b3a1cb">3,3 V / fonte e conversor ADC externos / circuito ideal de dois canais</text>\n');
for k=1:2
    y=195+(k-1)*185;
    fprintf(fid,'<g stroke="#c78aff" stroke-width="3" fill="none"><path d="M110 %d H310 M450 %d H1070"/><rect x="310" y="%d" width="140" height="44"/>\n',y,y,y-22);
    fprintf(fid,'<path d="M700 %d V%d M665 %d H735 M665 %d H735 M700 %d V%d M675 %d H725 M683 %d H717 M692 %d H708"/></g>\n',y,y+52,y+52,y+65,y+65,y+116,y+116,y+126,y+136);
    fprintf(fid,'<circle cx="700" cy="%d" r="5" fill="#e5caff"/>\n',y);
    suffix='L'; if k==2, suffix='R'; end
    fprintf(fid,'<text x="100" y="%d" font-size="19">RAW_%s</text><text x="315" y="%d" font-size="19">R%d / 10 kOhm</text>\n',y-35,suffix,y-38,k);
    fprintf(fid,'<text x="760" y="%d" font-size="19">C%d / 4,7 uF</text><text x="1080" y="%d" font-size="19">ADC_%s</text>\n',y+65,k,y+6,suffix);
end
fprintf(fid,'<text x="60" y="585" font-size="20">tau = R C = %.0f ms / fc = 1 / (2 pi R C) = %.3f Hz</text>\n',1000*b.resistance_Ohm*b.capacitance_F,1/(2*pi*b.resistance_Ohm*b.capacitance_F));
fprintf(fid,'<text x="60" y="620" font-size="16" fill="#b3a1cb">Conceito de placa passiva. Nao inclui sensores ativos, ADC, MCU, protecao de entrada ou controle termico.</text></g></svg>\n');
end
function write_json(path,value)
fid=fopen(path,'w','n','UTF-8'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s\n',jsonencode(value,PrettyPrint=true));
end
