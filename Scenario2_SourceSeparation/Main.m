% Main script to run the source separation experiment for 11 reference signals,
% each with 5 mixture cases (3, 5, 7, 9, 11 sources), compute mean/std of SDR and MSE,
% save reconstructed signals as .mat files, and display results with smooth interpolated plots.
% Plots exclude the Observation method.

clc; clear; close all;

% List of clean audio files (Voice Bank Corpus, ordered by size)
audio_files = {'p273_182.wav', 'p279_059.wav', 'p259_265.wav', 'p258_207.wav', ...
               'p276_276.wav', 'p250_226.wav', 'p228_035.wav', 'p287_277.wav', ...
               'p279_121.wav', 'p270_224.wav', 'p254_026.wav'};
num_refs = length(audio_files);
num_cases = 5; % 3, 5, 7, 9, 11 sources
source_counts = [3, 5, 7, 9, 11];

% Create main output directory if it doesn't exist
output_dir = 'results';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Initialize arrays for metrics (num_refs x num_cases)
metrics = struct();
methods = {'observe', 'gla', 'ot', 'dnn', 'admm', 'tesa'};
metrics.time.sdr = struct();
metrics.tf.mse = struct();
for method = methods
    metrics.time.sdr.(method{1}) = zeros(num_refs, num_cases);
    metrics.tf.mse.(method{1}) = zeros(num_refs, num_cases);
end

% Process each reference signal and mixture case
for ref_idx = 1:num_refs
    ref_file = fullfile('materials', audio_files{ref_idx});
    fprintf('Processing reference %d: %s\n', ref_idx, ref_file);
    
    for case_idx = 1:num_cases
        num_sources = source_counts(case_idx);
        % Select sources (reference + next files, wrapping around)
        source_indices = mod((ref_idx-1) + (0:num_sources-1), num_refs) + 1;
        source_files = audio_files(source_indices);
        
        % Load and align signals (convert to mono)
        [ref_signal, fs] = audioread(fullfile('materials', source_files{1}));
        if size(ref_signal, 2) > 1
            ref_signal = mean(ref_signal, 2); % Convert to mono
        end
        min_len = length(ref_signal);
        signals = cell(num_sources, 1);
        signals{1} = ref_signal;
        
        % Load other signals and find minimum length
        for i = 2:num_sources
            [sig, ~] = audioread(fullfile('materials', source_files{i}));
            if size(sig, 2) > 1
                sig = mean(sig, 2); % Convert to mono
            end
            signals{i} = sig;
            min_len = min(min_len, length(sig));
        end
        
        % Truncate all signals to minimum length
        ref_signal = ref_signal(1:min_len);
        for i = 1:num_sources
            signals{i} = signals{i}(1:min_len);
        end
        
        % Generate equal mixing coefficients
        mix_coeffs = ones(1, num_sources); % Equal weight of 1 for each source
        
        % Create mixture
        mixture = zeros(min_len, 1);
        for i = 1:num_sources
            mixture = mixture + mix_coeffs(i) * signals{i};
        end
        
        % Normalize mixture to prevent clipping
        mixture = rescale(mixture, -0.5, 0.5);
        
        % Save mixture temporarily
        mixture_file = fullfile(output_dir, sprintf('temp_mixture_ref%02d_case%d.wav', ref_idx, num_sources));
        audiowrite(mixture_file, mixture, fs);
        
        fprintf('  Case %d (%d sources): Processing mixture\n', case_idx, num_sources);
        try
            results = run_separation(mixture_file, ref_file);
        catch e
            fprintf('Error in separation for Ref %d, Case %d: %s\n', ref_idx, case_idx, e.message);
            continue;
        end
        
        % Store metrics
        for method = methods
            metrics.time.sdr.(method{1})(ref_idx, case_idx) = results.(sprintf('sdr_%s_time', method{1}));
            metrics.tf.mse.(method{1})(ref_idx, case_idx) = results.(sprintf('mse_%s_tf', method{1}));
        end
        
        % Display per-reference table
        fprintf('\nResults for Reference %d, Case %d (%d sources):\n', ref_idx, case_idx, num_sources);
        fprintf('--------------------------------------------------------\n');
        fprintf('%-20s %-20s %-20s\n', 'Method', 'Time SDR (dB)', 'TF MSE');
        fprintf('--------------------------------------------------------\n');
        for method = methods
            method_name = upper(method{1});
            if strcmp(method_name, 'OBSERVE')
                method_name = 'OBSERVE';
            elseif strcmp(method_name, 'TESA')
                method_name = 'TESA';
            else
                method_name = sprintf('%s', method_name);
            end
            time_sdr = results.(sprintf('sdr_%s_time', method{1}));
            tf_mse = results.(sprintf('mse_%s_tf', method{1}));
            fprintf('%-20s %4.4f %-12s %4.4e\n', method_name, time_sdr, '', tf_mse);
        end
        fprintf('--------------------------------------------------------\n');
        drawnow; % Force console output
        
        % Save reconstructed signals
        case_dir = fullfile(output_dir, sprintf('ref_%02d_case_%d', ref_idx, num_sources));
        if ~exist(case_dir, 'dir')
            mkdir(case_dir);
        end
        try
            save(fullfile(case_dir, sprintf('reconstructed_ref%02d_case%d.mat', ref_idx, num_sources)), ...
                 '-struct', 'results', 'x_gla', 'x_ot', 'x_dnn', 'x_admm', 'x_tesa');
            fprintf('  Saved reconstructed signals in %s\n', case_dir);
        catch e
            fprintf('Error saving Ref %d, Case %d: %s\n', ref_idx, case_idx, e.message);
        end
    end
end

% Save all metrics
try
    save(fullfile(output_dir, 'separation_results.mat'), 'metrics', 'source_counts');
    fprintf('Saved all metrics to %s\n', output_dir);
