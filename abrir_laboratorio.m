function fig = abrir_laboratorio()
%ABRIR_LABORATORIO Launch the MATLAB-only Realidade Quantica lab.

project_dir = fileparts(mfilename('fullpath'));
matlab_dir = fullfile(project_dir, 'matlab');
addpath(matlab_dir);

C.background = [0.035, 0.047, 0.067];
C.panel = [0.070, 0.087, 0.112];
C.panel_alt = [0.095, 0.116, 0.145];
C.text = [0.900, 0.930, 0.960];
C.muted = [0.540, 0.620, 0.700];
C.line = [0.180, 0.235, 0.285];
C.cyan = [0.250, 0.850, 0.860];
C.lime = [0.720, 0.930, 0.430];
C.amber = [1.000, 0.650, 0.340];
C.violet = [0.660, 0.580, 0.980];

latest_links = [];
latest_lattice = [];
source_list = [];
code_title = [];
code_area = [];
beta_field = [];
sweep_field = [];
step_field = [];
seed_field = [];
run_button = [];
gauge_button = [];
plaquette_metric = [];
acceptance_metric = [];
gauge_metric = [];
lattice_status = [];
trace_axes = [];
histogram_axes = [];
sigma_field = [];
wave_number_field = [];
time_field = [];
time_slider = [];
probability_axes = [];
real_axes = [];
width_metric = [];
center_metric = [];
norm_metric = [];
wave_status = [];
omega_m_field = [];
omega_lambda_field = [];
omega_r_field = [];
scale_axes = [];
hubble_axes = [];
deceleration_axes = [];
age_metric = [];
curvature_metric = [];
acceleration_metric = [];
cosmology_status = [];

fig = uifigure('Name', 'Realidade Quantica | Laboratorio', ...
    'Position', [80, 60, 1420, 900], ...
    'Color', C.background);

root = uigridlayout(fig, [2, 1], ...
    'RowHeight', {108, '1x'}, ...
    'ColumnWidth', {'1x'}, ...
    'Padding', [18, 18, 18, 18], ...
    'RowSpacing', 14);

header = uipanel(root, 'BorderType', 'none', 'BackgroundColor', C.panel);
header.Layout.Row = 1;
header_grid = uigridlayout(header, [2, 2], ...
    'RowHeight', {24, '1x'}, ...
    'ColumnWidth', {'1x', 240}, ...
    'Padding', [20, 12, 20, 12], ...
    'ColumnSpacing', 10);

eyebrow = uilabel(header_grid, ...
    'Text', 'KONAET   /   FISICA COMPUTACIONAL   /   LAB 01', ...
    'FontName', 'Consolas', 'FontSize', 11, 'FontWeight', 'bold', ...
    'FontColor', C.cyan);
eyebrow.Layout.Row = 1;
eyebrow.Layout.Column = 1;

local_badge = uilabel(header_grid, ...
    'Text', 'EXECUCAO LOCAL  ·  MATLAB', ...
    'FontName', 'Consolas', 'FontSize', 10, 'FontWeight', 'bold', ...
    'FontColor', C.lime, 'HorizontalAlignment', 'right');
local_badge.Layout.Row = 1;
local_badge.Layout.Column = 2;

title_label = uilabel(header_grid, ...
    'Text', 'REALIDADE QUANTICA', ...
    'FontName', 'Arial', 'FontSize', 27, 'FontWeight', 'bold', ...
    'FontColor', C.text);
title_label.Layout.Row = 2;
title_label.Layout.Column = 1;

subtitle = uilabel(header_grid, ...
    'Text', 'QCD SU(3)  /  Schrodinger  /  Friedmann  /  Q#  /  FPGA', ...
    'FontName', 'Consolas', 'FontSize', 10, ...
    'FontColor', C.muted, 'HorizontalAlignment', 'right');
subtitle.Layout.Row = 2;
subtitle.Layout.Column = 2;

tabs = uitabgroup(root, 'TabLocation', 'top');
tabs.Layout.Row = 2;
tabs.Layout.Column = 1;
tab_lattice = uitab(tabs, 'Title', '  01  /  LATTICE SU(3)  ');
tab_wave = uitab(tabs, 'Title', '  02  /  ONDA QUANTICA  ');
tab_cosmology = uitab(tabs, 'Title', '  03  /  COSMOLOGIA  ');
tab_engines = uitab(tabs, 'Title', '  04  /  MODULOS  ');

