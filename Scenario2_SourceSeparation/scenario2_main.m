% Main script to run the experiment for 12 mixtures with 3 sources each, compute mean/std of metrics,
% save reconstructed signals as .mat files, and display results

clc; clear; close all;

% Create output directory if it doesn't exist
output_dir = 'results';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Initialize arrays for each metric (12 mixtures x 3 sources)
snr_observe_time = zeros(12, 3);
snr_gla_time = zeros(12, 3);
snr_ot_time = zeros(12, 3);
snr_dnn_time = zeros(12, 3);
snr_admm_time = zeros(12, 3);
snr_tesa_time = zeros(12, 3);
mse_observe_time = zeros(12, 3);
mse_gla_time = zeros(12, 3);
mse_ot_time = zeros(12, 3);
mse_dnn_time = zeros(12, 3);
mse_admm_time = zeros(12, 3);
mse_tesa_time = zeros(12, 3);
pcc_observe_time = zeros(12, 3);
pcc_gla_time = zeros(12, 3);
pcc_ot_time = zeros(12, 3);
pcc_dnn_time = zeros(12, 3);
pcc_admm_time = zeros(12, 3);
pcc_tesa_time = zeros(12, 3);
snr_observe_tf = zeros(12, 3);
snr_gla_tf = zeros(12, 3);
snr_ot_tf = zeros(12, 3);
snr_dnn_tf = zeros(12, 3);
snr_admm_tf = zeros(12, 3);
snr_tesa_tf = zeros(12, 3);
mse_observe_tf = zeros(12, 3);
mse_gla_tf = zeros(12, 3);
mse_ot_tf = zeros(12, 3);
mse_dnn_tf = zeros(12, 3);
mse_admm_tf = zeros(12, 3);
mse_tesa_tf = zeros(12, 3);
pcc_observe_tf = zeros(12, 3);
pcc_gla_tf = zeros(12, 3);
pcc_ot_tf = zeros(12, 3);
pcc_dnn_tf = zeros(12, 3);
pcc_admm_tf = zeros(12, 3);
pcc_tesa_tf = zeros(12, 3);

% Run the experiment for each mixture and source
for k = 1:12
    for p = 1:3
        mixture_file = sprintf('materials/PER3_Mix%02d.wav', k);
        source_file = sprintf('materials/PER3_Mix%02d_S%d.wav', k, p);
        
        fprintf('Processing mixture %d, source %d: %s and %s\n', k, p, mixture_file, source_file);
        results = run_separation(mixture_file, source_file);
        
        % Store metrics
        snr_observe_time(k, p) = results.snr_observe_time;
        snr_gla_time(k, p) = results.snr_gla_time;
        snr_ot_time(k, p) = results.snr_ot_time;
        snr_dnn_time(k, p) = results.snr_dnn_time;
        snr_admm_time(k, p) = results.snr_admm_time;
        snr_tesa_time(k, p) = results.snr_tesa_time;
        
        mse_observe_time(k, p) = results.mse_observe_time;
        mse_gla_time(k, p) = results.mse_gla_time;
        mse_ot_time(k, p) = results.mse_ot_time;
        mse_dnn_time(k, p) = results.mse_dnn_time;
        mse_admm_time(k, p) = results.mse_admm_time;
        mse_tesa_time(k, p) = results.mse_tesa_time;
        
        pcc_observe_time(k, p) = results.pcc_observe_time;
        pcc_gla_time(k, p) = results.pcc_gla_time;
        pcc_ot_time(k, p) = results.pcc_ot_time;
        pcc_dnn_time(k, p) = results.pcc_dnn_time;
        pcc_admm_time(k, p) = results.pcc_admm_time;
        pcc_tesa_time(k, p) = results.pcc_tesa_time;
        
        snr_observe_tf(k, p) = results.snr_observe_tf;
        snr_gla_tf(k, p) = results.snr_gla_tf;
        snr_ot_tf(k, p) = results.snr_ot_tf;
        snr_dnn_tf(k, p) = results.snr_dnn_tf;
        snr_admm_tf(k, p) = results.snr_admm_tf;
        snr_tesa_tf(k, p) = results.snr_tesa_tf;
        
        mse_observe_tf(k, p) = results.mse_observe_tf;
        mse_gla_tf(k, p) = results.mse_gla_tf;
        mse_ot_tf(k, p) = results.mse_ot_tf;
        mse_dnn_tf(k, p) = results.mse_dnn_tf;
        mse_admm_tf(k, p) = results.mse_admm_tf;
        mse_tesa_tf(k, p) = results.mse_tesa_tf;
        
        pcc_observe_tf(k, p) = results.pcc_observe_tf;
        pcc_gla_tf(k, p) = results.pcc_gla_tf;
        pcc_ot_tf(k, p) = results.pcc_ot_tf;
        pcc_dnn_tf(k, p) = results.pcc_dnn_tf;
        pcc_admm_tf(k, p) = results.pcc_admm_tf;
        pcc_tesa_tf(k, p) = results.pcc_tesa_tf;
        
        % Save reconstructed signals as .mat files
        x_gla = results.x_gla;
        x_ot = results.x_ot;
        x_dnn = results.x_dnn;
        x_admm = results.x_admm;
        x_tesa = results.x_tesa;
        save(fullfile(output_dir, sprintf('reconstructed_Mix%02d_S%d.mat', k, p)), ...
             'x_gla', 'x_ot', 'x_dnn', 'x_admm', 'x_tesa');
        fprintf('Saved reconstructed signals for Mix%02d_S%d in %s\n', k, p, output_dir);
    end
