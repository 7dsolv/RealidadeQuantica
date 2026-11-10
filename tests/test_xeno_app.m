function report = test_xeno_app(output)
%TEST_XENO_APP Exercita calculo e controles reais da interface MATLAB.
if ~isfolder(output), mkdir(output); end
f=abrir_xenoelement(true);
guard=onCleanup(@() close(f)); %#ok<NASGU>
assert(isgraphics(f) && isstruct(f.UserData));
initial=f.UserData;
assert(isfield(initial,'bragg_nm') && numel(initial.time_s)==361);
drawnow;
exportapp(f,fullfile(output,'x01-app.png'));
picture=imfinfo(fullfile(output,'x01-app.png'));
assert(picture.Width>=1200 && picture.Height>=750);
D=findall(f,'Tag','xeno-diffusivity'); E=findall(f,'Tag','xeno-elasticity');
C=findall(f,'Tag','xeno-chemical'); button=findall(f,'Tag','xeno-run');
assert(isscalar(D) && isscalar(E) && isscalar(C) && isscalar(button));
D.Value=8; E.Value=220; C.Value=0.5;
callback=button.ButtonPushedFcn; callback(button,[]);
updated=f.UserData;
assert(abs(updated.parameters.diffusivity_m2_s-8e-11)<1e-24);
assert(updated.parameters.young_Pa==220e3 && updated.parameters.concentration_max_mol_m3==0.5);
assert(~isequal(updated.bragg_nm,initial.bragg_nm) && strcmp(button.Enable,'on'));
report.revision=getenv('GITHUB_SHA');
report.passed=4; report.total=4;
report.checks={'app construction and calculation','rendered app dimensions', ...
    'all three controls connected to calculation','recalculation updates output and restores button'};
fid=fopen(fullfile(output,'app-report.json'),'w','n','UTF-8'); assert(fid>=0);
file_guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s\n',jsonencode(report,PrettyPrint=true));
fprintf('X-01 app: 4/4 verificacoes aprovadas; controles recalcularam a trajetoria.\n');
end
