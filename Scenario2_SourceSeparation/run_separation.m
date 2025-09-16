function results = run_separation(mixture_file, source_file)
    % This function runs the audio source separation experiment for a given mixture and source audio files
    % and returns the evaluation metrics and reconstructed signals as a struct.

    %% --- 1. Define and load signals ---
    % Load the source (ground truth) and mixture audio files
    [source, ~] = audioread(source_file);
    [mixture, fs] = audioread(mixture_file);

    % Downsampling (If your processor is slow, you can use downsampling to get an estimate of the calculations)
    ndown = 40;
    source = source(1:ndown:end);
    mixture = mixture(1:ndown:end);
    fs = fs / ndown;

    % Compute STFT of the clean and noisy signals
    win_len = 256;
    noverlap = round(0.85 * win_len);
    nfft = win_len;
    window = hamming(win_len);

    % Length Alignment
    [S_source, ~, ~] = stft(source, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    min_len = length(istft(S_source, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));

    source = source(1:min_len);
    mixture = mixture(1:min_len);

    source = rescale(source, -0.5, 0.5);
    source = source - mean(source);
    mixture = rescale(mixture, -0.5, 0.5);
    mixture = mixture - mean(mixture);

    [S_source, ~, ~] = stft(source, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    [S_mixture, ~, ~] = stft(mixture, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    S_mixture = abs(S_mixture);
    S_source = abs(S_source);

    %% --- 2. Create the Target Spectrogram ---
    % Define the mask
    target_spectrogram = S_source;

    %% --- 3. Apply Methods ---
    % Method Name: Griffin-Lim Algorithm (GLA)
    x_gla = gla(mixture, target_spectrogram, fs, window, noverlap, nfft, 100);
    x_gla = rescale(x_gla, -0.5, 0.5);
    x_gla = x_gla - mean(x_gla);

    % Method Name: Optimal Transportation of Spectrograms (Wasserstein Barycenters)
    lambda = 0.5;  % Interpolation between input and target
    x_ot = ot(mixture, target_spectrogram, fs, window, noverlap, nfft, lambda);
    x_ot = rescale(x_ot, -0.5, 0.5);
    x_ot = x_ot - mean(x_ot);

    % Method Name: DNN-based Phase Reconstruction
    x_dnn = dnn(mixture, target_spectrogram, fs, window, noverlap, nfft);
    x_dnn = rescale(x_dnn, -0.5, 0.5);
    x_dnn = x_dnn - mean(x_dnn);

    % Method Name: Alternating Direction Method of Multipliers (ADMM)
    num_iters = 20;
    x_admm = admm(mixture, target_spectrogram, fs, window, noverlap, nfft, num_iters);
    x_admm = rescale(x_admm, -0.5, 0.5);
    x_admm = x_admm - mean(x_admm);

    % Method Name: Time-Enhanced Spectrogram Alignment (TESA) <-- Our Proposed Method
    stft_params = struct('fs', fs, 'window', window, 'noverlap', noverlap, 'nfft', nfft);
    tesa_params = struct('lambda', 1e-5, 'alpha', 1e-2, 'num_iter', 10000, ...
                         'beta1', 0.9, 'beta2', 0.999);
    x_tesa = tesa(mixture, target_spectrogram, stft_params, tesa_params);
    x_tesa = rescale(x_tesa, -0.5, 0.5);
    x_tesa = x_tesa - mean(x_tesa);

    %% --- 4. Calculate Spectrogram of the outputs ---
    S_gla = abs(stft(x_gla, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    S_ot = abs(stft(x_ot, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    S_dnn = abs(stft(x_dnn, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    S_admm = abs(stft(x_admm, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    S_tesa = abs(stft(x_tesa, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));

    %% --- 5. Evaluation Metrics in Time Domain ---
    % Signal-to-Noise Ratio (SNR)
    snr_observe_time = 10*log10(var(source)/var(source - mixture));
    snr_gla_time = 10*log10(var(source)/var(source - x_gla));
    snr_ot_time = 10*log10(var(source)/var(source - x_ot));
    snr_dnn_time = 10*log10(var(source)/var(source - x_dnn));
    snr_admm_time = 10*log10(var(source)/var(source - x_admm));
    snr_tesa_time = 10*log10(var(source)/var(source - x_tesa));

    % Mean Square Error (MSE)
    mse_observe_time = mean((source - mixture).^2);
    mse_gla_time = mean((source - x_gla).^2);
    mse_ot_time = mean((source - x_ot).^2);
    mse_dnn_time = mean((source - x_dnn).^2);
    mse_admm_time = mean((source - x_admm).^2);
    mse_tesa_time = mean((source - x_tesa).^2);

    % Pearson Correlation Coefficient (PCC)
    pcc_observe_time = corr(source(:), mixture(:));
    pcc_gla_time = corr(source(:), x_gla(:));
    pcc_ot_time = corr(source(:), x_ot(:));
    pcc_dnn_time = corr(source(:), x_dnn(:));
    pcc_admm_time = corr(source(:), x_admm(:));
    pcc_tesa_time = corr(source(:), x_tesa(:));

    %% --- 6. Evaluation Metrics in Time-Frequency Domain ---
    % Signal-to-Noise Ratio (SNR)
    snr_observe_tf = 10*log10(var(S_source(:))/var(S_source(:) - S_mixture(:)));
    snr_gla_tf = 10*log10(var(S_source(:))/var(S_source(:) - S_gla(:)));
    snr_ot_tf = 10*log10(var(S_source(:))/var(S_source(:) - S_ot(:)));
    snr_dnn_tf = 10*log10(var(S_source(:))/var(S_source(:) - S_dnn(:)));
    snr_admm_tf = 10*log10(var(S_source(:))/var(S_source(:) - S_admm(:)));
    snr_tesa_tf = 10*log10(var(S_source(:))/var(S_source(:) - S_tesa(:)));

    % Mean Square Error (MSE)
    mse_observe_tf = mean((S_source(:) - S_mixture(:)).^2);
    mse_gla_tf = mean((S_source(:) - S_gla(:)).^2);
    mse_ot_tf = mean((S_source(:) - S_ot(:)).^2);
    mse_dnn_tf = mean((S_source(:) - S_dnn(:)).^2);
    mse_admm_tf = mean((S_source(:) - S_admm(:)).^2);
    mse_tesa_tf = mean((S_source(:) - S_tesa(:)).^2);

    % Pearson Correlation Coefficient (PCC)
    pcc_observe_tf = corr(S_source(:), S_mixture(:));
    pcc_gla_tf = corr(S_source(:), S_gla(:));
    pcc_ot_tf = corr(S_source(:), S_ot(:));
    pcc_dnn_tf = corr(S_source(:), S_dnn(:));
    pcc_admm_tf = corr(S_source(:), S_admm(:));
    pcc_tesa_tf = corr(S_source(:), S_tesa(:));

    %% --- 7. Pack results into a struct ---
    % Include both metrics and reconstructed signals
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
        'pcc_tesa_tf', pcc_tesa_tf, ...
        'x_gla', x_gla, ...
        'x_ot', x_ot, ...
        'x_dnn', x_dnn, ...
        'x_admm', x_admm, ...
        'x_tesa', x_tesa, ...
        'fs', fs ...
    );
end