% This function runs the image restoration experiment for a given image name and damage percentage,
% computes PCC (time) and MSE (tf), displays results table, saves reconstructed signals,
% and saves subplots in an image-specific directory.

function results = run_restoration(image_name, damagePercentage)
    
    % TESA Parameters
    lambda = 0;
    alpha = 1e-2;
    num_iter = 8000;
    beta1 = 0.9;
    beta2 = 0.999;
    
    % STFT Parameters
    win_len = 512;
    noverlap = round(0.85*win_len);
    nfft = win_len;
    window = hamming(win_len);

    % Display processing message
    [~, name, ~] = fileparts(image_name);
    damagePercentage = sqrt(damagePercentage);
    fprintf('  Percentage %.0f%%: Processing\n', (damagePercentage^2)*100);

    %% --- 1. Define and load images ---
    % Load the clean image (ground truth) and create a damaged version by zeroing a central square.
    clean_image = imread(image_name);

    % Downsampling (If your processor is slow, you can use downsampling to get an estimate of the calculations)
    clean_image = imresize(clean_image, [128, 128]);
    clean_image = rescale(clean_image);  % Normalize to [0, 1]

    [m, n] = size(clean_image);

    % Create damaged image by setting a central square to zero (simulating damage)
    rect_size = round(damagePercentage * size(clean_image));
    start_row = max(1, round(m/2 - rect_size(1)/2) + 1);
    end_row = min(m, start_row + rect_size(1) - 1);
    start_col = max(1, round(n/2 - rect_size(2)/2) + 1);
    end_col = min(n, start_col + rect_size(2) - 1);

    damaged_image = clean_image;
    damaged_image(start_row:end_row, start_col:end_col) = 0;

    % Flatten images to 1D vectors for STFT processing
    clean_imageVec = clean_image(:);
    damaged_imageVec = damaged_image(:);

    % Set sampling rate as the number of samples (pixels), as per request
    fs = length(clean_imageVec);

    % Length Alignment
    [S_clean, ~, ~] = stft(clean_imageVec, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    min_len = length(istft(S_clean, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));

    clean_imageVec = clean_imageVec(1:min_len);
    damaged_imageVec = damaged_imageVec(1:min_len);

    clean_imageVec = rescale(clean_imageVec);
    damaged_imageVec = rescale(damaged_imageVec);

    [S_clean, ~, ~] = stft(clean_imageVec, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    [S_damaged, ~, ~] = stft(damaged_imageVec, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    S_damaged = abs(S_damaged);
    S_clean = abs(S_clean);

    %% --- 2. Create the Target Spectrogram ---
    target_spectrogram = S_clean;

    %% --- 3. Apply Methods ---
    % Griffin-Lim Algorithm (GLA)
    x_gla = gla(damaged_imageVec, target_spectrogram, fs, window, noverlap, nfft, 100);
    x_gla = rescale(x_gla);

    % Optimal Transportation of Spectrograms (Wasserstein Barycenters)
    x_ot = ot(damaged_imageVec, target_spectrogram, fs, window, noverlap, nfft, 0.5);
    x_ot = rescale(x_ot);

    % DNN-based Phase Reconstruction
    x_dnn = dnn(damaged_imageVec, target_spectrogram, fs, window, noverlap, nfft);
    x_dnn = rescale(x_dnn);

    % Alternating Direction Method of Multipliers (ADMM)
    x_admm = admm(damaged_imageVec, target_spectrogram, fs, window, noverlap, nfft, 100);
    x_admm = rescale(x_admm);

    % Time-Enhanced Spectrogram Alignment (TESA)
    stft_params = struct('fs', fs, 'window', window, 'noverlap', noverlap, 'nfft', nfft);
    tesa_params = struct('lambda', lambda, 'alpha', alpha, 'num_iter', num_iter, ...
                         'beta1', beta1, 'beta2', beta2);
    x_tesa = tesa(damaged_imageVec, target_spectrogram, stft_params, tesa_params);
    x_tesa = rescale(x_tesa);

    %% --- 4. Calculate Spectrogram of the outputs ---
    S_gla = abs(stft(x_gla, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    S_ot = abs(stft(x_ot, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    S_dnn = abs(stft(x_dnn, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    S_admm = abs(stft(x_admm, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    S_tesa = abs(stft(x_tesa, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));

    %% --- 5. Evaluation Metrics in Time Domain (Image Domain) ---
    % 5.3. Pearson Correlation Coefficient (PCC)
    pcc_observe_time = corr(clean_imageVec(:), damaged_imageVec(:));
    pcc_gla_time = corr(clean_imageVec(:), x_gla(:));
    pcc_ot_time = corr(clean_imageVec(:), x_ot(:));
    pcc_dnn_time = corr(clean_imageVec(:), x_dnn(:));
    pcc_admm_time = corr(clean_imageVec(:), x_admm(:));
    pcc_tesa_time = corr(clean_imageVec(:), x_tesa(:));

    %% --- 6. Evaluation Metrics in Time-Frequency Domain ---
    % 6.2. Mean Square Error (MSE)
    mse_observe_tf = mean((S_clean(:) - S_damaged(:)).^2);
    mse_gla_tf = mean((S_clean(:) - S_gla(:)).^2);
    mse_ot_tf = mean((S_clean(:) - S_ot(:)).^2);
    mse_dnn_tf = mean((S_clean(:) - S_dnn(:)).^2);
    mse_admm_tf = mean((S_clean(:) - S_admm(:)).^2);
    mse_tesa_tf = mean((S_clean(:) - S_tesa(:)).^2);

    %% --- 7. Display Results as Images ---
    clean_image_restored = reshape([clean_imageVec; zeros(m*n-min_len,1)], m, n);
    damaged_image_restored = reshape([damaged_imageVec; zeros(m*n-min_len,1)], m, n);
    x_gla_image = reshape([x_gla; zeros(m*n-min_len,1)], m, n);
    x_tesa_image = reshape([x_tesa; zeros(m*n-min_len,1)], m, n);

    close(gcf); % Close figure to save memory

    figure('Name', sprintf('Restoration Results for %s (%.0f%% Damage)', name, round((damagePercentage^2)*100)), ...
           'NumberTitle', 'off', 'Position', [100, 100, 1200, 600]);
    subplot(2, 2, 1); imagesc(clean_image_restored); title('Clean'); colormap(gray); axis equal tight;
    subplot(2, 2, 2); imagesc(damaged_image_restored); title('Damaged'); colormap(gray); axis equal tight;
    subplot(2, 2, 3); imagesc(x_gla_image); title('GLA'); colormap(gray); axis equal tight;
    subplot(2, 2, 4); imagesc(x_tesa_image); title('TESA'); colormap(gray); axis equal tight;

    % Create image-specific output directory
    image_dir = fullfile('results', name);
    if ~exist(image_dir, 'dir')
        mkdir(image_dir);
    end

    % Save the figure with high quality
    output_file = fullfile(image_dir, sprintf('restoration_%d.png', round((damagePercentage^2)*100)));
    if exist('exportgraphics', 'file')
        exportgraphics(gcf, output_file, 'Resolution', 300, 'ContentType', 'image');
    else
        print(gcf, output_file, '-dpng', '-r300');
    end

    % Save reconstructed signals
    recon_file = fullfile(image_dir, sprintf('reconstructed_%d.mat', round((damagePercentage^2)*100)));
    save(recon_file, 'x_gla', 'x_ot', 'x_dnn', 'x_admm', 'x_tesa');
    fprintf('  Saved reconstructed signals in %s\n', recon_file);

    %% --- 8. Display Results Table ---
    fprintf('Results for %s (%.0f%% Damage):\n', name, (damagePercentage^2)*100);
    fprintf('--------------------------------------------\n');
    fprintf('%-12s | %-10s | %-10s\n', 'Method', 'PCC (Time)', 'MSE (TF)');
    fprintf('--------------------------------------------\n');
    fprintf('%-12s | %10.4f | %.4e\n', 'Observation', pcc_observe_time, mse_observe_tf);
    fprintf('%-12s | %10.4f | %.4e\n', 'GLA', pcc_gla_time, mse_gla_tf);
    fprintf('%-12s | %10.4f | %.4e\n', 'OT', pcc_ot_time, mse_ot_tf);
    fprintf('%-12s | %10.4f | %.4e\n', 'DNN', pcc_dnn_time, mse_dnn_tf);
    fprintf('%-12s | %10.4f | %.4e\n', 'ADMM', pcc_admm_time, mse_admm_tf);
    fprintf('%-12s | %10.4f | %.4e\n', 'TESA', pcc_tesa_time, mse_tesa_tf);
    fprintf('--------------------------------------------\n');

    %% --- 9. Pack results into a struct ---
    results = struct(...
        'pcc_observe_time', pcc_observe_time, ...
        'pcc_gla_time', pcc_gla_time, ...
        'pcc_ot_time', pcc_ot_time, ...
        'pcc_dnn_time', pcc_dnn_time, ...
        'pcc_admm_time', pcc_admm_time, ...
        'pcc_tesa_time', pcc_tesa_time, ...
        'mse_observe_tf', mse_observe_tf, ...
        'mse_gla_tf', mse_gla_tf, ...
        'mse_ot_tf', mse_ot_tf, ...
        'mse_dnn_tf', mse_dnn_tf, ...
        'mse_admm_tf', mse_admm_tf, ...
        'mse_tesa_tf', mse_tesa_tf, ...
        'x_gla', x_gla, ...
        'x_ot', x_ot, ...
        'x_dnn', x_dnn, ...
        'x_admm', x_admm, ...
        'x_tesa', x_tesa ...
    );
end