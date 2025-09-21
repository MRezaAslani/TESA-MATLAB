% Main script to run the noise reduction experiment for 10 audio pairs
% across 6 Signal-to-Noise Ratio (SNR) levels (-50, -40, -30, -20, -10, 0 dB),
% compute mean/std of SNR for time domain and MSE for time-frequency (TF) domain,
% save reconstructed signals as .mat files,
% display per-pair SNR/MSE tables and a combined table,
% save combined table to text file, and generate smooth interpolated plots
% with distinct line styles and markers for grayscale compatibility.
% Plots exclude the Observation method.

clc; clear; close all;

% Create output directory if it doesn't exist
output_dir = 'results';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Define audio file pairs (only clean files needed; noise will be generated)
clean_files = {
    'clean_p250_361.wav';
    'clean_p254_097.wav';
    'clean_p254_115.wav';
    'clean_p258_248.wav';
    'clean_p269_026.wav';
    'clean_p273_293.wav';
    'clean_p277_125.wav';
    'clean_p279_053.wav';
    'clean_p279_298.wav';
    'clean_p287_332.wav'
};

% Define Signal-to-Noise Ratio (SNR) levels (dB)
snr_levels = [-50, -40, -30, -20, -10, 0];
num_snr_levels = length(snr_levels);
num_pairs = length(clean_files);

% Initialize storage for SNR (time domain) and MSE (TF domain) metrics
metrics = struct();
methods = {'observe', 'gla', 'ot', 'dnn', 'admm', 'tesa'};
metrics.time.snr = struct();
metrics.tf.mse = struct();
for method = methods
    metrics.time.snr.(method{1}) = zeros(num_pairs, num_snr_levels);
    metrics.tf.mse.(method{1}) = zeros(num_pairs, num_snr_levels);
end

