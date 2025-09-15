% Main script to run the experiment for 10 images, compute mean/std of metrics, and display results

clc; clear; close all;

% Create output directory if it doesn't exist
output_dir = 'results';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% List of images
images = {...
    'materials/cameraman.tif', ...
    'materials/house.tif', ...
    'materials/lake.tif', ...
    'materials/lena.tif', ...
    'materials/livingroom.tif', ...
    'materials/baboon.tif', ...
    'materials/peppers.tif', ...
    'materials/pirate.tif', ...
    'materials/walkbridge.tif', ...
    'materials/woman.tif'...
};

num_images = length(images);

% Initialize arrays for each metric
snr_observe_time_all = zeros(num_images, 1);
snr_gla_time_all = zeros(num_images, 1);
snr_ot_time_all = zeros(num_images, 1);
snr_dnn_time_all = zeros(num_images, 1);
snr_admm_time_all = zeros(num_images, 1);
snr_tesa_time_all = zeros(num_images, 1);

mse_observe_time_all = zeros(num_images, 1);
mse_gla_time_all = zeros(num_images, 1);
mse_ot_time_all = zeros(num_images, 1);
mse_dnn_time_all = zeros(num_images, 1);
mse_admm_time_all = zeros(num_images, 1);
mse_tesa_time_all = zeros(num_images, 1);

pcc_observe_time_all = zeros(num_images, 1);
pcc_gla_time_all = zeros(num_images, 1);
pcc_ot_time_all = zeros(num_images, 1);
pcc_dnn_time_all = zeros(num_images, 1);
pcc_admm_time_all = zeros(num_images, 1);
pcc_tesa_time_all = zeros(num_images, 1);

snr_observe_tf_all = zeros(num_images, 1);
snr_gla_tf_all = zeros(num_images, 1);
snr_ot_tf_all = zeros(num_images, 1);
snr_dnn_tf_all = zeros(num_images, 1);
snr_admm_tf_all = zeros(num_images, 1);
snr_tesa_tf_all = zeros(num_images, 1);

mse_observe_tf_all = zeros(num_images, 1);
mse_gla_tf_all = zeros(num_images, 1);
mse_ot_tf_all = zeros(num_images, 1);
mse_dnn_tf_all = zeros(num_images, 1);
mse_admm_tf_all = zeros(num_images, 1);
mse_tesa_tf_all = zeros(num_images, 1);

pcc_observe_tf_all = zeros(num_images, 1);
pcc_gla_tf_all = zeros(num_images, 1);
pcc_ot_tf_all = zeros(num_images, 1);
pcc_dnn_tf_all = zeros(num_images, 1);
pcc_admm_tf_all = zeros(num_images, 1);
pcc_tesa_tf_all = zeros(num_images, 1);

% Run the experiment for each image
for i = 1:num_images
    fprintf('Processing image %d/%d: %s\n', i, num_images, images{i});
    results = run_restoration(images{i});
    
    % Store metrics
    snr_observe_time_all(i) = results.snr_observe_time;
    snr_gla_time_all(i) = results.snr_gla_time;
    snr_ot_time_all(i) = results.snr_ot_time;
    snr_dnn_time_all(i) = results.snr_dnn_time;
    snr_admm_time_all(i) = results.snr_admm_time;
    snr_tesa_time_all(i) = results.snr_tesa_time;
    
    mse_observe_time_all(i) = results.mse_observe_time;
    mse_gla_time_all(i) = results.mse_gla_time;
    mse_ot_time_all(i) = results.mse_ot_time;
    mse_dnn_time_all(i) = results.mse_dnn_time;
    mse_admm_time_all(i) = results.mse_admm_time;
    mse_tesa_time_all(i) = results.mse_tesa_time;
    
    pcc_observe_time_all(i) = results.pcc_observe_time;
    pcc_gla_time_all(i) = results.pcc_gla_time;
    pcc_ot_time_all(i) = results.pcc_ot_time;
    pcc_dnn_time_all(i) = results.pcc_dnn_time;
    pcc_admm_time_all(i) = results.pcc_admm_time;
    pcc_tesa_time_all(i) = results.pcc_tesa_time;
    
    snr_observe_tf_all(i) = results.snr_observe_tf;
    snr_gla_tf_all(i) = results.snr_gla_tf;
    snr_ot_tf_all(i) = results.snr_ot_tf;
    snr_dnn_tf_all(i) = results.snr_dnn_tf;
    snr_admm_tf_all(i) = results.snr_admm_tf;
    snr_tesa_tf_all(i) = results.snr_tesa_tf;
    
    mse_observe_tf_all(i) = results.mse_observe_tf;
    mse_gla_tf_all(i) = results.mse_gla_tf;
    mse_ot_tf_all(i) = results.mse_ot_tf;
    mse_dnn_tf_all(i) = results.mse_dnn_tf;
    mse_admm_tf_all(i) = results.mse_admm_tf;
    mse_tesa_tf_all(i) = results.mse_tesa_tf;
    
    pcc_observe_tf_all(i) = results.pcc_observe_tf;
    pcc_gla_tf_all(i) = results.pcc_gla_tf;
    pcc_ot_tf_all(i) = results.pcc_ot_tf;
    pcc_dnn_tf_all(i) = results.pcc_dnn_tf;
    pcc_admm_tf_all(i) = results.pcc_admm_tf;
    pcc_tesa_tf_all(i) = results.pcc_tesa_tf;
