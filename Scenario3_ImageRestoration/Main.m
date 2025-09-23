% Main script to run the image restoration experiment for 10 images and 7 damage percentages,
% compute mean/std of PCC (time) and MSE (tf), display results table for each experiment in run_restoration,
% save reconstructed signals in image-specific folders, and display results with smooth interpolated grayscale plots.
% Plots and summary tables exclude the Observation method.

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

% Damage percentages
percentages = [0.01, 0.1, 0.3, 0.5, 0.7, 0.9, 0.99];
num_percentages = length(percentages);

% Initialize storage for metrics (num_images x num_percentages)
metrics = struct();
methods = {'observe', 'gla', 'ot', 'dnn', 'admm', 'tesa'};
metrics.time.pcc = struct();
metrics.tf.mse = struct();
for method = methods
    metrics.time.pcc.(method{1}) = zeros(num_images, num_percentages);
    metrics.tf.mse.(method{1}) = zeros(num_images, num_percentages);
end

% Process each image and percentage
for img_idx = 1:num_images
    img_name = images{img_idx};
    [~, name, ~] = fileparts(img_name);
    fprintf('Processing image %d/%d: %s\n', img_idx, num_images, img_name);
    
    % Preprocess image to handle RGB
    try
        img = imread(img_name);
        if ndims(img) == 3
            img = rescale(sum(img, 3)); % Convert RGB to grayscale
            imwrite(img, img_name); % Save as grayscale for run_restoration
        end
    catch err
        fprintf('Error loading image %s: %s\n', img_name, err.message);
        continue;
    end
    
    for perc_idx = 1:num_percentages
        perc = percentages(perc_idx);
        try
            results = run_restoration(img_name, perc);
            % Store metrics
            for method = methods
                metrics.time.pcc.(method{1})(img_idx, perc_idx) = results.(sprintf('pcc_%s_time', method{1}));
                metrics.tf.mse.(method{1})(img_idx, perc_idx) = results.(sprintf('mse_%s_tf', method{1}));
            end
        catch
            % Suppress restoration error, results table already printed in run_restoration
            continue;
        end
    end
end

% Save all metrics
try
    save(fullfile(output_dir, 'restoration_results.mat'), 'metrics', 'percentages');
    fprintf('Saved all metrics to %s\n', fullfile(output_dir, 'restoration_results.mat'));
catch
    % Suppress save error
end

% Display and save combined results
fprintf('\nCombined Results (Time Domain - PCC):\n');
fprintf('--------------------------------------------------------\n');
fprintf('%-20s', 'Percentage');
for method = methods(2:end)  % Exclude observe for table
    fprintf('%-20s', upper(method{1}));
end
fprintf('\n');
fprintf('--------------------------------------------------------\n');

fileID = fopen(fullfile(output_dir, 'combined_results.txt'), 'w', 'n', 'UTF-8');
fprintf(fileID, 'Combined Results (Time Domain - PCC):\n');
fprintf(fileID, '--------------------------------------------------------\n');
fprintf(fileID, '%-20s', 'Percentage');
for method = methods(2:end)
    fprintf(fileID, '%-20s', upper(method{1}));
end
fprintf(fileID, '\n');
fprintf(fileID, '--------------------------------------------------------\n');

for perc_idx = 1:num_percentages
    perc = percentages(perc_idx) * 100;
    fprintf('%-20d', round(perc));
    fprintf(fileID, '%-20d', round(perc));
    for method = methods(2:end)  % Exclude observe
        mean_pcc = mean(metrics.time.pcc.(method{1})(:, perc_idx));
        std_pcc = std(metrics.time.pcc.(method{1})(:, perc_idx));
        fprintf('%-20s', sprintf('%4.4f ± %4.4f', mean_pcc, std_pcc));
        fprintf(fileID, '%-20s', sprintf('%4.4f ± %4.4f', mean_pcc, std_pcc));
    end
    fprintf('\n');
    fprintf(fileID, '\n');
end
fprintf('--------------------------------------------------------\n');
fprintf(fileID, '--------------------------------------------------------\n');

fprintf('\nCombined Results (TF Domain - MSE):\n');
fprintf('--------------------------------------------------------\n');
fprintf('%-20s', 'Percentage');
for method = methods(2:end)  % Exclude observe for table
    fprintf('%-20s', upper(method{1}));
end
fprintf('\n');
fprintf('--------------------------------------------------------\n');

