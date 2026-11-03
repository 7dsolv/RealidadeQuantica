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
state_dir = fullfile(project_dir, 'state');
addpath(matlab_dir);
if ~exist(artifact_dir, 'dir')
    mkdir(artifact_dir);
end
memory_path = fullfile(state_dir, 'konaet_memory.csv');
if ~isfile(memory_path)
    error('Memoria inicial do agente nao encontrada em %s.', memory_path);
end
memory_history = readmatrix(memory_path);
if isempty(memory_history) || size(memory_history, 2) ~= 16
    error('Memoria do agente precisa conter 16 colunas numericas.');
end
[policy, ~] = konaet_agent(memory_history);
cycle = policy.cycle;
beta = policy.beta;
measurement_count = 80;
step_size = policy.step_size;
seed = policy.seed;
ramsey_phase = policy.ramsey_phase;
ramsey_probability = policy.ramsey_probability;

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

observations = struct('wilson_mean', mean(plaquettes), ...
    'acceptance', acceptance, 'wave_spread', sigma_t / sigma_0, ...
    'deceleration', cosmology.present_deceleration);
[~, agent_memory] = konaet_agent(memory_history, observations);
curiosity = agent_memory(6);
coherence = agent_memory(7);
prediction_error = agent_memory(16);
memory_history = [memory_history; agent_memory];
writematrix(memory_history, memory_path);
writematrix(memory_history, fullfile(artifact_dir, 'konaet_memory.csv'));

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
fprintf(summary_file, 'Autonomous cycle: %.0f\n', cycle);
fprintf(summary_file, 'Agent curiosity/coherence: %.6f / %.6f\n', ...
    curiosity, coherence);
fprintf(summary_file, 'Ramsey phase and ideal P(1): %.8f / %.8f\n', ...
    ramsey_phase, ramsey_probability);
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
fprintf('Autonomous cycle %.0f: curiosity %.4f, coherence %.4f\n', ...
    cycle, curiosity, coherence);
render_dashboard(artifact_dir, wilson_history, plaquettes, ...
    plaquettes_before, plaquettes_after, x, probability, fortran_data, cosmology);
render_live_animation(artifact_dir, wilson_history, x, sigma_0, k_0, ...
    cosmology, memory_history(1:end - 1, :), agent_memory);
save(fullfile(artifact_dir, 'modelos.mat'), 'wilson_history', ...
    'plaquettes', 'acceptance', 'gauge_difference', 'sigma_0', 'k_0', ...
    'unitarity_error', 'determinant_error', 'time', 'x', 'psi', ...
    'probability', 'probability_integral', 'sigma_t', ...
    'maximum_fortran_error', 'cosmology', 'agent_memory', ...
    'ramsey_phase', 'ramsey_probability', 'curiosity', ...
    'coherence', 'prediction_error');
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

function render_live_animation(output_dir, wilson_history, x, sigma_0, k_0, ...
    cosmology, identity_history, agent_memory)
frame_count = 18;
frame_delay = 0.12;
cycle = agent_memory(1);
background = [0.025, 0.035, 0.055];
panel = [0.055, 0.073, 0.100];
text_color = [0.900, 0.940, 0.970];
muted = [0.510, 0.620, 0.710];
grid_color = [0.140, 0.210, 0.270];
cyan = [0.180, 0.860, 0.920];
violet = [0.710, 0.590, 1.000];
amber = [1.000, 0.670, 0.340];
green = [0.270, 0.930, 0.640];
identity_colors = [cyan; violet; amber; green];

frame_dir = tempname(output_dir);
mkdir(frame_dir);
frame_cleanup = onCleanup(@() remove_animation_frames(frame_dir)); %#ok<NASGU>
animation = figure('Visible', 'off', 'Color', background, ...
    'Position', [40, 60, 1480, 850], 'Name', 'Konaet');
figure_cleanup = onCleanup(@() close_animation_figure(animation)); %#ok<NASGU>
layout = tiledlayout(animation, 2, 2, ...
    'TileSpacing', 'compact', 'Padding', 'compact');
title(layout, sprintf('KONAET  /  CICLO %05.0f  /  TRAJETORIA DA SIMULACAO', ...
    cycle), 'Color', text_color, 'FontName', 'Consolas', ...
    'FontWeight', 'bold', 'FontSize', 15);

ax_wilson = nexttile(layout, 1);
wilson_line = plot(ax_wilson, NaN, NaN, 'Color', cyan, 'LineWidth', 2.1);
hold(ax_wilson, 'on');
plot(ax_wilson, 1:numel(wilson_history), wilson_history, ...
    'Color', [0.075, 0.360, 0.385], 'LineWidth', 0.7);
hold(ax_wilson, 'off');
xlim(ax_wilson, [1, numel(wilson_history)]);
wilson_span = max(wilson_history) - min(wilson_history);
if wilson_span < 1e-6
    wilson_span = 0.1;
end
ylim(ax_wilson, [min(wilson_history) - 0.12 * wilson_span, ...
    max(wilson_history) + 0.12 * wilson_span]);
title(ax_wilson, 'CAMPO DE GAUGE  /  LOOP DE WILSON', 'Color', text_color);
xlabel(ax_wilson, 'Medicoes Monte Carlo', 'Color', muted);
ylabel(ax_wilson, '<W>', 'Color', muted);
style_animation_axes(ax_wilson, panel, muted, grid_color);

ax_wave = nexttile(layout, 2);
wave_line = plot(ax_wave, x, zeros(size(x)), ...
    'Color', violet, 'LineWidth', 2.0);