end

% Compute means and standard deviations
mean_snr_observe_time = mean(snr_observe_time_all);
std_snr_observe_time = std(snr_observe_time_all);
mean_snr_gla_time = mean(snr_gla_time_all);
std_snr_gla_time = std(snr_gla_time_all);
mean_snr_ot_time = mean(snr_ot_time_all);
std_snr_ot_time = std(snr_ot_time_all);
mean_snr_dnn_time = mean(snr_dnn_time_all);
std_snr_dnn_time = std(snr_dnn_time_all);
mean_snr_admm_time = mean(snr_admm_time_all);
std_snr_admm_time = std(snr_admm_time_all);
mean_snr_tesa_time = mean(snr_tesa_time_all);
std_snr_tesa_time = std(snr_tesa_time_all);

mean_mse_observe_time = mean(mse_observe_time_all);
std_mse_observe_time = std(mse_observe_time_all);
mean_mse_gla_time = mean(mse_gla_time_all);
std_mse_gla_time = std(mse_gla_time_all);
mean_mse_ot_time = mean(mse_ot_time_all);
std_mse_ot_time = std(mse_ot_time_all);
mean_mse_dnn_time = mean(mse_dnn_time_all);
std_mse_dnn_time = std(mse_dnn_time_all);
mean_mse_admm_time = mean(mse_admm_time_all);
std_mse_admm_time = std(mse_admm_time_all);
mean_mse_tesa_time = mean(mse_tesa_time_all);
std_mse_tesa_time = std(mse_tesa_time_all);

mean_pcc_observe_time = mean(pcc_observe_time_all);
std_pcc_observe_time = std(pcc_observe_time_all);
mean_pcc_gla_time = mean(pcc_gla_time_all);
std_pcc_gla_time = std(pcc_gla_time_all);
mean_pcc_ot_time = mean(pcc_ot_time_all);
std_pcc_ot_time = std(pcc_ot_time_all);
mean_pcc_dnn_time = mean(pcc_dnn_time_all);
std_pcc_dnn_time = std(pcc_dnn_time_all);
mean_pcc_admm_time = mean(pcc_admm_time_all);
std_pcc_admm_time = std(pcc_admm_time_all);
mean_pcc_tesa_time = mean(pcc_tesa_time_all);
std_pcc_tesa_time = std(pcc_tesa_time_all);

mean_snr_observe_tf = mean(snr_observe_tf_all);
std_snr_observe_tf = std(snr_observe_tf_all);
mean_snr_gla_tf = mean(snr_gla_tf_all);
std_snr_gla_tf = std(snr_gla_tf_all);
mean_snr_ot_tf = mean(snr_ot_tf_all);
std_snr_ot_tf = std(snr_ot_tf_all);
mean_snr_dnn_tf = mean(snr_dnn_tf_all);
std_snr_dnn_tf = std(snr_dnn_tf_all);
mean_snr_admm_tf = mean(snr_admm_tf_all);
std_snr_admm_tf = std(snr_admm_tf_all);
mean_snr_tesa_tf = mean(snr_tesa_tf_all);
std_snr_tesa_tf = std(snr_tesa_tf_all);