end

% Save all results to a file
save(fullfile(output_dir, 'separation_results.mat'), '-regexp', '^(snr_|mse_|pcc_).*');

% Display average results with std for Time-Series Metrics
fprintf('\n----- Time-Series Metrics -----\n');
fprintf(['S1_PCC: %2.4f±%2.4f | S1_MSE: %.2e±%.2e | S1_SNR(db): %4.4f±%4.4f ||| ' ...
         'S2_PCC: %2.4f±%2.4f | S2_MSE: %.2e±%.2e | S2_SNR(db): %4.4f±%4.4f ||| ' ...
         'S3_PCC: %2.4f±%2.4f | S3_MSE: %.2e±%.2e | S3_SNR(db): %4.4f±%4.4f  (Observation)\n'], ...
    mean(pcc_observe_time(:,1)), std(pcc_observe_time(:,1)), mean(mse_observe_time(:,1)), std(mse_observe_time(:,1)), mean(snr_observe_time(:,1)), std(snr_observe_time(:,1)),...
    mean(pcc_observe_time(:,2)), std(pcc_observe_time(:,2)), mean(mse_observe_time(:,2)), std(mse_observe_time(:,2)), mean(snr_observe_time(:,2)), std(snr_observe_time(:,2)),...
    mean(pcc_observe_time(:,3)), std(pcc_observe_time(:,3)), mean(mse_observe_time(:,3)), std(mse_observe_time(:,3)), mean(snr_observe_time(:,3)), std(snr_observe_time(:,3)));

fprintf(['S1_PCC: %2.4f±%2.4f | S1_MSE: %.2e±%.2e | S1_SNR(db): %4.4f±%4.4f ||| ' ...
         'S2_PCC: %2.4f±%2.4f | S2_MSE: %.2e±%.2e | S2_SNR(db): %4.4f±%4.4f ||| ' ...
         'S3_PCC: %2.4f±%2.4f | S3_MSE: %.2e±%.2e | S3_SNR(db): %4.4f±%4.4f  (GLA Method)\n'], ...
    mean(pcc_gla_time(:,1)), std(pcc_gla_time(:,1)), mean(mse_gla_time(:,1)), std(mse_gla_time(:,1)), mean(snr_gla_time(:,1)), std(snr_gla_time(:,1)),...
    mean(pcc_gla_time(:,2)), std(pcc_gla_time(:,2)), mean(mse_gla_time(:,2)), std(mse_gla_time(:,2)), mean(snr_gla_time(:,2)), std(snr_gla_time(:,2)),...
    mean(pcc_gla_time(:,3)), std(pcc_gla_time(:,3)), mean(mse_gla_time(:,3)), std(mse_gla_time(:,3)), mean(snr_gla_time(:,3)), std(snr_gla_time(:,3)));