catch e
    fprintf('Error saving metrics: %s\n', e.message);
end

% Display and save combined results
for case_idx = 1:num_cases
    num_sources = source_counts(case_idx);
    fprintf('\nCombined Results for Case %d (%d sources):\n', case_idx, num_sources);
    fprintf('--------------------------------------------------------\n');
    fprintf('%-20s %-20s %-20s\n', 'Method', 'Time SDR (dB)', 'TF MSE');
    fprintf('--------------------------------------------------------\n');
    
    fileID = fopen(fullfile(output_dir, sprintf('results_case_%d.txt', num_sources)), 'w', 'n', 'UTF-8');
    fprintf(fileID, 'Combined Results for Case %d (%d sources):\n', case_idx, num_sources);
    fprintf(fileID, '--------------------------------------------------------\n');
    fprintf(fileID, '%-20s %-20s %-20s\n', 'Method', 'Time SDR (dB)', 'TF MSE');
    fprintf(fileID, '--------------------------------------------------------\n');
    
    for method = methods
        method_name = upper(method{1});
        if strcmp(method_name, 'OBSERVE')
            method_name = 'OBSERVE';
        elseif strcmp(method_name, 'TESA')
            method_name = 'TESA';
        else
            method_name = sprintf('%s', method_name);
        end
        time_sdr_mean = mean(metrics.time.sdr.(method{1})(:, case_idx));
        time_sdr_std = std(metrics.time.sdr.(method{1})(:, case_idx));
        tf_mse_mean = mean(metrics.tf.mse.(method{1})(:, case_idx));
        tf_mse_std = std(metrics.tf.mse.(method{1})(:, case_idx));
        
        fprintf('%-20s %4.4f±%4.4f %-12s %4.4e±%4.4e\n', ...
            method_name, time_sdr_mean, time_sdr_std, '', tf_mse_mean, tf_mse_std);
        fprintf(fileID, '%-20s %4.4f±%4.4f %-12s %4.4e±%4.4e\n', ...
            method_name, time_sdr_mean, time_sdr_std, '', tf_mse_mean, tf_mse_std);
    end
    
    fprintf('--------------------------------------------------------\n');
    fprintf(fileID, '--------------------------------------------------------\n');
    fclose(fileID);
    fprintf('Results saved to %s\n', fullfile(output_dir, sprintf('results_case_%d.txt', num_sources)));
end

% Smooth interpolated plots (excluding Observation)
plot_methods = {'gla', 'ot', 'dnn', 'admm', 'tesa'};
methods_display = {'GLA', 'OT', 'DNN', 'ADMM', 'TESA'};
line_styles = {'--', ':', '-.', '--', ':'};
markers = {'s', 'd', '^', 'v', 'o'};
marker_sizes = [6, 6, 6, 6, 6];
line_widths = [2, 2, 2, 2, 2];

x_fine = linspace(min(source_counts), max(source_counts), 100); % Fine grid for interpolation
figure('Name', 'SDR vs Number of Sources (Time Domain)', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 400]);
hold on;
colors = gray(length(plot_methods) + 1); % Grayscale colormap
for m = 1:length(plot_methods)
    mean_sdr = mean(metrics.time.sdr.(plot_methods{m}), 1);
    sdr_interp = interp1(source_counts, mean_sdr, x_fine, 'pchip');
    plot(x_fine, sdr_interp, 'LineStyle', line_styles{m}, 'Marker', markers{m}, ...
         'MarkerIndices', 1:10:length(x_fine), 'MarkerSize', marker_sizes(m), ...
         'LineWidth', line_widths(m), 'Color', colors(ceil(m^0.5), :), 'DisplayName', methods_display{m});
end
legend('show', 'Location', 'best');
title('SDR (Time Domain) Across Number of Sources');
xlabel('Number of Sources'); ylabel('SDR (dB)'); grid on;
set(gca, 'XTick', source_counts);
try
    if exist('exportgraphics', 'file')
        exportgraphics(gcf, fullfile(output_dir, 'time_domain_sdr_sources.png'), 'Resolution', 300, 'ContentType', 'image');
    else
        print(gcf, fullfile(output_dir, 'time_domain_sdr_sources.png'), '-dpng', '-r300');
    end
catch e
    fprintf('Error saving time domain plot: %s\n', e.message);
end

figure('Name', 'MSE vs Number of Sources (Time-Frequency Domain)', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 400]);
hold on;
for m = 1:length(plot_methods)
    mean_mse = mean(metrics.tf.mse.(plot_methods{m}), 1);
    mse_interp = interp1(source_counts, mean_mse, x_fine, 'pchip');
    plot(x_fine, mse_interp, 'LineStyle', line_styles{m}, 'Marker', markers{m}, ...
         'MarkerIndices', 1:10:length(x_fine), 'MarkerSize', marker_sizes(m), ...
         'LineWidth', line_widths(m), 'Color', colors(ceil(m^0.5), :), 'DisplayName', methods_display{m});
end
legend('show', 'Location', 'best');
title('MSE (Time-Frequency Domain) Across Number of Sources');
xlabel('Number of Sources'); ylabel('MSE'); grid on;
set(gca, 'XTick', source_counts);
try
    if exist('exportgraphics', 'file')
        exportgraphics(gcf, fullfile(output_dir, 'tf_domain_mse_sources.png'), 'Resolution', 300, 'ContentType', 'image');
    else
        print(gcf, fullfile(output_dir, 'tf_domain_mse_sources.png'), '-dpng', '-r300');
    end
catch e
    fprintf('Error saving TF domain plot: %s\n', e.message);
end

fprintf('Check %s for reconstructed signals, metrics, and plots.\n', output_dir);