mean_mse_observe_tf = mean(mse_observe_tf_all);
std_mse_observe_tf = std(mse_observe_tf_all);
mean_mse_gla_tf = mean(mse_gla_tf_all);
std_mse_gla_tf = std(mse_gla_tf_all);
mean_mse_ot_tf = mean(mse_ot_tf_all);
std_mse_ot_tf = std(mse_ot_tf_all);
mean_mse_dnn_tf = mean(mse_dnn_tf_all);
std_mse_dnn_tf = std(mse_dnn_tf_all);
mean_mse_admm_tf = mean(mse_admm_tf_all);
std_mse_admm_tf = std(mse_admm_tf_all);
mean_mse_tesa_tf = mean(mse_tesa_tf_all);
std_mse_tesa_tf = std(mse_tesa_tf_all);

mean_pcc_observe_tf = mean(pcc_observe_tf_all);
std_pcc_observe_tf = std(pcc_observe_tf_all);
mean_pcc_gla_tf = mean(pcc_gla_tf_all);
std_pcc_gla_tf = std(pcc_gla_tf_all);
mean_pcc_ot_tf = mean(pcc_ot_tf_all);
std_pcc_ot_tf = std(pcc_ot_tf_all);
mean_pcc_dnn_tf = mean(pcc_dnn_tf_all);
std_pcc_dnn_tf = std(pcc_dnn_tf_all);
mean_pcc_admm_tf = mean(pcc_admm_tf_all);
std_pcc_admm_tf = std(pcc_admm_tf_all);
mean_pcc_tesa_tf = mean(pcc_tesa_tf_all);
std_pcc_tesa_tf = std(pcc_tesa_tf_all);

% Display average results with std
fprintf('\n----- Average Time-Series Metrics (Image Domain) over %d images -----\n', num_images);
fprintf('PCC: %2.4f ± %2.4f | MSE: %.2e ± %.2e | SNR(db): %4.4f ± %4.4f   (Observation)\n', ...
    mean_pcc_observe_time, std_pcc_observe_time, mean_mse_observe_time, std_mse_observe_time, mean_snr_observe_time, std_snr_observe_time);
fprintf('PCC: %2.4f ± %2.4f | MSE: %.2e ± %.2e | SNR(db): %4.4f ± %4.4f   (GLA Method)\n', ...
    mean_pcc_gla_time, std_pcc_gla_time, mean_mse_gla_time, std_mse_gla_time, mean_snr_gla_time, std_snr_gla_time);
fprintf('PCC: %2.4f ± %2.4f | MSE: %.2e ± %.2e | SNR(db): %4.4f ± %4.4f   (OT Method)\n', ...
    mean_pcc_ot_time, std_pcc_ot_time, mean_mse_ot_time, std_mse_ot_time, mean_snr_ot_time, std_snr_ot_time);
fprintf('PCC: %2.4f ± %2.4f | MSE: %.2e ± %.2e | SNR(db): %4.4f ± %4.4f   (DNN Method)\n', ...
    mean_pcc_dnn_time, std_pcc_dnn_time, mean_mse_dnn_time, std_mse_dnn_time, mean_snr_dnn_time, std_snr_dnn_time);
fprintf('PCC: %2.4f ± %2.4f | MSE: %.2e ± %.2e | SNR(db): %4.4f ± %4.4f   (ADMM Method)\n', ...
    mean_pcc_admm_time, std_pcc_admm_time, mean_mse_admm_time, std_mse_admm_time, mean_snr_admm_time, std_snr_admm_time);
fprintf('PCC: %2.4f ± %2.4f | MSE: %.2e ± %.2e | SNR(db): %4.4f ± %4.4f   (TESA Method)\n', ...
    mean_pcc_tesa_time, std_pcc_tesa_time, mean_mse_tesa_time, std_mse_tesa_time, mean_snr_tesa_time, std_snr_tesa_time);

fprintf('\n*************************************************');
fprintf('*************************************************\n');
fprintf('                      ****          \n');
fprintf('*************************************************\n');
fprintf('*************************************************\n');

fprintf('\n----- Average Spectrogram Metrics over %d images -----\n', num_images);
fprintf('PCC: %2.4f ± %2.4f | MSE: %.2e ± %.2e | SNR(db): %4.4f ± %4.4f   (Observation)\n', ...
    mean_pcc_observe_tf, std_pcc_observe_tf, mean_mse_observe_tf, std_mse_observe_tf, mean_snr_observe_tf, std_snr_observe_tf);
fprintf('PCC: %2.4f ± %2.4f | MSE: %.2e ± %.2e | SNR(db): %4.4f ± %4.4f   (GLA Method)\n', ...
    mean_pcc_gla_tf, std_pcc_gla_tf, mean_mse_gla_tf, std_mse_gla_tf, mean_snr_gla_tf, std_snr_gla_tf);