fprintf(['S1_PCC: %2.4f±%2.4f | S1_MSE: %.2e±%.2e | S1_SNR(db): %4.4f±%4.4f ||| ' ...
         'S2_PCC: %2.4f±%2.4f | S2_MSE: %.2e±%.2e | S2_SNR(db): %4.4f±%4.4f ||| ' ...
         'S3_PCC: %2.4f±%2.4f | S3_MSE: %.2e±%.2e | S3_SNR(db): %4.4f±%4.4f  (OT Method)\n'], ...
    mean(pcc_ot_time(:,1)), std(pcc_ot_time(:,1)), mean(mse_ot_time(:,1)), std(mse_ot_time(:,1)), mean(snr_ot_time(:,1)), std(snr_ot_time(:,1)),...
    mean(pcc_ot_time(:,2)), std(pcc_ot_time(:,2)), mean(mse_ot_time(:,2)), std(mse_ot_time(:,2)), mean(snr_ot_time(:,2)), std(snr_ot_time(:,2)),...
    mean(pcc_ot_time(:,3)), std(pcc_ot_time(:,3)), mean(mse_ot_time(:,3)), std(mse_ot_time(:,3)), mean(snr_ot_time(:,3)), std(snr_ot_time(:,3)));

fprintf(['S1_PCC: %2.4f±%2.4f | S1_MSE: %.2e±%.2e | S1_SNR(db): %4.4f±%4.4f ||| ' ...
         'S2_PCC: %2.4f±%2.4f | S2_MSE: %.2e±%.2e | S2_SNR(db): %4.4f±%4.4f ||| ' ...
         'S3_PCC: %2.4f±%2.4f | S3_MSE: %.2e±%.2e | S3_SNR(db): %4.4f±%4.4f  (DNN Method)\n'], ...
    mean(pcc_dnn_time(:,1)), std(pcc_dnn_time(:,1)), mean(mse_dnn_time(:,1)), std(mse_dnn_time(:,1)), mean(snr_dnn_time(:,1)), std(snr_dnn_time(:,1)),...
    mean(pcc_dnn_time(:,2)), std(pcc_dnn_time(:,2)), mean(mse_dnn_time(:,2)), std(mse_dnn_time(:,2)), mean(snr_dnn_time(:,2)), std(snr_dnn_time(:,2)),...
    mean(pcc_dnn_time(:,3)), std(pcc_dnn_time(:,3)), mean(mse_dnn_time(:,3)), std(mse_dnn_time(:,3)), mean(snr_dnn_time(:,3)), std(snr_dnn_time(:,3)));

fprintf(['S1_PCC: %2.4f±%2.4f | S1_MSE: %.2e±%.2e | S1_SNR(db): %4.4f±%4.4f ||| ' ...
         'S2_PCC: %2.4f±%2.4f | S2_MSE: %.2e±%.2e | S2_SNR(db): %4.4f±%4.4f ||| ' ...
         'S3_PCC: %2.4f±%2.4f | S3_MSE: %.2e±%.2e | S3_SNR(db): %4.4f±%4.4f  (ADMM Method)\n'], ...
    mean(pcc_admm_time(:,1)), std(pcc_admm_time(:,1)), mean(mse_admm_time(:,1)), std(mse_admm_time(:,1)), mean(snr_admm_time(:,1)), std(snr_admm_time(:,1)),...
    mean(pcc_admm_time(:,2)), std(pcc_admm_time(:,2)), mean(mse_admm_time(:,2)), std(mse_admm_time(:,2)), mean(snr_admm_time(:,2)), std(snr_admm_time(:,2)),...
    mean(pcc_admm_time(:,3)), std(pcc_admm_time(:,3)), mean(mse_admm_time(:,3)), std(mse_admm_time(:,3)), mean(snr_admm_time(:,3)), std(snr_admm_time(:,3)));