fprintf(fileID, '\nCombined Results (TF Domain - MSE):\n');
fprintf(fileID, '--------------------------------------------------------\n');
fprintf(fileID, '%-20s', 'Percentage');
for method = methods(2:end)
    fprintf(fileID, '%-20s', upper(method{1}));
end
fprintf(fileID, '\n');
fprintf(fileID, '--------------------------------------------------------\n');

for perc_idx = 1:num_percentages
    perc = percentages(perc_idx) * 100;
    fprintf('%-20d', round(perc));
    fprintf(fileID, '%-20d', round(perc));
    for method = methods(2:end)  % Exclude observe
        mean_mse = mean(metrics.tf.mse.(method{1})(:, perc_idx));
        std_mse = std(metrics.tf.mse.(method{1})(:, perc_idx));
        fprintf('%-20s', sprintf('%.2e ± %.2e', mean_mse, std_mse));
        fprintf(fileID, '%-20s', sprintf('%.2e ± %.2e', mean_mse, std_mse));
    end
    fprintf('\n');
    fprintf(fileID, '\n');
end
fprintf('--------------------------------------------------------\n');
fprintf(fileID, '--------------------------------------------------------\n');
fclose(fileID);
fprintf('Results saved to %s\n', fullfile(output_dir, 'combined_results.txt'));

% Smooth interpolated plots (excluding Observation, using grayscale)
plot_methods = {'gla', 'ot', 'dnn', 'admm', 'tesa'};
methods_display = {'GLA', 'OT', 'DNN', 'ADMM', 'TESA'};
line_styles = {'--', ':', '-.', '--', ':'};
markers = {'s', 'd', '^', 'v', 'o'};
marker_sizes = [6, 6, 6, 6, 6];
line_widths = [2, 2, 2, 2, 2];

x_fine = linspace(min(percentages)*100, max(percentages)*100, 100); % Fine grid for interpolation
figure('Name', 'PCC vs Damage Percentage (Time Domain)', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 400]);
hold on;
colors = gray(length(plot_methods) + 1); % Grayscale colormap
for m = 1:length(plot_methods)
    mean_pcc = mean(metrics.time.pcc.(plot_methods{m}), 1);
    pcc_interp = interp1(percentages*100, mean_pcc, x_fine, 'pchip');
    plot(x_fine, pcc_interp, 'LineStyle', line_styles{m}, 'Marker', markers{m}, ...
         'MarkerIndices', 1:10:length(x_fine), 'MarkerSize', marker_sizes(m), ...
         'LineWidth', line_widths(m), 'Color', colors(ceil(m^0.5), :), 'DisplayName', methods_display{m});
end
legend('show', 'Location', 'best');
title('PCC (Time Domain) Across Damage Percentage');
xlabel('Damage Percentage (%)'); ylabel('PCC'); grid on;
set(gca, 'XTick', percentages*100);
try
    if exist('exportgraphics', 'file')
        exportgraphics(gcf, fullfile(output_dir, 'time_domain_pcc_percentages.png'), 'Resolution', 300, 'ContentType', 'image');
    else
        print(gcf, fullfile(output_dir, 'time_domain_pcc_percentages.png'), '-dpng', '-r300');
    end
catch
    % Suppress plot save error
end
close(gcf);

figure('Name', 'MSE vs Damage Percentage (Time-Frequency Domain)', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 400]);
hold on;
for m = 1:length(plot_methods)
    mean_mse = mean(metrics.tf.mse.(plot_methods{m}), 1);
    mse_interp = interp1(percentages*100, mean_mse, x_fine, 'pchip');
    plot(x_fine, mse_interp, 'LineStyle', line_styles{m}, 'Marker', markers{m}, ...
         'MarkerIndices', 1:10:length(x_fine), 'MarkerSize', marker_sizes(m), ...
         'LineWidth', line_widths(m), 'Color', colors(ceil(m^0.5), :), 'DisplayName', methods_display{m});
end
legend('show', 'Location', 'best');
title('MSE (Time-Frequency Domain) Across Damage Percentage');
xlabel('Damage Percentage (%)'); ylabel('MSE'); grid on;
set(gca, 'XTick', percentages*100);
try
    if exist('exportgraphics', 'file')
        exportgraphics(gcf, fullfile(output_dir, 'tf_domain_mse_percentages.png'), 'Resolution', 300, 'ContentType', 'image');
    else
        print(gcf, fullfile(output_dir, 'tf_domain_mse_percentages.png'), '-dpng', '-r300');
    end
catch
    % Suppress plot save error
end
close(gcf);

fprintf('Check %s for reconstructed signals, metrics, and plots.\n', output_dir);