fprintf('PCC: %2.4f ± %2.4f | MSE: %.2e ± %.2e | SNR(db): %4.4f ± %4.4f   (OT Method)\n', ...
    mean_pcc_ot_tf, std_pcc_ot_tf, mean_mse_ot_tf, std_mse_ot_tf, mean_snr_ot_tf, std_snr_ot_tf);
fprintf('PCC: %2.4f ± %2.4f | MSE: %.2e ± %.2e | SNR(db): %4.4f ± %4.4f   (DNN Method)\n', ...
    mean_pcc_dnn_tf, std_pcc_dnn_tf, mean_mse_dnn_tf, std_mse_dnn_tf, mean_snr_dnn_tf, std_snr_dnn_tf);
fprintf('PCC: %2.4f ± %2.4f | MSE: %.2e ± %.2e | SNR(db): %4.4f ± %4.4f   (ADMM Method)\n', ...
    mean_pcc_admm_tf, std_pcc_admm_tf, mean_mse_admm_tf, std_mse_admm_tf, mean_snr_admm_tf, std_snr_admm_tf);
fprintf('PCC: %2.4f ± %2.4f | MSE: %.2e ± %.2e | SNR(db): %4.4f ± %4.4f   (TESA Method)\n', ...
    mean_pcc_tesa_tf, std_pcc_tesa_tf, mean_mse_tesa_tf, std_mse_tesa_tf, mean_snr_tesa_tf, std_snr_tesa_tf);

% Plot bar charts for mean metrics with error bars (std)
methods = {'Observation', 'GLA', 'OT', 'DNN', 'ADMM', 'TESA'};
mean_snr_time = [mean_snr_observe_time, mean_snr_gla_time, mean_snr_ot_time, mean_snr_dnn_time, mean_snr_admm_time, mean_snr_tesa_time];
std_snr_time = [std_snr_observe_time, std_snr_gla_time, std_snr_ot_time, std_snr_dnn_time, std_snr_admm_time, std_snr_tesa_time];
mean_mse_time = [mean_mse_observe_time, mean_mse_gla_time, mean_mse_ot_time, mean_mse_dnn_time, mean_mse_admm_time, mean_mse_tesa_time];
std_mse_time = [std_mse_observe_time, std_mse_gla_time, std_mse_ot_time, std_mse_dnn_time, std_mse_admm_time, std_mse_tesa_time];
mean_pcc_time = [mean_pcc_observe_time, mean_pcc_gla_time, mean_pcc_ot_time, mean_pcc_dnn_time, mean_pcc_admm_time, mean_pcc_tesa_time];
std_pcc_time = [std_pcc_observe_time, std_pcc_gla_time, std_pcc_ot_time, std_pcc_dnn_time, std_pcc_admm_time, std_pcc_tesa_time];

mean_snr_tf = [mean_snr_observe_tf, mean_snr_gla_tf, mean_snr_ot_tf, mean_snr_dnn_tf, mean_snr_admm_tf, mean_snr_tesa_tf];
std_snr_tf = [std_snr_observe_tf, std_snr_gla_tf, std_snr_ot_tf, std_snr_dnn_tf, std_snr_admm_tf, std_snr_tesa_tf];
mean_mse_tf = [mean_mse_observe_tf, mean_mse_gla_tf, mean_mse_ot_tf, mean_mse_dnn_tf, mean_mse_admm_tf, mean_mse_tesa_tf];
std_mse_tf = [std_mse_observe_tf, std_mse_gla_tf, std_mse_ot_tf, std_mse_dnn_tf, std_mse_admm_tf, std_mse_tesa_tf];
mean_pcc_tf = [mean_pcc_observe_tf, mean_pcc_gla_tf, mean_pcc_ot_tf, mean_pcc_dnn_tf, mean_pcc_admm_tf, mean_pcc_tesa_tf];
std_pcc_tf = [std_pcc_observe_tf, std_pcc_gla_tf, std_pcc_ot_tf, std_pcc_dnn_tf, std_pcc_admm_tf, std_pcc_tesa_tf];

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

% Save all results to a file
save(fullfile(output_dir, 'restoration_results.mat'), 'mean_*', 'std_*', '-regexp', '^(mean_|std_)');
fprintf('Please check the results folder, the results of this experiment are there.\n');