build_lattice_tab();
build_wave_tab();
build_cosmology_tab();
build_engines_tab();
render_wave();
render_cosmology();
load_selected_source();

    function build_lattice_tab()
        page = uigridlayout(tab_lattice, [1, 2], ...
            'ColumnWidth', {292, '1x'}, ...
            'RowHeight', {'1x'}, ...
            'Padding', [16, 16, 16, 16], ...
            'ColumnSpacing', 16);

        controls = uipanel(page, 'BorderType', 'none', ...
            'BackgroundColor', C.panel);
        controls.Layout.Row = 1;
        controls.Layout.Column = 1;
        control_grid = uigridlayout(controls, [13, 1], ...
            'RowHeight', {24, 18, 34, 18, 34, 18, 34, 18, 34, 42, 38, 50, '1x'}, ...
            'Padding', [16, 14, 16, 14], ...
            'RowSpacing', 7);

        section = uilabel(control_grid, 'Text', 'PURE GAUGE  /  WILSON', ...
            'FontName', 'Consolas', 'FontSize', 11, 'FontWeight', 'bold', ...
            'FontColor', C.cyan);
        section.Layout.Row = 1;
        add_field_label(control_grid, 'Beta de acoplamento', 2);
        beta_field = uieditfield(control_grid, 'numeric', ...
            'Limits', [0.1, 10], 'Value', 5.5, 'BackgroundColor', C.panel_alt, ...
            'FontColor', C.text);
        beta_field.Layout.Row = 3;
        add_field_label(control_grid, 'Medicoes apos aquecimento', 4);
        sweep_field = uieditfield(control_grid, 'numeric', ...
            'Limits', [10, 600], 'Value', 120, 'BackgroundColor', C.panel_alt, ...
            'FontColor', C.text);
        sweep_field.Layout.Row = 5;
        add_field_label(control_grid, 'Passo do Metropolis', 6);
        step_field = uieditfield(control_grid, 'numeric', ...
            'Limits', [0.02, 1.5], 'Value', 0.35, 'BackgroundColor', C.panel_alt, ...
            'FontColor', C.text);
        step_field.Layout.Row = 7;
        add_field_label(control_grid, 'Semente aleatoria', 8);
        seed_field = uieditfield(control_grid, 'numeric', ...
            'Limits', [0, 1000000], 'Value', 7, 'BackgroundColor', C.panel_alt, ...
            'FontColor', C.text);
        seed_field.Layout.Row = 9;

        run_button = uibutton(control_grid, 'push', ...
            'Text', 'RODAR MONTE CARLO', ...
            'BackgroundColor', C.cyan, 'FontColor', C.background, ...
            'FontName', 'Consolas', 'FontSize', 12, 'FontWeight', 'bold', ...
            'ButtonPushedFcn', @run_lattice);
        run_button.Layout.Row = 10;

        gauge_button = uibutton(control_grid, 'push', ...
            'Text', 'VALIDAR INVARIANCIA DE GAUGE', ...
            'BackgroundColor', C.panel_alt, 'FontColor', C.lime, ...
            'FontName', 'Consolas', 'FontSize', 10, ...
            'ButtonPushedFcn', @check_gauge_invariance);
        gauge_button.Layout.Row = 11;

        lattice_status = uilabel(control_grid, ...
            'Text', 'Pronto  ·  grade 2^4  ·  16 sitios  ·  64 links', ...
            'FontName', 'Consolas', 'FontSize', 9, ...
            'FontColor', C.muted, 'WordWrap', 'on');
        lattice_status.Layout.Row = 12;

        lattice_note = uilabel(control_grid, ...
            'Text', ['Modelo didatico de gauge puro. Mede loops de Wilson em uma rede ' ...
                'periodica 2^4. Nao inclui quarks dinamicos e nao calcula um proton.'], ...
            'FontName', 'Arial', 'FontSize', 10, ...
            'FontColor', C.muted, 'WordWrap', 'on', ...
            'VerticalAlignment', 'top');
        lattice_note.Layout.Row = 13;

        plots = uipanel(page, 'BorderType', 'none', 'BackgroundColor', C.panel);
        plots.Layout.Row = 1;
        plots.Layout.Column = 2;
        plot_grid = uigridlayout(plots, [3, 2], ...
            'RowHeight', {76, '1x', '1x'}, 'ColumnWidth', {'1x', '1x'}, ...
            'Padding', [14, 14, 14, 14], 'RowSpacing', 12, 'ColumnSpacing', 12);

        metric_panel = uipanel(plot_grid, 'BorderType', 'none', ...
            'BackgroundColor', C.panel_alt);
        metric_panel.Layout.Row = 1;
        metric_panel.Layout.Column = [1, 2];
        metric_grid = uigridlayout(metric_panel, [1, 3], ...
            'ColumnWidth', {'1x', '1x', '1x'}, ...
            'Padding', [12, 8, 12, 8], 'ColumnSpacing', 10);
        [plaquette_metric, acceptance_metric, gauge_metric] = ...
            make_metrics(metric_grid, {'MEDIA <W>', 'ACEITACAO', 'DELTA GAUGE'}, C);

        trace_axes = uiaxes(plot_grid);
        trace_axes.Layout.Row = 2;
        trace_axes.Layout.Column = 1;
        style_axes(trace_axes, C);
        title(trace_axes, 'Loop de Wilson medio por varredura', ...
            'Color', C.text, 'FontWeight', 'normal');
        xlabel(trace_axes, 'Medicao', 'Color', C.muted);
        ylabel(trace_axes, '<W>', 'Color', C.muted);

        histogram_axes = uiaxes(plot_grid);
        histogram_axes.Layout.Row = 2;
        histogram_axes.Layout.Column = 2;
        style_axes(histogram_axes, C);
        title(histogram_axes, 'Loops na configuracao final', ...
            'Color', C.text, 'FontWeight', 'normal');
        xlabel(histogram_axes, 'Re Tr(U_p) / 3', 'Color', C.muted);
        ylabel(histogram_axes, 'Contagem', 'Color', C.muted);

        lattice_axes = uiaxes(plot_grid);
        lattice_axes.Layout.Row = 3;
        lattice_axes.Layout.Column = [1, 2];
        style_axes(lattice_axes, C);
        draw_lattice_projection(lattice_axes, C);
    end

    function build_wave_tab()
        page = uigridlayout(tab_wave, [1, 2], ...
            'ColumnWidth', {292, '1x'}, 'RowHeight', {'1x'}, ...
            'Padding', [16, 16, 16, 16], 'ColumnSpacing', 16);

        controls = uipanel(page, 'BorderType', 'none', ...
            'BackgroundColor', C.panel);
        controls.Layout.Row = 1;
        controls.Layout.Column = 1;
        control_grid = uigridlayout(controls, [12, 1], ...
            'RowHeight', {24, 18, 34, 18, 34, 18, 34, 18, 34, 42, 42, '1x'}, ...
            'Padding', [16, 14, 16, 14], 'RowSpacing', 7);

        section = uilabel(control_grid, 'Text', 'PACOTE GAUSSIANO LIVRE', ...
            'FontName', 'Consolas', 'FontSize', 11, 'FontWeight', 'bold', ...
            'FontColor', C.violet);
        section.Layout.Row = 1;
        add_field_label(control_grid, 'Largura inicial sigma_0', 2);
        sigma_field = uieditfield(control_grid, 'numeric', ...
            'Limits', [0.25, 2], 'Value', 0.7, 'BackgroundColor', C.panel_alt, ...
            'FontColor', C.text);
        sigma_field.Layout.Row = 3;
        add_field_label(control_grid, 'Numero de onda k_0', 4);
        wave_number_field = uieditfield(control_grid, 'numeric', ...
            'Limits', [-3, 3], 'Value', 1.2, 'BackgroundColor', C.panel_alt, ...
            'FontColor', C.text);
        wave_number_field.Layout.Row = 5;
        add_field_label(control_grid, 'Tempo t  ·  unidades naturais', 6);
        time_field = uieditfield(control_grid, 'numeric', ...
            'Limits', [0, 3], 'Value', 0.8, 'BackgroundColor', C.panel_alt, ...
            'FontColor', C.text, 'ValueChangedFcn', @time_field_changed);
        time_field.Layout.Row = 7;
        time_slider = uislider(control_grid, 'Limits', [0, 3], ...
            'Value', 0.8, 'MajorTicks', [0, 0.75, 1.5, 2.25, 3], ...
            'ValueChangedFcn', @time_slider_changed);
        time_slider.Layout.Row = 8;
        add_field_label(control_grid, 'hbar = m = 1', 9);

        update_button = uibutton(control_grid, 'push', ...
            'Text', 'ATUALIZAR ONDA', 'BackgroundColor', C.violet, ...
            'FontColor', C.background, 'FontName', 'Consolas', ...
            'FontSize', 12, 'FontWeight', 'bold', 'ButtonPushedFcn', @render_wave);
        update_button.Layout.Row = 10;

        fortran_button = uibutton(control_grid, 'push', ...
            'Text', 'COMPARAR COM FORTRAN', ...
            'BackgroundColor', C.panel_alt, 'FontColor', C.amber, ...
            'FontName', 'Consolas', 'FontSize', 10, ...
            'ButtonPushedFcn', @run_fortran_wave);
        fortran_button.Layout.Row = 11;

        wave_status = uilabel(control_grid, ...
            'Text', 'Solucao analitica exata para particula livre.', ...
            'FontName', 'Consolas', 'FontSize', 9, ...
            'FontColor', C.muted, 'WordWrap', 'on', ...
            'VerticalAlignment', 'top');
        wave_status.Layout.Row = 12;

        plots = uipanel(page, 'BorderType', 'none', 'BackgroundColor', C.panel);
        plots.Layout.Row = 1;
        plots.Layout.Column = 2;
        plot_grid = uigridlayout(plots, [3, 1], ...
            'RowHeight', {76, '1x', '1x'}, 'ColumnWidth', {'1x'}, ...
            'Padding', [14, 14, 14, 14], 'RowSpacing', 10);

        metric_panel = uipanel(plot_grid, 'BorderType', 'none', ...
            'BackgroundColor', C.panel_alt);
        metric_panel.Layout.Row = 1;
        metrics = uigridlayout(metric_panel, [1, 3], ...
            'ColumnWidth', {'1x', '1x', '1x'}, ...
            'Padding', [12, 8, 12, 8], 'ColumnSpacing', 10);
        [width_metric, center_metric, norm_metric] = ...
            make_metrics(metrics, {'SIGMA(t)', 'CENTRO', 'INTEGRAL P'}, C);

        probability_axes = uiaxes(plot_grid);
        probability_axes.Layout.Row = 2;
        probability_axes.Layout.Column = 1;
        style_axes(probability_axes, C);
        title(probability_axes, 'Densidade de probabilidade  |psi|^2', ...
            'Color', C.text, 'FontWeight', 'normal');
        xlabel(probability_axes, 'x', 'Color', C.muted);
        ylabel(probability_axes, 'Probabilidade', 'Color', C.muted);

        real_axes = uiaxes(plot_grid);
        real_axes.Layout.Row = 3;
        real_axes.Layout.Column = 1;
        style_axes(real_axes, C);
        title(real_axes, 'Parte real da funcao de onda Re(psi)', ...
            'Color', C.text, 'FontWeight', 'normal');
        xlabel(real_axes, 'x', 'Color', C.muted);
        ylabel(real_axes, 'Amplitude', 'Color', C.muted);
    end

    function build_cosmology_tab()
        page = uigridlayout(tab_cosmology, [1, 2], ...
            'ColumnWidth', {292, '1x'}, 'RowHeight', {'1x'}, ...
            'Padding', [16, 16, 16, 16], 'ColumnSpacing', 16);

        controls = uipanel(page, 'BorderType', 'none', ...
            'BackgroundColor', C.panel);
        controls.Layout.Row = 1;
        controls.Layout.Column = 1;
        control_grid = uigridlayout(controls, [9, 1], ...
            'RowHeight', {24, 18, 34, 18, 34, 18, 34, 42, '1x'}, ...
            'Padding', [16, 14, 16, 14], 'RowSpacing', 8);

        section = uilabel(control_grid, 'Text', 'EXPANSAO FRIEDMANN-LEMAITRE', ...
            'FontName', 'Consolas', 'FontSize', 10, 'FontWeight', 'bold', ...
            'FontColor', C.amber);
        section.Layout.Row = 1;
        add_field_label(control_grid, 'Omega_m  ·  materia', 2);
        omega_m_field = uieditfield(control_grid, 'numeric', ...
            'Limits', [0, 2], 'Value', 0.315, ...
            'BackgroundColor', C.panel_alt, 'FontColor', C.text);
        omega_m_field.Layout.Row = 3;
        add_field_label(control_grid, 'Omega_lambda  ·  energia escura', 4);
        omega_lambda_field = uieditfield(control_grid, 'numeric', ...
            'Limits', [-0.5, 2], 'Value', 0.68491, ...
            'BackgroundColor', C.panel_alt, 'FontColor', C.text);
        omega_lambda_field.Layout.Row = 5;
        add_field_label(control_grid, 'Omega_r  ·  radiacao', 6);
        omega_r_field = uieditfield(control_grid, 'numeric', ...
            'Limits', [0, 0.5], 'Value', 0.00009, ...
            'BackgroundColor', C.panel_alt, 'FontColor', C.text);
        omega_r_field.Layout.Row = 7;

        update_button = uibutton(control_grid, 'push', ...
            'Text', 'RECALCULAR UNIVERSO', ...
            'BackgroundColor', C.amber, 'FontColor', C.background, ...
            'FontName', 'Consolas', 'FontSize', 11, 'FontWeight', 'bold', ...
            'ButtonPushedFcn', @render_cosmology);
        update_button.Layout.Row = 8;

        cosmology_status = uilabel(control_grid, ...
            'Text', ['Modelo FLRW homogeneo e isotropico. A curvatura Omega_k ' ...
                'e inferida para fechar Friedmann; sem perturbacoes ou formacao ' ...
                'de estruturas.'], ...
            'FontName', 'Arial', 'FontSize', 10, ...
            'FontColor', C.muted, 'WordWrap', 'on', ...
            'VerticalAlignment', 'top');
        cosmology_status.Layout.Row = 9;

        plots = uipanel(page, 'BorderType', 'none', 'BackgroundColor', C.panel);
        plots.Layout.Row = 1;
        plots.Layout.Column = 2;
        plot_grid = uigridlayout(plots, [3, 2], ...
            'RowHeight', {76, '1x', '1x'}, 'ColumnWidth', {'1x', '1x'}, ...
            'Padding', [14, 14, 14, 14], 'RowSpacing', 12, 'ColumnSpacing', 12);

        metric_panel = uipanel(plot_grid, 'BorderType', 'none', ...
            'BackgroundColor', C.panel_alt);
        metric_panel.Layout.Row = 1;
        metric_panel.Layout.Column = [1, 2];
        metrics = uigridlayout(metric_panel, [1, 3], ...
            'ColumnWidth', {'1x', '1x', '1x'}, ...
            'Padding', [12, 8, 12, 8], 'ColumnSpacing', 10);
        [age_metric, curvature_metric, acceleration_metric] = ...
            make_metrics(metrics, {'IDADE H0t0', 'CURVATURA Omega_k', 'q0 ATUAL'}, C);

        scale_axes = uiaxes(plot_grid);
        scale_axes.Layout.Row = 2;
        scale_axes.Layout.Column = 1;
        style_axes(scale_axes, C);
        title(scale_axes, 'Fator de escala ao longo do tempo cosmico', ...
            'Color', C.text, 'FontWeight', 'normal');
        xlabel(scale_axes, 'H0 t', 'Color', C.muted);
        ylabel(scale_axes, 'a(t)', 'Color', C.muted);

        hubble_axes = uiaxes(plot_grid);
        hubble_axes.Layout.Row = 2;
        hubble_axes.Layout.Column = 2;
        style_axes(hubble_axes, C);
        title(hubble_axes, 'Taxa de expansao normalizada E(a)', ...
            'Color', C.text, 'FontWeight', 'normal');
        xlabel(hubble_axes, 'Fator de escala a', 'Color', C.muted);
        ylabel(hubble_axes, 'H(a) / H0', 'Color', C.muted);

        deceleration_axes = uiaxes(plot_grid);
        deceleration_axes.Layout.Row = 3;
        deceleration_axes.Layout.Column = [1, 2];
        style_axes(deceleration_axes, C);
        title(deceleration_axes, 'Transicao entre desaceleracao e aceleracao', ...
            'Color', C.text, 'FontWeight', 'normal');
        xlabel(deceleration_axes, 'Tempo cosmico H0 t', 'Color', C.muted);
        ylabel(deceleration_axes, 'Parametro de desaceleracao q(t)', ...
            'Color', C.muted);
    end

    function build_engines_tab()
        page = uigridlayout(tab_engines, [1, 2], ...
            'ColumnWidth', {340, '1x'}, 'RowHeight', {'1x'}, ...
            'Padding', [16, 16, 16, 16], 'ColumnSpacing', 16);

        source_panel = uipanel(page, 'BorderType', 'none', ...
            'BackgroundColor', C.panel);
        source_panel.Layout.Row = 1;
        source_panel.Layout.Column = 1;
        source_grid = uigridlayout(source_panel, [5, 1], ...
            'RowHeight', {24, 56, 64, 40, '1x'}, ...
            'Padding', [16, 14, 16, 14], 'RowSpacing', 10);

        source_heading = uilabel(source_grid, 'Text', 'MODULOS DO LABORATORIO', ...
            'FontName', 'Consolas', 'FontSize', 11, 'FontWeight', 'bold', ...
            'FontColor', C.cyan);
        source_heading.Layout.Row = 1;

        source_list = uidropdown(source_grid, ...
            'Items', {'MATLAB · SU(3) Monte Carlo', ...
                'MATLAB · invariancia de gauge', ...
                'MATLAB · medicao de plaquettes', ...
                'MATLAB · matrizes SU(3)', ...
                'MATLAB · onda gaussiana', ...
                'MATLAB · cosmologia FLRW', ...
                'Fortran · onda gaussiana', ...
                'Q# · interferometria Ramsey', ...
                'SystemVerilog · multiplicador complexo'}, ...
            'Value', 'MATLAB · SU(3) Monte Carlo', ...
            'BackgroundColor', C.panel_alt, 'FontColor', C.text, ...
            'ValueChangedFcn', @load_selected_source);
        source_list.Layout.Row = 2;

        source_info = uilabel(source_grid, ...
            'Text', ['O nucleo visual e numerico roda em MATLAB. Os outros arquivos ' ...
                'sao modulos-fonte reais para compiladores e ferramentas proprias.'], ...
            'FontName', 'Arial', 'FontSize', 10, ...
            'FontColor', C.muted, 'WordWrap', 'on', ...
            'VerticalAlignment', 'top');
        source_info.Layout.Row = 3;

        source_buttons = uigridlayout(source_grid, [1, 2], ...
            'ColumnWidth', {'1x', '1x'}, 'Padding', [0, 0, 0, 0], ...
            'ColumnSpacing', 8);
        source_buttons.Layout.Row = 4;
        open_source_button = uibutton(source_buttons, 'push', ...
            'Text', 'ABRIR ARQUIVO', 'BackgroundColor', C.panel_alt, ...
            'FontColor', C.cyan, 'FontName', 'Consolas', 'FontSize', 10, ...
            'ButtonPushedFcn', @open_selected_source);
        copy_source_button = uibutton(source_buttons, 'push', ...
            'Text', 'COPIAR CODIGO', 'BackgroundColor', C.panel_alt, ...
            'FontColor', C.lime, 'FontName', 'Consolas', 'FontSize', 10, ...
            'ButtonPushedFcn', @copy_selected_source);
        open_source_button.Layout.Row = 1;
        open_source_button.Layout.Column = 1;
        copy_source_button.Layout.Row = 1;
        copy_source_button.Layout.Column = 2;

        module_note = uilabel(source_grid, ...
            'Text', ['Q# usa o simulador local do QDK. Fortran pode ser compilado ' ...
                'com gfortran. O modulo SystemVerilog e preparado para sintese FPGA.'], ...
            'FontName', 'Consolas', 'FontSize', 9, ...
            'FontColor', C.muted, 'WordWrap', 'on', ...
            'VerticalAlignment', 'top');
        module_note.Layout.Row = 5;

        code_panel = uipanel(page, 'BorderType', 'none', ...
            'BackgroundColor', C.panel);
        code_panel.Layout.Row = 1;
        code_panel.Layout.Column = 2;
        code_grid = uigridlayout(code_panel, [2, 1], ...
            'RowHeight', {28, '1x'}, 'ColumnWidth', {'1x'}, ...
            'Padding', [14, 14, 14, 14], 'RowSpacing', 8);

        code_title = uilabel(code_grid, 'Text', 'SOURCE  /  MATLAB', ...
            'FontName', 'Consolas', 'FontSize', 10, 'FontWeight', 'bold', ...
            'FontColor', C.muted);
        code_title.Layout.Row = 1;

        code_area = uitextarea(code_grid, 'Editable', 'off', ...
            'FontName', 'Consolas', 'FontSize', 11, ...
            'BackgroundColor', C.panel_alt, 'FontColor', C.text);
        code_area.Layout.Row = 2;
    end

    function add_field_label(parent, text_value, row)
        label = uilabel(parent, 'Text', text_value, ...
            'FontName', 'Arial', 'FontSize', 10, 'FontColor', C.muted);
        label.Layout.Row = row;
    end

    function [value1, value2, value3] = make_metrics(parent, names, colors)
        value1 = make_one_metric(parent, names{1}, 1, colors);
        value2 = make_one_metric(parent, names{2}, 2, colors);
        value3 = make_one_metric(parent, names{3}, 3, colors);
    end

    function value_label = make_one_metric(parent, heading, column, colors)
        card = uigridlayout(parent, [2, 1], ...
            'RowHeight', {18, '1x'}, 'ColumnWidth', {'1x'}, ...
            'Padding', [4, 0, 4, 0], 'RowSpacing', 0);
        card.Layout.Row = 1;
        card.Layout.Column = column;
        heading_label = uilabel(card, 'Text', heading, ...
            'FontName', 'Consolas', 'FontSize', 9, ...
            'FontColor', colors.muted);
        heading_label.Layout.Row = 1;
        value_label = uilabel(card, 'Text', '—', ...
            'FontName', 'Consolas', 'FontSize', 15, ...
            'FontWeight', 'bold', 'FontColor', colors.text);
        value_label.Layout.Row = 2;
    end

    function style_axes(ax, colors)
        ax.Color = colors.panel;
        ax.XColor = colors.muted;
        ax.YColor = colors.muted;
        ax.GridColor = colors.line;
        ax.FontName = 'Consolas';
        ax.FontSize = 9;
        ax.Box = 'off';
        grid(ax, 'on');
    end

    function draw_lattice_projection(ax, colors)
        cla(ax);
        hold(ax, 'on');
        offset = [0.42, 0.34, 0.46];

        for time_slice = 0:1
            if time_slice == 0
                link_color = colors.cyan;
            else
                link_color = colors.violet;
            end

            for z = 0:1
                for y = 0:1
                    for x = 0:1
                        site = [x, y, z] + time_slice * offset;
                        for direction = 1:3
                            coordinate = [x, y, z];
                            if coordinate(direction) == 0
                                endpoint = site;
                                endpoint(direction) = endpoint(direction) + 1;
                                plot3(ax, [site(1), endpoint(1)], ...
                                    [site(2), endpoint(2)], [site(3), endpoint(3)], ...
                                    'Color', link_color, 'LineWidth', 1.1);
                            end
                        end

                        if time_slice == 0
                            endpoint = site + offset;
                            plot3(ax, [site(1), endpoint(1)], ...
                                [site(2), endpoint(2)], [site(3), endpoint(3)], ...
                                ':', 'Color', colors.amber, 'LineWidth', 1.2);
                        end
                    end
                end
            end
        end

        for time_slice = 0:1
            if time_slice == 0
                node_color = colors.cyan;
            else
                node_color = colors.violet;
            end
            for z = 0:1
                for y = 0:1
                    for x = 0:1
                        site = [x, y, z] + time_slice * offset;
                        scatter3(ax, site(1), site(2), site(3), 34, ...
                            'MarkerFaceColor', node_color, ...
                            'MarkerEdgeColor', colors.text);
                    end
                end
            end
        end

        hold(ax, 'off');
        style_axes(ax, colors);
        grid(ax, 'off');
        ax.XTick = [];
        ax.YTick = [];
        ax.ZTick = [];
        ax.Box = 'off';
        axis(ax, 'equal');
        view(ax, 34, 25);
        xlim(ax, [-0.1, 1.55]);
        ylim(ax, [-0.1, 1.45]);
        zlim(ax, [-0.1, 1.55]);
        title(ax, 'Rede 2^4 projetada  ·  ciano = t0  ·  violeta = t1  ·  pontilhado = link temporal', ...
            'Color', colors.text, 'FontWeight', 'normal');
    end

    function run_lattice(~, ~)
        run_button.Enable = 'off';
        gauge_button.Enable = 'off';
        plaquette_metric.Text = 'calculando';
        acceptance_metric.Text = '—';
        gauge_metric.Text = '—';
        lattice_status.Text = 'Inicializando campo de gauge SU(3)...';
        drawnow;

        try
            [history, final_plaquettes, acceptance, latest_links, latest_lattice] = ...
                run_su3_lattice(beta_field.Value, sweep_field.Value, ...
                    step_field.Value, seed_field.Value, @update_lattice_progress);

            cla(trace_axes);
            plot(trace_axes, 1:numel(history), history, ...
                'Color', C.cyan, 'LineWidth', 1.5);
            style_axes(trace_axes, C);
            title(trace_axes, 'Loop de Wilson medio por varredura', ...
                'Color', C.text, 'FontWeight', 'normal');
            xlabel(trace_axes, 'Medicao apos aquecimento', 'Color', C.muted);
            ylabel(trace_axes, '<W>', 'Color', C.muted);

            cla(histogram_axes);
            histogram(histogram_axes, final_plaquettes, 20, ...
                'FaceColor', C.amber, 'EdgeColor', 'none');
            style_axes(histogram_axes, C);
            title(histogram_axes, 'Loops na configuracao final', ...
                'Color', C.text, 'FontWeight', 'normal');
            xlabel(histogram_axes, 'Re Tr(U_p) / 3', 'Color', C.muted);
            ylabel(histogram_axes, 'Contagem', 'Color', C.muted);

            plaquette_metric.Text = sprintf('%.5f', mean(final_plaquettes));
            acceptance_metric.Text = sprintf('%.1f%%', 100 * acceptance);
            lattice_status.Text = sprintf('Concluido  ·  %d plaquettes  ·  %d links', ...
                numel(final_plaquettes), latest_lattice.n_sites * latest_lattice.n_directions);
        catch problem
            lattice_status.Text = 'Falha ao executar a simulacao.';
            uialert(fig, problem.message, 'Erro na simulacao SU(3)');
        end

        run_button.Enable = 'on';
        gauge_button.Enable = 'on';
    end

    function update_lattice_progress(current, total)
        lattice_status.Text = sprintf('Metropolis  ·  varredura %d / %d', current, total);
        drawnow limitrate;
    end

    function check_gauge_invariance(~, ~)
        if isempty(latest_links)
            uialert(fig, 'Rode Monte Carlo antes de validar a invariancia.', ...
                'Nenhuma configuracao');
            return;
        end

        [difference, ~, ~] = validate_su3_gauge(latest_links, latest_lattice);
        gauge_metric.Text = sprintf('%.2e', difference);
        if difference < 1e-10
            lattice_status.Text = 'Gauge validado  ·  os loops permaneceram invariantes.';
        else
            lattice_status.Text = 'Diferenca numerica acima do esperado.';
        end
    end

    function render_wave(varargin)
        sigma_0 = sigma_field.Value;
        k_0 = wave_number_field.Value;
        time_value = time_field.Value;
        x = linspace(-10, 10, 1001);
        [psi, probability, sigma_t] = free_wavepacket(x, sigma_0, k_0, time_value);

        cla(probability_axes);
        plot(probability_axes, x, probability, ...
            'Color', C.violet, 'LineWidth', 1.8);
        style_axes(probability_axes, C);
        title(probability_axes, 'Densidade de probabilidade  |psi|^2', ...
            'Color', C.text, 'FontWeight', 'normal');
        xlabel(probability_axes, 'x', 'Color', C.muted);
        ylabel(probability_axes, 'Probabilidade', 'Color', C.muted);

        cla(real_axes);
        plot(real_axes, x, real(psi), ...
            'Color', C.cyan, 'LineWidth', 1.5);
        style_axes(real_axes, C);
        title(real_axes, 'Parte real da funcao de onda Re(psi)', ...
            'Color', C.text, 'FontWeight', 'normal');
        xlabel(real_axes, 'x', 'Color', C.muted);
        ylabel(real_axes, 'Amplitude', 'Color', C.muted);

        width_metric.Text = sprintf('%.4f', sigma_t);
        center_metric.Text = sprintf('%.4f', k_0 * time_value);
        norm_metric.Text = sprintf('%.6f', trapz(x, probability));
        wave_status.Text = 'Solucao analitica exata  ·  unidades naturais hbar = m = 1.';
    end

    function render_cosmology(varargin)
        try
            model = friedmann_background(omega_m_field.Value, ...
                omega_r_field.Value, omega_lambda_field.Value, 1400);

            cla(scale_axes);
            plot(scale_axes, model.dimensionless_time, model.scale_factor, ...
                'Color', C.amber, 'LineWidth', 1.8);
            style_axes(scale_axes, C);
            title(scale_axes, 'Fator de escala ao longo do tempo cosmico', ...
                'Color', C.text, 'FontWeight', 'normal');
            xlabel(scale_axes, 'H0 t', 'Color', C.muted);
            ylabel(scale_axes, 'a(t)', 'Color', C.muted);

            cla(hubble_axes);
            plot(hubble_axes, model.scale_factor, model.expansion_rate, ...
                'Color', C.cyan, 'LineWidth', 1.7);
            style_axes(hubble_axes, C);
            hubble_axes.XScale = 'log';
            hubble_axes.YScale = 'log';
            title(hubble_axes, 'Taxa de expansao normalizada E(a)', ...
                'Color', C.text, 'FontWeight', 'normal');
            xlabel(hubble_axes, 'Fator de escala a', 'Color', C.muted);
            ylabel(hubble_axes, 'H(a) / H0', 'Color', C.muted);

            cla(deceleration_axes);
            plot(deceleration_axes, model.dimensionless_time, model.deceleration, ...
                'Color', C.violet, 'LineWidth', 1.6);
            hold(deceleration_axes, 'on');
            yline(deceleration_axes, 0, ':', 'Color', C.muted);
            hold(deceleration_axes, 'off');
            style_axes(deceleration_axes, C);
            title(deceleration_axes, 'Transicao entre desaceleracao e aceleracao', ...
                'Color', C.text, 'FontWeight', 'normal');
            xlabel(deceleration_axes, 'Tempo cosmico H0 t', 'Color', C.muted);
            ylabel(deceleration_axes, 'Parametro de desaceleracao q(t)', ...
                'Color', C.muted);

            age_metric.Text = sprintf('%.4f', model.age_hubble_units);
            curvature_metric.Text = sprintf('%.4f', model.omega_k);
            acceleration_metric.Text = sprintf('%.4f', model.present_deceleration);
            cosmology_status.Text = ['Friedmann atualizado  ·  FLRW homogeneo/isotropico; ' ...
                'sem perturbacoes ou formacao de estruturas.'];
        catch problem
            cosmology_status.Text = 'Parametros invalidos para expansao real.';
            uialert(fig, problem.message, 'Falha no modelo cosmologico');
        end
    end

    function time_slider_changed(~, event)
        time_field.Value = event.Value;
        render_wave();
    end

    function time_field_changed(~, ~)
        time_slider.Value = time_field.Value;
        render_wave();
    end

    function run_fortran_wave(~, ~)
        if ispc
            locator = 'where gfortran';
            executable_name = 'free_wavepacket.exe';
        else
            locator = 'command -v gfortran';
            executable_name = 'free_wavepacket';
        end
        [compiler_status, compiler_location] = system(locator);
        if compiler_status ~= 0
            uialert(fig, ['Nao encontrei gfortran. Instale o compilador Fortran e ' ...
                'adicione-o ao PATH para habilitar esta comparacao.'], ...
                'Compilador Fortran ausente');
            return;
        end

        work_dir = tempname;
        mkdir(work_dir);
        cleanup_guard = onCleanup(@() remove_temp_directory(work_dir)); %#ok<NASGU>
        executable_path = fullfile(work_dir, executable_name);
        output_path = fullfile(work_dir, 'onda_fortran.dat');
        fortran_source = fullfile(project_dir, 'fortran', 'free_wavepacket.f90');
        compiler_parts = regexp(strtrim(compiler_location), '\r\n|\n|\r', 'split');
        compiler_name = compiler_parts{1};
        compile_command = sprintf('"%s" "%s" -o "%s"', ...
            compiler_name, fortran_source, executable_path);
        [compile_status, compile_message] = system(compile_command);
        if compile_status ~= 0
            uialert(fig, ['Falha ao compilar o modulo Fortran:' newline compile_message], ...
                'Falha de compilacao');
            return;
        end

        sigma_0 = sigma_field.Value;
        k_0 = wave_number_field.Value;
        time_value = time_field.Value;
        run_command = sprintf('"%s" %.17g %.17g %.17g "%s"', ...
            executable_path, sigma_0, k_0, time_value, output_path);
        [run_status, run_message] = system(run_command);
        if run_status ~= 0 || ~isfile(output_path)
            uialert(fig, ['Falha ao executar o modulo Fortran:' newline run_message], ...
                'Falha de execucao');
            return;
        end

        data = readmatrix(output_path);
        [~, matlab_probability] = free_wavepacket(data(:, 1).', ...
            sigma_0, k_0, time_value);
        maximum_error = max(abs(data(:, 3) - matlab_probability(:)));
        hold(probability_axes, 'on');
        plot(probability_axes, data(:, 1), data(:, 3), '--', ...
            'Color', C.amber, 'LineWidth', 1.4);
        hold(probability_axes, 'off');
        legend(probability_axes, {'MATLAB', 'Fortran'}, ...
            'TextColor', C.text, 'Color', C.panel_alt, 'Location', 'northeast');
        wave_status.Text = sprintf('Fortran x MATLAB  ·  erro maximo = %.3e', maximum_error);
    end

    function load_selected_source(varargin)
        if isempty(code_area) || ~isvalid(code_area)
            return;
        end
        labels = source_list.Items;
        paths = {fullfile(matlab_dir, 'run_su3_lattice.m'), ...
            fullfile(matlab_dir, 'validate_su3_gauge.m'), ...
            fullfile(matlab_dir, 'su3_plaquettes.m'), ...
            fullfile(matlab_dir, 'su3_random_haar.m'), ...
            fullfile(matlab_dir, 'free_wavepacket.m'), ...
            fullfile(matlab_dir, 'friedmann_background.m'), ...
            fullfile(project_dir, 'fortran', 'free_wavepacket.f90'), ...
            fullfile(project_dir, 'qsharp', 'ramsey_interferometry.qs'), ...
            fullfile(project_dir, 'systemverilog', 'complex_mul_q15.sv')};
        index = find(strcmp(labels, source_list.Value), 1);
        if isempty(index)
            return;
        end
        source = fileread(paths{index});
        code_area.Value = regexp(source, '\r\n|\n|\r', 'split');
        code_title.Text = ['SOURCE  /  ' upper(strtok(source_list.Value, ' ·'))];
    end

    function open_selected_source(~, ~)
        paths = selected_source_paths();
        index = find(strcmp(source_list.Items, source_list.Value), 1);
        if ~isempty(index) && exist(paths{index}, 'file')
            edit(paths{index});
        end
    end

    function copy_selected_source(~, ~)
        paths = selected_source_paths();
        index = find(strcmp(source_list.Items, source_list.Value), 1);
        if ~isempty(index) && exist(paths{index}, 'file')
            clipboard('copy', fileread(paths{index}));
        end
    end

    function paths = selected_source_paths()
        paths = {fullfile(matlab_dir, 'run_su3_lattice.m'), ...
            fullfile(matlab_dir, 'validate_su3_gauge.m'), ...
            fullfile(matlab_dir, 'su3_plaquettes.m'), ...
            fullfile(matlab_dir, 'su3_random_haar.m'), ...
            fullfile(matlab_dir, 'free_wavepacket.m'), ...
            fullfile(matlab_dir, 'friedmann_background.m'), ...
            fullfile(project_dir, 'fortran', 'free_wavepacket.f90'), ...
            fullfile(project_dir, 'qsharp', 'ramsey_interferometry.qs'), ...
            fullfile(project_dir, 'systemverilog', 'complex_mul_q15.sv')};
    end

    function remove_temp_directory(path)
        if exist(path, 'dir')
            rmdir(path, 's');
        end
    end
end
