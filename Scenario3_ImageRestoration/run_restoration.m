function results = run_restoration(image_name)
    % This function runs the image restoration experiment for a given image name
    % and returns the evaluation metrics as a struct.

    %% --- 1. Define and load images ---
    % Load the clean image (ground truth) and create a damaged version by zeroing a central square.
    clean_image = imread(image_name);
    if ndims(clean_image) == 3
        clean_image = sum(clean_image, 3);  % Convert to grayscale if RGB
    end
    
    % Downsampling (If your processor is slow, you can use downsampling to get an estimate of the calculations)
    clean_image = imresize(clean_image, [128, 128]);
    clean_image = rescale(clean_image);  % Normalize to [0, 1]

    [m, n] = size(clean_image);

    % Create damaged image by setting a central square to zero (simulating damage)
    damageAmount = 0.5; % A value of 0 indecates an image with no distortion, and a value of 1 signifies complete damage
    square_size = round(min(m, n) * damageAmount);
    start_row = round(m/2 - square_size/2) + 1;
    end_row = start_row + square_size - 1;
    start_col = round(n/2 - square_size/2) + 1;
    end_col = start_col + square_size - 1;

    damaged_image = clean_image;
    damaged_image(start_row:end_row, start_col:end_col) = 0;

    % Flatten images to 1D vectors for STFT processing
    clean_imageVec = clean_image(:);
    damaged_imageVec = damaged_image(:);

    % Set sampling rate as the number of samples (pixels), as per request
    fs = length(clean_imageVec);

    % Compute STFT of the clean and damaged vectors
    win_len = 512;
    noverlap = round(0.88 * win_len);
    nfft = win_len;
    window = hamming(win_len);

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
    lambda = 0.5;
    x_ot = ot(damaged_imageVec, target_spectrogram, fs, window, noverlap, nfft, lambda);
    x_ot = rescale(x_ot);

    % DNN-based Phase Reconstruction
    x_dnn = dnn(damaged_imageVec, target_spectrogram, fs, window, noverlap, nfft);
    x_dnn = rescale(x_dnn);

    % Alternating Direction Method of Multipliers (ADMM)
    num_iters = 20;
    x_admm = admm(damaged_imageVec, target_spectrogram, fs, window, noverlap, nfft, num_iters);
    x_admm = rescale(x_admm);

    % Time-Enhanced Spectrogram Alignment (TESA)
    stft_params = struct('fs', fs, 'window', window, ...
                     'noverlap', noverlap, 'nfft', nfft);
    tesa_params = struct('lambda', 1e-5, 'alpha', 1e-2, 'num_iter', 10000, ...
                     'beta1', 0.9, 'beta2', 0.999);
    x_tesa = tesa(damaged_imageVec, target_spectrogram, stft_params, tesa_params);
    x_tesa = rescale(x_tesa);

    %% --- 4. Calculate Spectrogram of the outputs ---
    S_gla = abs(stft(x_gla, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    S_ot = abs(stft(x_ot, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    S_dnn = abs(stft(x_dnn, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    S_admm = abs(stft(x_admm, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    S_tesa = abs(stft(x_tesa, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));

    %% --- 5. Evaluation Metrics in Time Domain (Image Domain) ---
    % 5.1. Signal-to-Noise Ratio (SNR)
    snr_observe_time = 10*log10(var(clean_imageVec)/var(clean_imageVec - damaged_imageVec));
    snr_gla_time = 10*log10(var(clean_imageVec)/var(clean_imageVec - x_gla));
    snr_ot_time = 10*log10(var(clean_imageVec)/var(clean_imageVec - x_ot));
    snr_dnn_time = 10*log10(var(clean_imageVec)/var(clean_imageVec - x_dnn));
    snr_admm_time = 10*log10(var(clean_imageVec)/var(clean_imageVec - x_admm));
    snr_tesa_time = 10*log10(var(clean_imageVec)/var(clean_imageVec - x_tesa));

    % 5.2. Mean Square Error (MSE)
    mse_observe_time = mean((clean_imageVec - damaged_imageVec).^2);
    mse_gla_time = mean((clean_imageVec - x_gla).^2);
    mse_ot_time = mean((clean_imageVec - x_ot).^2);
    mse_dnn_time = mean((clean_imageVec - x_dnn).^2);
    mse_admm_time = mean((clean_imageVec - x_admm).^2);
    mse_tesa_time = mean((clean_imageVec - x_tesa).^2);

    % 5.3. Pearson Correlation Coefficient (PCC)
    pcc_observe_time = corr(clean_imageVec(:), damaged_imageVec(:));
    pcc_gla_time = corr(clean_imageVec(:), x_gla(:));
    pcc_ot_time = corr(clean_imageVec(:), x_ot(:));
    pcc_dnn_time = corr(clean_imageVec(:), x_dnn(:));
    pcc_admm_time = corr(clean_imageVec(:), x_admm(:));
    pcc_tesa_time = corr(clean_imageVec(:), x_tesa(:));

    %% --- 6. Evaluation Metrics in Time-Frequency Domain ---
    % 6.1. Signal-to-Noise Ratio (SNR)
    snr_observe_tf = 10*log10(var(S_clean(:))/var(S_clean(:) - S_damaged(:)));
    snr_gla_tf = 10*log10(var(S_clean(:))/var(S_clean(:) - S_gla(:)));
    snr_ot_tf = 10*log10(var(S_clean(:))/var(S_clean(:) - S_ot(:)));
    snr_dnn_tf = 10*log10(var(S_clean(:))/var(S_clean(:) - S_dnn(:)));
    snr_admm_tf = 10*log10(var(S_clean(:))/var(S_clean(:) - S_admm(:)));
    snr_tesa_tf = 10*log10(var(S_clean(:))/var(S_clean(:) - S_tesa(:)));

    % 6.2. Mean Square Error (MSE)
    mse_observe_tf = mean((S_clean(:) - S_damaged(:)).^2);
    mse_gla_tf = mean((S_clean(:) - S_gla(:)).^2);
    mse_ot_tf = mean((S_clean(:) - S_ot(:)).^2);
    mse_dnn_tf = mean((S_clean(:) - S_dnn(:)).^2);
    mse_admm_tf = mean((S_clean(:) - S_admm(:)).^2);
    mse_tesa_tf = mean((S_clean(:) - S_tesa(:)).^2);

    % 6.3. Pearson Correlation Coefficient (PCC)
    pcc_observe_tf = corr(S_clean(:), S_damaged(:));
    pcc_gla_tf = corr(S_clean(:), S_gla(:));
    pcc_ot_tf = corr(S_clean(:), S_ot(:));
    pcc_dnn_tf = corr(S_clean(:), S_dnn(:));
    pcc_admm_tf = corr(S_clean(:), S_admm(:));
    pcc_tesa_tf = corr(S_clean(:), S_tesa(:));

    %% --- 7. Display Results as Images ---
    clean_image_restored = reshape([clean_imageVec; zeros(m*n-length(x_gla),1)], m, n);
    damaged_image_restored = reshape([damaged_imageVec; zeros(m*n-length(x_gla),1)], m, n);
    x_gla_image = reshape([x_gla; zeros(m*n-length(x_gla),1)], m, n);
    x_ot_image = reshape([x_ot; zeros(m*n-length(x_gla),1)], m, n);
    x_dnn_image = reshape([x_dnn; zeros(m*n-length(x_gla),1)], m, n);
    x_admm_image = reshape([x_admm; zeros(m*n-length(x_gla),1)], m, n);
    x_tesa_image = reshape([x_tesa; zeros(m*n-length(x_gla),1)], m, n);

    figure('Name', ['Restoration Results for ', image_name], 'NumberTitle', 'off', 'Position', [100, 100, 1200, 600]);
    subplot(2, 4, 1); imagesc(clean_image_restored); title('Clean'); colormap(gray); axis equal tight;
    subplot(2, 4, 2); imagesc(damaged_image_restored); title('Damaged'); colormap(gray); axis equal tight;
    subplot(2, 4, 3); imagesc(x_gla_image); title('GLA'); colormap(gray); axis equal tight;
    subplot(2, 4, 4); imagesc(x_ot_image); title('OT'); colormap(gray); axis equal tight;
    subplot(2, 4, 5); imagesc(x_dnn_image); title('DNN'); colormap(gray); axis equal tight;
    subplot(2, 4, 6); imagesc(x_admm_image); title('ADMM'); colormap(gray); axis equal tight;
    subplot(2, 4, 7); imagesc(x_tesa_image); title('TESA'); colormap(gray); axis equal tight;
    
    % Create output directory if it doesn't exist
    output_dir = 'results';
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    % Extract file name without path
    [~, name, ~] = fileparts(image_name);
    
    % Save the figure with high quality
    output_file = fullfile(output_dir, ['restoration_', name, '.png']);
    if exist('exportgraphics', 'file')
        exportgraphics(gcf, output_file, 'Resolution', 300, 'ContentType', 'image');
    else
        print(gcf, output_file, '-dpng', '-r300');
    end

    %% --- 8. Pack results into a struct ---
    results = struct(...
        'snr_observe_time', snr_observe_time, ...
        'snr_gla_time', snr_gla_time, ...
        'snr_ot_time', snr_ot_time, ...
        'snr_dnn_time', snr_dnn_time, ...
        'snr_admm_time', snr_admm_time, ...
        'snr_tesa_time', snr_tesa_time, ...
        'mse_observe_time', mse_observe_time, ...
        'mse_gla_time', mse_gla_time, ...
        'mse_ot_time', mse_ot_time, ...
        'mse_dnn_time', mse_dnn_time, ...
        'mse_admm_time', mse_admm_time, ...
        'mse_tesa_time', mse_tesa_time, ...
        'pcc_observe_time', pcc_observe_time, ...
        'pcc_gla_time', pcc_gla_time, ...
        'pcc_ot_time', pcc_ot_time, ...
        'pcc_dnn_time', pcc_dnn_time, ...
        'pcc_admm_time', pcc_admm_time, ...
        'pcc_tesa_time', pcc_tesa_time, ...
        'snr_observe_tf', snr_observe_tf, ...
        'snr_gla_tf', snr_gla_tf, ...
        'snr_ot_tf', snr_ot_tf, ...
        'snr_dnn_tf', snr_dnn_tf, ...
        'snr_admm_tf', snr_admm_tf, ...
        'snr_tesa_tf', snr_tesa_tf, ...
        'mse_observe_tf', mse_observe_tf, ...
        'mse_gla_tf', mse_gla_tf, ...
        'mse_ot_tf', mse_ot_tf, ...
        'mse_dnn_tf', mse_dnn_tf, ...
        'mse_admm_tf', mse_admm_tf, ...
        'mse_tesa_tf', mse_tesa_tf, ...
        'pcc_observe_tf', pcc_observe_tf, ...
        'pcc_gla_tf', pcc_gla_tf, ...
        'pcc_ot_tf', pcc_ot_tf, ...
        'pcc_dnn_tf', pcc_dnn_tf, ...
        'pcc_admm_tf', pcc_admm_tf, ...
        'pcc_tesa_tf', pcc_tesa_tf ...
    );
end