% Process each audio pair and each SNR level
for snr_idx = 1:num_snr_levels
    snr_db = snr_levels(snr_idx);
    fprintf('Processing SNR level: %d dB\n', snr_db);
    
    % Create subdirectory for this SNR level
    snr_dir = fullfile(output_dir, sprintf('snr_%ddB', snr_db));
    if ~exist(snr_dir, 'dir')
        mkdir(snr_dir);
    end
    
    for k = 1:num_pairs
        clean_file = fullfile('materials', clean_files{k});
        
        % Load clean signal
        try
            [clean_speech, fs] = audioread(clean_file);
        catch e
            fprintf('Error loading Pair %d: %s\n', k, e.message);
            continue;
        end
        
        % Downsample if needed
        ndown = 1;
        clean_speech = clean_speech(1:ndown:end);
        fs = fs/ndown;
        
        % Align length
        try
            [S_clean, ~, ~] = stft(clean_speech, fs, 'Window', hamming(512), 'OverlapLength', round(0.85*512), 'FFTLength', 512);
            min_len = length(istft(S_clean, fs, 'Window', hamming(512), 'OverlapLength', round(0.85*512), 'FFTLength', 512));
            clean_speech = clean_speech(1:min_len);
        catch e
            fprintf('Error in STFT for Pair %d: %s\n', k, e.message);
            continue;
        end
        
        % Ensure zero-mean for clean signal
        clean_speech = clean_speech - mean(clean_speech);
        
        % Generate white noise with reproducible RNG
        rng(k); % Seed for reproducibility
        noise = randn(size(clean_speech));
        noise = noise - mean(noise); % Ensure zero-mean noise
        
        % Scale noise to achieve exact target SNR
        Ps = var(clean_speech); % Signal variance
        SNR_lin = 10^(snr_db/10); % Linear SNR
        sigma_n = sqrt(Ps / SNR_lin); % Desired noise standard deviation
        scaled_noise = sigma_n * noise / sqrt(var(noise)); % Scale noise
        new_noisy_speech = clean_speech + scaled_noise;
        
        % Run the denoising function
        fprintf('Processing pair %d\n', k);
        try
            results = run_denoising(new_noisy_speech, clean_speech, fs);
        catch e
            fprintf('Error in denoising Pair %d: %s\n', k, e.message);
            continue;
        end
        
        % Store SNR (time) and MSE (TF) metrics
        for method = methods
            metrics.time.snr.(method{1})(k, snr_idx) = results.(sprintf('snr_%s_time', method{1}));
            metrics.tf.mse.(method{1})(k, snr_idx) = results.(sprintf('mse_%s_tf', method{1}));
        end
        
        % Display per-pair SNR/MSE table
        fprintf('\nSNR/MSE Metrics for Pair %d (SNR = %d dB)\n', k, snr_db);
        fprintf('--------------------------------------------------------\n');
        fprintf('%-20s %-20s %-20s\n', 'Method', 'Time SNR (dB)', 'TF MSE');
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
            time_snr = results.(sprintf('snr_%s_time', method{1}));
            tf_mse = results.(sprintf('mse_%s_tf', method{1}));
            fprintf('%-20s %4.4f %-12s %4.4f\n', method_name, time_snr, '', tf_mse);
        end
        fprintf('--------------------------------------------------------\n');
        drawnow; % Force console output
        
        % Save reconstructed signals
        try
            save(fullfile(snr_dir, sprintf('reconstructed_Pair%02d_snr%ddB.mat', k, snr_db)), ...
                 '-struct', 'results', 'x_gla', 'x_ot', 'x_dnn', 'x_admm', 'x_tesa');
            fprintf('Saved reconstructed signals for Pair%02d\n', k);
        catch e
            fprintf('Error saving Pair %d: %s\n', k, e.message);
        end
    end
    
    % Debug: Check if metrics are populated
    fprintf('\nDebug: Metrics for SNR %d dB\n', snr_db);
    for method = methods
        fprintf('  %s: Time SNR = %s, TF MSE = %s\n', method{1}, ...
            num2str(metrics.time.snr.(method{1})(:, snr_idx)'), ...
            num2str(metrics.tf.mse.(method{1})(:, snr_idx)'));
    end
    
    % Display and save combined SNR/MSE metrics table
    fileID = fopen(fullfile(snr_dir, sprintf('results_snr_%ddB.txt', snr_db)), 'w', 'n', 'UTF-8');
    
    fprintf(fileID, 'SNR/MSE Metrics (SNR = %d dB)\n', snr_db);
    fprintf(fileID, '--------------------------------------------------------\n');
    fprintf(fileID, '%-20s %-20s %-20s\n', 'Method', 'Time SNR (dB)', 'TF MSE');
    fprintf(fileID, '--------------------------------------------------------\n');
    
    fprintf('\nSNR/MSE Metrics (SNR = %d dB)\n', snr_db);
    fprintf('--------------------------------------------------------\n');
    fprintf('%-20s %-20s %-20s\n', 'Method', 'Time SNR (dB)', 'TF MSE');
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
        time_snr_mean = mean(metrics.time.snr.(method{1})(:, snr_idx));
        time_snr_std = std(metrics.time.snr.(method{1})(:, snr_idx));
        tf_mse_mean = mean(metrics.tf.mse.(method{1})(:, snr_idx));
        tf_mse_std = std(metrics.tf.mse.(method{1})(:, snr_idx));
        
        fprintf(fileID, '%-20s %4.4f±%4.4f %-12s %4.4f±%4.4f\n', ...
            method_name, time_snr_mean, time_snr_std, '', tf_mse_mean, tf_mse_std);
        fprintf('%-20s %4.4f±%4.4f %-12s %4.4f±%4.4f\n', ...
            method_name, time_snr_mean, time_snr_std, '', tf_mse_mean, tf_mse_std);
    end
    
    fprintf(fileID, '--------------------------------------------------------\n');
    fprintf('--------------------------------------------------------\n');
    drawnow; % Force console output
    fclose(fileID);
    fprintf('Results saved to %s\n\n', snr_dir);
end

% Save all SNR/MSE metrics
try
    save(fullfile(output_dir, 'denoising_results_all_snr_mse.mat'), 'metrics', 'snr_levels');
    fprintf('Saved all metrics to %s\n', output_dir);
catch e
    fprintf('Error saving metrics: %s\n', e.message);
end

% Define line styles and markers for grayscale compatibility (excluding Observation)
line_styles = {'--', ':', '-.', '--', ':'};
markers = {'s', 'd', '^', 'v', 'o'};
marker_sizes = [6, 6, 6, 6, 6];
line_widths = [2, 2, 2, 2, 2];

% Smooth interpolated plots
x_fine = linspace(min(snr_levels), max(snr_levels), 100); % Fine grid for interpolation
methods_display = {'GLA', 'OT', 'DNN', 'ADMM', 'TESA'};
plot_methods = {'gla', 'ot', 'dnn', 'admm', 'tesa'}; % Exclude 'observe'

% Time Domain Plot
figure('Name', 'SNR Across Levels (Time Domain)', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 400]);
hold on;
colors = gray(length(plot_methods) + 1); % Grayscale colormap for testing
for m = 1:length(plot_methods)
    mean_snr = mean(metrics.time.snr.(plot_methods{m}), 1);
    snr_interp = interp1(snr_levels, mean_snr, x_fine, 'pchip');
    plot(x_fine, snr_interp, 'LineStyle', line_styles{m}, 'Marker', markers{m}, ...
         'MarkerIndices', 1:10:length(x_fine), 'MarkerSize', marker_sizes(m), ...
         'LineWidth', line_widths(m), 'Color', colors(ceil(m^0.5), :), 'DisplayName', methods_display{m});
end
legend('show', 'Location', 'best');
title('SNR (Time Domain) Across Signal-to-Noise Ratio Levels');
xlabel('Signal-to-Noise Ratio (dB)'); ylabel('SNR (dB)'); grid on;

% Save the figure
try
    if exist('exportgraphics', 'file')
        exportgraphics(gcf, fullfile(output_dir, 'time_domain_metrics_snr_levels.png'), 'Resolution', 300, 'ContentType', 'image');
    else
        print(gcf, fullfile(output_dir, 'time_domain_metrics_snr_levels.png'), '-dpng', '-r300');
    end
catch e
    fprintf('Error saving time domain plot: %s\n', e.message);
end

% Time-Frequency Domain Plot
figure('Name', 'MSE Across Levels (Time-Frequency Domain)', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 400]);
hold on;
for m = 1:length(plot_methods)
    mean_mse = mean(metrics.tf.mse.(plot_methods{m}), 1);
    mse_interp = interp1(snr_levels, mean_mse, x_fine, 'pchip');
    plot(x_fine, mse_interp, 'LineStyle', line_styles{m}, 'Marker', markers{m}, ...
         'MarkerIndices', 1:10:length(x_fine), 'MarkerSize', marker_sizes(m), ...
         'LineWidth', line_widths(m), 'Color', colors(ceil(m^0.5), :), 'DisplayName', methods_display{m});
end
legend('show', 'Location', 'best');
title('MSE (Time-Frequency Domain) Across Signal-to-Noise Ratio Levels');
xlabel('Signal-to-Noise Ratio (dB)'); ylabel('MSE'); grid on;

% Save the figure
try
    if exist('exportgraphics', 'file')
        exportgraphics(gcf, fullfile(output_dir, 'tf_domain_metrics_mse_levels.png'), 'Resolution', 300, 'ContentType', 'image');
    else
        print(gcf, fullfile(output_dir, 'tf_domain_metrics_mse_levels.png'), '-dpng', '-r300');
    end
catch e
    fprintf('Error saving TF domain plot: %s\n', e.message);
end

fprintf('Check %s for reconstructed signals, metrics, and plots.\n', output_dir);