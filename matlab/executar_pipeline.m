function executar_pipeline(require_fortran)
%EXECUTAR_PIPELINE Run the scientific models without opening a desktop UI.
%   This entry point is intended for GitHub Actions and MATLAB batch mode.

if nargin < 1
    require_fortran = false;
end
if ~islogical(require_fortran) || ~isscalar(require_fortran)
    error('require_fortran precisa ser um valor logico escalar.');
end

project_dir = fileparts(fileparts(mfilename('fullpath')));
matlab_dir = fullfile(project_dir, 'matlab');
artifact_dir = fullfile(project_dir, 'artifacts');
addpath(matlab_dir);
if ~exist(artifact_dir, 'dir')
    mkdir(artifact_dir);
end

beta = 5.5;
measurement_count = 80;
step_size = 0.35;
seed = 7;
[wilson_history, plaquettes, acceptance, links, lattice] = ...
    run_su3_lattice(beta, measurement_count, step_size, seed, []);
[gauge_difference, plaquettes_before, plaquettes_after] = ...
    validate_su3_gauge(links, lattice);

unitarity_error = 0;
determinant_error = 0;
for site = 1:lattice.n_sites
    for direction = 1:lattice.n_directions
        link = links(:, :, site, direction);
        unitarity_error = max(unitarity_error, ...
            norm(link' * link - eye(3), 'fro'));
        determinant_error = max(determinant_error, abs(det(link) - 1));
    end
end

sigma_0 = 0.7;
k_0 = 1.2;
time = 0.8;
x = linspace(-10, 10, 1001);
[psi, probability, sigma_t] = free_wavepacket(x, sigma_0, k_0, time);
probability_integral = trapz(x, probability);
cosmology = friedmann_background(0.315, 0.00009, 0.68491, 1400);

if gauge_difference > 1e-10
    error('Invariancia de gauge excedeu a tolerancia: %.3e.', gauge_difference);
end
if max(unitarity_error, determinant_error) > 1e-10
    error('Restricao SU(3) excedeu a tolerancia: unitario %.3e, det %.3e.', ...
        unitarity_error, determinant_error);
end
if abs(probability_integral - 1) > 1e-6
    error('Normalizacao da onda excedeu a tolerancia: integral %.12f.', ...
        probability_integral);
end

writematrix([(1:numel(wilson_history)).', wilson_history], ...
    fullfile(artifact_dir, 'wilson_history.csv'));
writematrix(plaquettes, fullfile(artifact_dir, 'wilson_plaquettes.csv'));
writematrix([plaquettes_before, plaquettes_after], ...
    fullfile(artifact_dir, 'gauge_invariance.csv'));
writematrix([unitarity_error, determinant_error], ...
    fullfile(artifact_dir, 'su3_constraints.csv'));
writematrix([x(:), real(psi(:)), probability(:)], ...
    fullfile(artifact_dir, 'wave_matlab.csv'));
writematrix([cosmology.dimensionless_time, cosmology.scale_factor, ...
    cosmology.expansion_rate, cosmology.deceleration], ...
    fullfile(artifact_dir, 'cosmology_friedmann.csv'));

fortran_path = fullfile(artifact_dir, 'wave_fortran.dat');
maximum_fortran_error = NaN;
fortran_data = [];
if ~isfile(fortran_path) && require_fortran
    error('Saida Fortran obrigatoria nao encontrada em %s.', fortran_path);
elseif isfile(fortran_path)
    fortran_data = readmatrix(fortran_path);
    [~, matlab_probability] = free_wavepacket(fortran_data(:, 1).', ...
        sigma_0, k_0, time);
    maximum_fortran_error = max(abs(fortran_data(:, 3) - matlab_probability(:)));
    writematrix([fortran_data(:, 1), matlab_probability(:), fortran_data(:, 3)], ...
        fullfile(artifact_dir, 'wave_comparison.csv'));
    if maximum_fortran_error > 1e-10
        error('MATLAB/Fortran wave comparison exceeded tolerance: %.3e', ...
            maximum_fortran_error);
    end
end

summary_path = fullfile(artifact_dir, 'summary.txt');
summary_file = fopen(summary_path, 'w');
if summary_file < 0
    error('Nao foi possivel criar o resumo em %s.', summary_path);
end
cleanup_file = onCleanup(@() fclose(summary_file)); %#ok<NASGU>
fprintf(summary_file, 'Lattice SU(3) 2^4, pure gauge\n');
fprintf(summary_file, 'Beta: %.6f, measurements: %d, seed: %d\n', ...
    beta, measurement_count, seed);
fprintf(summary_file, 'Wilson mean: %.12f\n', mean(plaquettes));
fprintf(summary_file, 'Metropolis acceptance: %.8f\n', acceptance);
fprintf(summary_file, 'Gauge invariance delta: %.6e\n', gauge_difference);
fprintf(summary_file, 'SU(3) unitarity error: %.6e\n', unitarity_error);
fprintf(summary_file, 'SU(3) determinant error: %.6e\n', determinant_error);
fprintf(summary_file, 'Wave packet sigma(t): %.12f\n', sigma_t);
fprintf(summary_file, 'Wave probability integral: %.12f\n', probability_integral);
fprintf(summary_file, 'Cosmic age H0^-1: %.12f\n', cosmology.age_hubble_units);
fprintf(summary_file, 'Omega_k: %.12f, present q0: %.12f\n', ...
    cosmology.omega_k, cosmology.present_deceleration);
if ~isnan(maximum_fortran_error)
    fprintf(summary_file, 'MATLAB/Fortran max error: %.6e\n', maximum_fortran_error);
end

fprintf('Lattice SU(3) 2^4: mean Wilson = %.6f, acceptance = %.1f%%\n', ...
    mean(plaquettes), 100 * acceptance);
fprintf('Gauge invariance difference = %.3e\n', gauge_difference);
fprintf('SU(3) constraint errors: unitarity = %.3e, determinant = %.3e\n', ...
    unitarity_error, determinant_error);
fprintf('Free-packet sigma(t) = %.6f\n', sigma_t);
fprintf('Wave probability integral = %.12f\n', probability_integral);
if ~isnan(maximum_fortran_error)
    fprintf('MATLAB/Fortran maximum probability error = %.3e\n', ...
        maximum_fortran_error);
end
fprintf('Cosmic age = %.6f H0^-1, Omega_k = %.6f, q0 = %.6f\n', ...
    cosmology.age_hubble_units, cosmology.omega_k, ...
    cosmology.present_deceleration);
render_dashboard(artifact_dir, wilson_history, plaquettes, ...
    plaquettes_before, plaquettes_after, x, probability, fortran_data, cosmology);
save(fullfile(artifact_dir, 'modelos.mat'), 'wilson_history', ...
    'plaquettes', 'acceptance', 'gauge_difference', 'sigma_0', 'k_0', ...
    'unitarity_error', 'determinant_error', 'time', 'x', 'psi', ...
    'probability', 'probability_integral', 'sigma_t', ...
    'maximum_fortran_error', 'cosmology');
fprintf('Numerical outputs saved under %s\n', artifact_dir);
end

function render_dashboard(output_dir, wilson_history, plaquettes, ...
    plaquettes_before, plaquettes_after, x, probability, fortran_data, cosmology)
background = [0.035, 0.047, 0.067];
panel = [0.070, 0.087, 0.112];
text_color = [0.900, 0.930, 0.960];
muted = [0.540, 0.620, 0.700];
grid_color = [0.180, 0.235, 0.285];
cyan = [0.250, 0.850, 0.860];
amber = [1.000, 0.650, 0.340];
violet = [0.660, 0.580, 0.980];

dashboard = figure('Visible', 'off', 'Color', background, ...
    'Position', [40, 80, 2200, 1040], 'Name', 'Realidade Quantica');
layout = tiledlayout(dashboard, 2, 3, ...
    'TileSpacing', 'compact', 'Padding', 'compact');

ax = nexttile(layout);
plot(ax, 1:numel(wilson_history), wilson_history, ...
    'Color', cyan, 'LineWidth', 1.7);
style_report_axes(ax, panel, text_color, muted, grid_color);
title(ax, 'SU(3)  /  media do loop de Wilson', 'Color', text_color);
xlabel(ax, 'Medicao apos aquecimento', 'Color', muted);
ylabel(ax, '<W>', 'Color', muted);

ax = nexttile(layout);
histogram(ax, plaquettes, 22, 'FaceColor', amber, 'EdgeColor', 'none');
style_report_axes(ax, panel, text_color, muted, grid_color);
title(ax, 'SU(3)  /  distribuicao final dos plaquettes', 'Color', text_color);
xlabel(ax, 'Re Tr(U_p) / 3', 'Color', muted);
ylabel(ax, 'Contagem', 'Color', muted);

ax = nexttile(layout);
plot(ax, plaquettes_before, plaquettes_after, '.', ...
    'Color', cyan, 'MarkerSize', 12);
hold(ax, 'on');
plot(ax, [-1, 1], [-1, 1], '--', 'Color', text_color, 'LineWidth', 0.8);
hold(ax, 'off');
style_report_axes(ax, panel, text_color, muted, grid_color);
title(ax, sprintf('Plaquettes  /  invariancia gauge delta %.2e', ...
    max(abs(plaquettes_before - plaquettes_after))), 'Color', text_color);
xlabel(ax, 'Plaquette antes', 'Color', muted);
ylabel(ax, 'Plaquette depois', 'Color', muted);

ax = nexttile(layout);
plot(ax, x, probability, 'Color', violet, 'LineWidth', 1.8);
if ~isempty(fortran_data)
    hold(ax, 'on');
    plot(ax, fortran_data(:, 1), fortran_data(:, 3), '--', ...
        'Color', amber, 'LineWidth', 1.3);
    hold(ax, 'off');
    legend(ax, {'MATLAB', 'Fortran'}, 'TextColor', text_color, ...
        'Color', panel, 'Location', 'northeast');
end
style_report_axes(ax, panel, text_color, muted, grid_color);
title(ax, 'Schrodinger  /  pacote gaussiano livre', 'Color', text_color);
xlabel(ax, 'Posicao x', 'Color', muted);
ylabel(ax, '|psi(x,t)|^2', 'Color', muted);

ax = nexttile(layout);
plot(ax, cosmology.dimensionless_time, cosmology.scale_factor, ...
    'Color', amber, 'LineWidth', 1.9);
style_report_axes(ax, panel, text_color, muted, grid_color);
title(ax, sprintf('Friedmann  /  idade %.4f H0^{-1}  /  q0 %.3f', ...
    cosmology.age_hubble_units, cosmology.present_deceleration), ...
    'Color', text_color);
xlabel(ax, 'Tempo cosmico H0 t', 'Color', muted);
ylabel(ax, 'Fator de escala a(t)', 'Color', muted);

ax = nexttile(layout);
plot(ax, cosmology.dimensionless_time, cosmology.deceleration, ...
    'Color', violet, 'LineWidth', 1.7);
hold(ax, 'on');
yline(ax, 0, ':', 'Color', text_color, 'LineWidth', 1);
hold(ax, 'off');
style_report_axes(ax, panel, text_color, muted, grid_color);
title(ax, 'Friedmann  /  desaceleracao e aceleracao', 'Color', text_color);
xlabel(ax, 'Tempo cosmico H0 t', 'Color', muted);
ylabel(ax, 'Parametro q(t)', 'Color', muted);

exportgraphics(dashboard, fullfile(output_dir, 'realidade-quantica-dashboard.png'), ...
    'Resolution', 180);
close(dashboard);
end

function style_report_axes(ax, panel, text_color, muted, grid_color)
ax.Color = panel;
ax.XColor = muted;
ax.YColor = muted;
ax.GridColor = grid_color;
ax.FontName = 'Consolas';
ax.FontSize = 10;
ax.Box = 'off';
grid(ax, 'on');
end
