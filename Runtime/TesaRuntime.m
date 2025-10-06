% This script measures the runtime of the TESA algorithm for signal lengths from 10000 to 100000 in steps of 10000.
% It generates synthetic signals, runs TESA multiple times (3 runs) for each of multiple STFT resolutions, measures average time, and saves the results in a combined table in the 'rresults' folder.
% Additionally, it plots the average runtime vs. signal length for all resolutions on a single figure and saves the plot.
clc; clear; close all
% Define signal lengths
signal_lengths = 0:100000:1000000;
signal_lengths(1) = [];

% Number of runs for averaging
num_runs = 100;

% Define multiple STFT resolutions
resolutions = {
    struct('win_len', 512, 'noverlap_factor', 0.85, 'label', 'Win512_Overlap85');
    struct('win_len', 384, 'noverlap_factor', 0.80, 'label', 'Win384_Overlap80');
    struct('win_len', 256, 'noverlap_factor', 0.70, 'label', 'Win256_Overlap70');
    struct('win_len', 128, 'noverlap_factor', 0.50, 'label', 'Win128_Overlap50');
};
num_res = length(resolutions);

% Debug: Check resolutions structure
disp('Resolutions defined:');
for i = 1:num_res
    disp(resolutions{i});
end
labels = cellfun(@(r) r.label, resolutions, 'UniformOutput', false);
labels = labels(:)';  % Transpose to ensure 1xN row cell array
disp('Extracted labels:');
disp(labels);

% Preallocate table
num_lengths = length(signal_lengths);
var_names = [{'Length'}, labels]; % Simplified concatenation
runtime_table = table('Size', [num_lengths, num_res + 1], ...
                     'VariableTypes', repmat({'double'}, 1, num_res + 1), ...
                     'VariableNames', var_names, ...
                     'RowNames', arrayfun(@num2str, signal_lengths, 'UniformOutput', false));

% TESA Parameters (common for all)
lambda = 0;
alpha = 1;
num_iter = 1;
beta1 = 0.9;
beta2 = 0.999;

% Create output directory
output_dir = 'Results';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Loop over resolutions
for res_idx = 1:num_res
    res = resolutions{res_idx};
    win_len = res.win_len;
    noverlap = round(res.noverlap_factor * win_len);
    nfft = win_len;
    window = hamming(win_len);

    % Loop over signal lengths
    for i = 1:num_lengths
        len = signal_lengths(i);
        if res_idx == 1
            runtime_table.Length(i) = len;
        end

        % Generate synthetic clean and damaged signals
        clean_signal = rand(len, 1);  % Random signal as placeholder for clean
        damaged_signal = clean_signal;
        damaged_signal(1:round(0.5*len)) = 0;  % Simulate damage by zeroing half

        fs = len;  % Sampling rate as length, per original code

        % Length Alignment to ensure inverse STFT matches original length
        [S_clean, ~, ~] = stft(clean_signal, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
        min_len = length(istft(S_clean, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));

        clean_signal = clean_signal(1:min_len);
        damaged_signal = damaged_signal(1:min_len);

        % Recompute STFT after length alignment
        [S_clean, ~, ~] = stft(clean_signal, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
        target_spectrogram = abs(S_clean);

        % Measure average runtime for TESA over num_runs
        tesa_times = zeros(num_runs, 1);
        stft_params = struct('fs', fs, 'window', window, 'noverlap', noverlap, 'nfft', nfft);
        tesa_params = struct('lambda', lambda, 'alpha', alpha, 'num_iter', num_iter, ...
                             'beta1', beta1, 'beta2', beta2);
        for r = 1:num_runs
            tic;
            x_tesa = tesa(damaged_signal, target_spectrogram, stft_params, tesa_params);
            tesa_times(r) = toc;
        end
        runtime_table.(res.label)(i) = mean(tesa_times);

        fprintf('Completed for length %d and resolution %s\n', len, res.label);
    end
end

% Display table
disp(runtime_table);

% Save table as CSV
output_file_csv = fullfile(output_dir, 'runtime_table_tesa_multi_res.csv');
writetable(runtime_table, output_file_csv, 'WriteRowNames', true);
fprintf('Saved runtime table to %s\n', output_file_csv);

% Plot the runtime vs. signal length for all resolutions
figure('Name', 'Runtime vs. Signal Length for TESA (Multiple Resolutions)', 'NumberTitle', 'off');
hold on;
colors = lines(num_res);  % Get distinct colors
markers = {'o', 's', 'd', '^'};  % Distinct markers

for res_idx = 1:num_res
    res = resolutions{res_idx};
    plot(signal_lengths, runtime_table.(res.label), ...
         'LineWidth', 1.5, 'Color', colors(res_idx,:), ...
         'Marker', markers{res_idx}, 'MarkerSize', 6, ...
         'DisplayName', res.label);
end

xlabel('Signal Length');
ylabel('Average Runtime (seconds)');
title('Average Runtime of TESA vs. Signal Length (Multiple Resolutions)');
legend('Location', 'northwest');
grid on;
hold off;

% Save the plot
output_file_plot = fullfile(output_dir, 'runtime_plot_tesa_multi_res.png');
saveas(gcf, output_file_plot);
fprintf('Saved runtime plot to %s\n', output_file_plot);