fprintf(['S1_PCC: %2.4f±%2.4f | S1_MSE: %.2e±%.2e | S1_SNR(db): %4.4f±%4.4f ||| ' ...
         'S2_PCC: %2.4f±%2.4f | S2_MSE: %.2e±%.2e | S2_SNR(db): %4.4f±%4.4f ||| ' ...
         'S3_PCC: %2.4f±%2.4f | S3_MSE: %.2e±%.2e | S3_SNR(db): %4.4f±%4.4f  (TESA Method)\n'], ...
    mean(pcc_tesa_time(:,1)), std(pcc_tesa_time(:,1)), mean(mse_tesa_time(:,1)), std(mse_tesa_time(:,1)), mean(snr_tesa_time(:,1)), std(snr_tesa_time(:,1)),...
    mean(pcc_tesa_time(:,2)), std(pcc_tesa_time(:,2)), mean(mse_tesa_time(:,2)), std(mse_tesa_time(:,2)), mean(snr_tesa_time(:,2)), std(snr_tesa_time(:,2)),...
    mean(pcc_tesa_time(:,3)), std(pcc_tesa_time(:,3)), mean(mse_tesa_time(:,3)), std(mse_tesa_time(:,3)), mean(snr_tesa_time(:,3)), std(snr_tesa_time(:,3)));

fprintf('\n*************************************************');
fprintf('\n                      ****          \n');
fprintf('*************************************************\n');

fprintf('\n----- Spectrogram Metrics -----\n');
fprintf(['S1_PCC: %2.4f±%2.4f | S1_MSE: %.2e±%.2e | S1_SNR(db): %4.4f±%4.4f ||| ' ...
         'S2_PCC: %2.4f±%2.4f | S2_MSE: %.2e±%.2e | S2_SNR(db): %4.4f±%4.4f ||| ' ...
         'S3_PCC: %2.4f±%2.4f | S3_MSE: %.2e±%.2e | S3_SNR(db): %4.4f±%4.4f  (Observation)\n'], ...
    mean(pcc_observe_tf(:,1)), std(pcc_observe_tf(:,1)), mean(mse_observe_tf(:,1)), std(mse_observe_tf(:,1)), mean(snr_observe_tf(:,1)), std(snr_observe_tf(:,1)),...
    mean(pcc_observe_tf(:,2)), std(pcc_observe_tf(:,2)), mean(mse_observe_tf(:,2)), std(mse_observe_tf(:,2)), mean(snr_observe_tf(:,2)), std(snr_observe_tf(:,2)),...
    mean(pcc_observe_tf(:,3)), std(pcc_observe_tf(:,3)), mean(mse_observe_tf(:,3)), std(mse_observe_tf(:,3)), mean(snr_observe_tf(:,3)), std(snr_observe_tf(:,3)));

fprintf(['S1_PCC: %2.4f±%2.4f | S1_MSE: %.2e±%.2e | S1_SNR(db): %4.4f±%4.4f ||| ' ...
         'S2_PCC: %2.4f±%2.4f | S2_MSE: %.2e±%.2e | S2_SNR(db): %4.4f±%4.4f ||| ' ...
         'S3_PCC: %2.4f±%2.4f | S3_MSE: %.2e±%.2e | S3_SNR(db): %4.4f±%4.4f  (GLA Method)\n'], ...
    mean(pcc_gla_tf(:,1)), std(pcc_gla_tf(:,1)), mean(mse_gla_tf(:,1)), std(mse_gla_tf(:,1)), mean(snr_gla_tf(:,1)), std(snr_gla_tf(:,1)),...
    mean(pcc_gla_tf(:,2)), std(pcc_gla_tf(:,2)), mean(mse_gla_tf(:,2)), std(mse_gla_tf(:,2)), mean(snr_gla_tf(:,2)), std(snr_gla_tf(:,2)),...
    mean(pcc_gla_tf(:,3)), std(pcc_gla_tf(:,3)), mean(mse_gla_tf(:,3)), std(mse_gla_tf(:,3)), mean(snr_gla_tf(:,3)), std(snr_gla_tf(:,3)));