xlim(ax_wave, [min(x), max(x)]);
ylim(ax_wave, [0, 0.65]);
title(ax_wave, 'CAMPO QUANTICO  /  PACOTE DE ONDA', 'Color', text_color);
xlabel(ax_wave, 'Posicao x', 'Color', muted);
ylabel(ax_wave, '|psi(x,t)|^2', 'Color', muted);
style_animation_axes(ax_wave, panel, muted, grid_color);

ax_cosmos = nexttile(layout, 3);
plot(ax_cosmos, cosmology.dimensionless_time, cosmology.scale_factor, ...
    'Color', [0.400, 0.270, 0.140], 'LineWidth', 1.0);
hold(ax_cosmos, 'on');
cosmic_marker = plot(ax_cosmos, NaN, NaN, 'o', ...
    'Color', amber, 'MarkerFaceColor', amber, 'MarkerSize', 8);
hold(ax_cosmos, 'off');
xlim(ax_cosmos, [0, cosmology.age_hubble_units]);
ylim(ax_cosmos, [min(cosmology.scale_factor), 1.05]);
set(ax_cosmos, 'YScale', 'log');
title(ax_cosmos, 'COSMOLOGIA  /  EXPANSAO FLRW', 'Color', text_color);
xlabel(ax_cosmos, 'Tempo cosmico H0 t', 'Color', muted);
ylabel(ax_cosmos, 'Fator de escala a(t)', 'Color', muted);
style_animation_axes(ax_cosmos, panel, muted, grid_color);

ax_identity = nexttile(layout, 4);
hold(ax_identity, 'on');
identity_lines = gobjects(1, 4);
for state_index = 1:4
    identity_lines(state_index) = plot(ax_identity, NaN, NaN, ...
        'Color', identity_colors(state_index, :), 'LineWidth', 1.7);
end
hold(ax_identity, 'off');
xlim(ax_identity, [max(0, cycle - 20), max(1, cycle)]);
ylim(ax_identity, [-1.05, 1.05]);
title(ax_identity, sprintf('MEMORIA DO AGENTE  /  COERENCIA %.3f', ...
    agent_memory(7)), 'Color', text_color);
xlabel(ax_identity, 'Ciclos persistidos', 'Color', muted);
ylabel(ax_identity, 'Estado interno', 'Color', muted);
legend(ax_identity, {'s1', 's2', 's3', 's4'}, ...
    'TextColor', text_color, 'Color', panel, ...
    'Location', 'southoutside', 'Orientation', 'horizontal');
style_animation_axes(ax_identity, panel, muted, grid_color);

gif_path = fullfile(output_dir, 'realidade-quantica-viva.gif');
color_map = make_332_palette();
for frame_index = 1:frame_count
    progress = (frame_index - 1) / (frame_count - 1);
    measurement_index = max(1, min(numel(wilson_history), ...
        round(progress * (numel(wilson_history) - 1)) + 1));
    set(wilson_line, 'XData', 1:measurement_index, ...
        'YData', wilson_history(1:measurement_index));

    wave_time = 2.4 * progress;
    [~, wave_probability] = free_wavepacket(x, sigma_0, k_0, wave_time);
    set(wave_line, 'YData', wave_probability);

    cosmic_index = max(1, min(numel(cosmology.dimensionless_time), ...
        round(progress * (numel(cosmology.dimensionless_time) - 1)) + 1));
    set(cosmic_marker, 'XData', cosmology.dimensionless_time(cosmic_index), ...
        'YData', cosmology.scale_factor(cosmic_index));

    if isempty(identity_history)
        visible_history = agent_memory;
    else
        visible_history = identity_history( ...
            max(1, size(identity_history, 1) - 19):end, :);
    end
    fractional_state = identity_history_value(visible_history, ...
        agent_memory, progress);
    for state_index = 1:4
        set(identity_lines(state_index), ...
            'XData', [visible_history(:, 1); cycle - 1 + progress], ...
            'YData', [visible_history(:, state_index + 1); ...
                fractional_state(state_index)]);
    end

    drawnow;
    frame_path = fullfile(frame_dir, sprintf('frame-%03d.png', frame_index));
    exportgraphics(animation, frame_path, 'Resolution', 90);
    rgb = imread(frame_path);
    red = bitshift(rgb(:, :, 1), -5);
    green_channel = bitshift(rgb(:, :, 2), -5);
    blue = bitshift(rgb(:, :, 3), -6);
    indexed = bitor(bitor(bitshift(red, 5), ...
        bitshift(green_channel, 2)), blue);
    if frame_index == 1
        imwrite(indexed, color_map, gif_path, 'gif', ...
            'LoopCount', inf, 'DelayTime', frame_delay);
    else
        imwrite(indexed, color_map, gif_path, 'gif', ...
            'WriteMode', 'append', 'DelayTime', frame_delay);
    end
end
end

function state = identity_history_value(history, current_memory, progress)
previous_state = history(end, 2:5);
current_state = current_memory(2:5);
state = (1 - progress) .* previous_state + progress .* current_state;
end

function color_map = make_332_palette()
palette_index = uint8((0:255).');
red = double(bitshift(palette_index, -5)) / 7;
green = double(bitand(bitshift(palette_index, -2), 7)) / 7;
blue = double(bitand(palette_index, 3)) / 3;
color_map = [red, green, blue];
end

function style_animation_axes(ax, panel, muted, grid_color)
ax.Color = panel;
ax.XColor = muted;
ax.YColor = muted;
ax.GridColor = grid_color;
ax.FontName = 'Consolas';
ax.FontSize = 9;
ax.Box = 'off';
grid(ax, 'on');
end

function remove_animation_frames(frame_dir)
if isfolder(frame_dir)
    rmdir(frame_dir, 's');
end
end

function close_animation_figure(animation)
if isgraphics(animation)
    close(animation);
end
end