fprintf(['S1_PCC: %2.4f±%2.4f | S1_MSE: %.2e±%.2e | S1_SNR(db): %4.4f±%4.4f ||| ' ...
         'S2_PCC: %2.4f±%2.4f | S2_MSE: %.2e±%.2e | S2_SNR(db): %4.4f±%4.4f ||| ' ...
         'S3_PCC: %2.4f±%2.4f | S3_MSE: %.2e±%.2e | S3_SNR(db): %4.4f±%4.4f  (OT Method)\n'], ...
    mean(pcc_ot_tf(:,1)), std(pcc_ot_tf(:,1)), mean(mse_ot_tf(:,1)), std(mse_ot_tf(:,1)), mean(snr_ot_tf(:,1)), std(snr_ot_tf(:,1)),...
    mean(pcc_ot_tf(:,2)), std(pcc_ot_tf(:,2)), mean(mse_ot_tf(:,2)), std(mse_ot_tf(:,2)), mean(snr_ot_tf(:,2)), std(snr_ot_tf(:,2)),...
    mean(pcc_ot_tf(:,3)), std(pcc_ot_tf(:,3)), mean(mse_ot_tf(:,3)), std(mse_ot_tf(:,3)), mean(snr_ot_tf(:,3)), std(snr_ot_tf(:,3)));

fprintf(['S1_PCC: %2.4f±%2.4f | S1_MSE: %.2e±%.2e | S1_SNR(db): %4.4f±%4.4f ||| ' ...
         'S2_PCC: %2.4f±%2.4f | S2_MSE: %.2e±%.2e | S2_SNR(db): %4.4f±%4.4f ||| ' ...
         'S3_PCC: %2.4f±%2.4f | S3_MSE: %.2e±%.2e | S3_SNR(db): %4.4f±%4.4f  (DNN Method)\n'], ...
    mean(pcc_dnn_tf(:,1)), std(pcc_dnn_tf(:,1)), mean(mse_dnn_tf(:,1)), std(mse_dnn_tf(:,1)), mean(snr_dnn_tf(:,1)), std(snr_dnn_tf(:,1)),...
    mean(pcc_dnn_tf(:,2)), std(pcc_dnn_tf(:,2)), mean(mse_dnn_tf(:,2)), std(mse_dnn_tf(:,2)), mean(snr_dnn_tf(:,2)), std(snr_dnn_tf(:,2)),...
    mean(pcc_dnn_tf(:,3)), std(pcc_dnn_tf(:,3)), mean(mse_dnn_tf(:,3)), std(mse_dnn_tf(:,3)), mean(snr_dnn_tf(:,3)), std(snr_dnn_tf(:,3)));

fprintf(['S1_PCC: %2.4f±%2.4f | S1_MSE: %.2e±%.2e | S1_SNR(db): %4.4f±%4.4f ||| ' ...
         'S2_PCC: %2.4f±%2.4f | S2_MSE: %.2e±%.2e | S2_SNR(db): %4.4f±%4.4f ||| ' ...
         'S3_PCC: %2.4f±%2.4f | S3_MSE: %.2e±%.2e | S3_SNR(db): %4.4f±%4.4f  (ADMM Method)\n'], ...
    mean(pcc_admm_tf(:,1)), std(pcc_admm_tf(:,1)), mean(mse_admm_tf(:,1)), std(mse_admm_tf(:,1)), mean(snr_admm_tf(:,1)), std(snr_admm_tf(:,1)),...
    mean(pcc_admm_tf(:,2)), std(pcc_admm_tf(:,2)), mean(mse_admm_tf(:,2)), std(mse_admm_tf(:,2)), mean(snr_admm_tf(:,2)), std(snr_admm_tf(:,2)),...
    mean(pcc_admm_tf(:,3)), std(pcc_admm_tf(:,3)), mean(mse_admm_tf(:,3)), std(mse_admm_tf(:,3)), mean(snr_admm_tf(:,3)), std(snr_admm_tf(:,3)));

fprintf(['S1_PCC: %2.4f±%2.4f | S1_MSE: %.2e±%.2e | S1_SNR(db): %4.4f±%4.4f ||| ' ...
         'S2_PCC: %2.4f±%2.4f | S2_MSE: %.2e±%.2e | S2_SNR(db): %4.4f±%4.4f ||| ' ...
         'S3_PCC: %2.4f±%2.4f | S3_MSE: %.2e±%.2e | S3_SNR(db): %4.4f±%4.4f  (TESA Method)\n'], ...
    mean(pcc_tesa_tf(:,1)), std(pcc_tesa_tf(:,1)), mean(mse_tesa_tf(:,1)), std(mse_tesa_tf(:,1)), mean(snr_tesa_tf(:,1)), std(snr_tesa_tf(:,1)),...
    mean(pcc_tesa_tf(:,2)), std(pcc_tesa_tf(:,2)), mean(mse_tesa_tf(:,2)), std(mse_tesa_tf(:,2)), mean(snr_tesa_tf(:,2)), std(snr_tesa_tf(:,2)),...
    mean(pcc_tesa_tf(:,3)), std(pcc_tesa_tf(:,3)), mean(mse_tesa_tf(:,3)), std(mse_tesa_tf(:,3)), mean(snr_tesa_tf(:,3)), std(snr_tesa_tf(:,3)));

% Plot bar charts for mean metrics with error bars (std)
methods = {'Observation', 'GLA', 'OT', 'DNN', 'ADMM', 'TESA'};
mean_snr_time = [mean(snr_observe_time(:)), mean(snr_gla_time(:)), mean(snr_ot_time(:)), mean(snr_dnn_time(:)), mean(snr_admm_time(:)), mean(snr_tesa_time(:))];
std_snr_time = [std(snr_observe_time(:)), std(snr_gla_time(:)), std(snr_ot_time(:)), std(snr_dnn_time(:)), std(snr_admm_time(:)), std(snr_tesa_time(:))];
mean_mse_time = [mean(mse_observe_time(:)), mean(mse_gla_time(:)), mean(mse_ot_time(:)), mean(mse_dnn_time(:)), mean(mse_admm_time(:)), mean(mse_tesa_time(:))];
std_mse_time = [std(mse_observe_time(:)), std(mse_gla_time(:)), std(mse_ot_time(:)), std(mse_dnn_time(:)), std(mse_admm_time(:)), std(mse_tesa_time(:))];
mean_pcc_time = [mean(pcc_observe_time(:)), mean(pcc_gla_time(:)), mean(pcc_ot_time(:)), mean(pcc_dnn_time(:)), mean(pcc_admm_time(:)), mean(pcc_tesa_time(:))];
std_pcc_time = [std(pcc_observe_time(:)), std(pcc_gla_time(:)), std(pcc_ot_time(:)), std(pcc_dnn_time(:)), std(pcc_admm_time(:)), std(pcc_tesa_time(:))];

mean_snr_tf = [mean(snr_observe_tf(:)), mean(snr_gla_tf(:)), mean(snr_ot_tf(:)), mean(snr_dnn_tf(:)), mean(snr_admm_tf(:)), mean(snr_tesa_tf(:))];
std_snr_tf = [std(snr_observe_tf(:)), std(snr_gla_tf(:)), std(snr_ot_tf(:)), std(snr_dnn_tf(:)), std(snr_admm_tf(:)), std(snr_tesa_tf(:))];
mean_mse_tf = [mean(mse_observe_tf(:)), mean(mse_gla_tf(:)), mean(mse_ot_tf(:)), mean(mse_dnn_tf(:)), mean(mse_admm_tf(:)), mean(mse_tesa_tf(:))];
std_mse_tf = [std(mse_observe_tf(:)), std(mse_gla_tf(:)), std(mse_ot_tf(:)), std(mse_dnn_tf(:)), std(mse_admm_tf(:)), std(mse_tesa_tf(:))];
mean_pcc_tf = [mean(pcc_observe_tf(:)), mean(pcc_gla_tf(:)), mean(pcc_ot_tf(:)), mean(pcc_dnn_tf(:)), mean(pcc_admm_tf(:)), mean(pcc_tesa_tf(:))];
std_pcc_tf = [std(pcc_observe_tf(:)), std(pcc_gla_tf(:)), std(pcc_ot_tf(:)), std(pcc_dnn_tf(:)), std(pcc_admm_tf(:)), std(pcc_tesa_tf(:))];

% Plot Time Domain Metrics
figure('Name', 'Average Metrics (Time Domain)', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);
subplot(3, 1, 1);
bar(mean_snr_time); hold on;
errorbar(1:6, mean_snr_time, std_snr_time, 'k.', 'LineWidth', 1.5);
set(gca, 'XTickLabel', methods, 'XTickLabelRotation', 45);
title('SNR (Time Domain)'); ylabel('SNR (dB)'); grid on;

subplot(3, 1, 2);
bar(mean_mse_time); hold on;
errorbar(1:6, mean_mse_time, std_mse_time, 'k.', 'LineWidth', 1.5);
set(gca, 'XTickLabel', methods, 'XTickLabelRotation', 45);
title('MSE (Time Domain)'); ylabel('MSE'); grid on;

subplot(3, 1, 3);
bar(mean_pcc_time); hold on;
errorbar(1:6, mean_pcc_time, std_pcc_time, 'k.', 'LineWidth', 1.5);
set(gca, 'XTickLabel', methods, 'XTickLabelRotation', 45);
title('PCC (Time Domain)'); ylabel('PCC'); grid on;

% Save the figure with high quality
if exist('exportgraphics', 'file')
    exportgraphics(gcf, fullfile(output_dir, 'time_domain_metrics.png'), 'Resolution', 300, 'ContentType', 'image');
else
    print(gcf, fullfile(output_dir, 'time_domain_metrics.png'), '-dpng', '-r300');
end

% Plot Time-Frequency Domain Metrics
figure('Name', 'Average Metrics (Time-Frequency Domain)', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);
subplot(3, 1, 1);
bar(mean_snr_tf); hold on;
errorbar(1:6, mean_snr_tf, std_snr_tf, 'k.', 'LineWidth', 1.5);
set(gca, 'XTickLabel', methods, 'XTickLabelRotation', 45);
title('SNR (Time-Frequency Domain)'); ylabel('SNR (dB)'); grid on;

subplot(3, 1, 2);
bar(mean_mse_tf); hold on;
errorbar(1:6, mean_mse_tf, std_mse_tf, 'k.', 'LineWidth', 1.5);
set(gca, 'XTickLabel', methods, 'XTickLabelRotation', 45);
title('MSE (Time-Frequency Domain)'); ylabel('MSE'); grid on;

subplot(3, 1, 3);
bar(mean_pcc_tf); hold on;
errorbar(1:6, mean_pcc_tf, std_pcc_tf, 'k.', 'LineWidth', 1.5);
set(gca, 'XTickLabel', methods, 'XTickLabelRotation', 45);
title('PCC (Time-Frequency Domain)'); ylabel('PCC'); grid on;

% Save the figure with high quality
if exist('exportgraphics', 'file')
    exportgraphics(gcf, fullfile(output_dir, 'tf_domain_metrics.png'), 'Resolution', 300, 'ContentType', 'image');
else
    print(gcf, fullfile(output_dir, 'tf_domain_metrics.png'), '-dpng', '-r300');
end

fprintf('Please check the %s folder for reconstructed signals, metrics, and plots.\n', output_dir);