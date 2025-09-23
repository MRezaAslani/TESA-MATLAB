% This function runs the audio source separation experiment for a given mixture and reference audio file
% and returns the evaluation metrics (SDR, MSE) and reconstructed signals as a struct.

function results = run_separation(mixture_file, source_file)
    
    % TESA Parameters
    lambda = 0;
    alpha = 1e-2;
    num_iter = 10000;
    beta1 = 0.9;
    beta2 = 0.999;

    % STFT Parameters
    win_len = 512;
    noverlap = round(0.85*win_len);
    nfft = win_len;
    window = hamming(win_len);

    %% --- 1. Define and load signals ---
    [source, ~] = audioread(source_file);
    [mixture, fs] = audioread(mixture_file);
    
    % Downsampling (optional for faster processing)
    ndown = 1;
    source = source(1:ndown:end);
    mixture = mixture(1:ndown:end);
    fs = fs / ndown;

    % Length Alignment
    [S_sourrce, ~, ~] = stft(source, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    min_len = length(istft(S_sourrce, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    source = source(1:min_len);
    mixture = mixture(1:min_len);

    % Preprocessing (aligned with Scenario 1)
    source = rescale(source, -0.5, 0.5); % Match main_experiment.m
    source = source - mean(source);
    mixture = rescale(mixture, -0.5, 0.5); % Match main_experiment.m
    mixture = mixture - mean(mixture);

    [S_source, ~, ~] = stft(source, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    [S_mixture, ~, ~] = stft(mixture, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    S_mixture = abs(S_mixture);
    S_source = abs(S_source);

    %% --- 2. Create the Target Spectrogram ---
    target_spectrogram = S_source;

    %% --- 3. Apply Methods ---
    results = struct('fs', fs);

    % Method Name: Observation (mixture itself)
    results.x_observe = mixture;
    results.sdr_observe_time = 10*log10(var(source) / var(source - mixture));
    results.mse_observe_tf = mean((S_source(:) - S_mixture(:)).^2);

    % Method Name: Griffin-Lim Algorithm (GLA)
    x_gla = gla(mixture, target_spectrogram, fs, window, noverlap, nfft, 100);
    x_gla = rescale(x_gla, -0.5, 0.5);
    x_gla = x_gla - mean(x_gla);
        
    S_gla = abs(stft(x_gla, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    results.x_gla = x_gla;
    results.sdr_gla_time = 10*log10(var(source) / var(source - x_gla));
    results.mse_gla_tf = mean((S_source(:) - S_gla(:)).^2);
    
    % Method Name: Optimal Transport (OT)
    x_ot = ot(mixture, target_spectrogram, fs, window, noverlap, nfft, 0.5);
    x_ot = rescale(x_ot, -0.5, 0.5);
    x_ot = x_ot - mean(x_ot);
    S_ot = abs(stft(x_ot, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    results.x_ot = x_ot;
    results.sdr_ot_time = 10*log10(var(source) / var(source - x_ot));
    results.mse_ot_tf = mean((S_source(:) - S_ot(:)).^2);
    
    % Method Name: Deep Neural Network (DNN)
    x_dnn = dnn(mixture, target_spectrogram, fs, window, noverlap, nfft);
    x_dnn = rescale(x_dnn, -0.5, 0.5);
    x_dnn = x_dnn - mean(x_dnn);
    S_dnn = abs(stft(x_dnn, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    results.x_dnn = x_dnn;
    results.sdr_dnn_time = 10*log10(var(source) / var(source - x_dnn));
    results.mse_dnn_tf = mean((S_source(:) - S_dnn(:)).^2);
   
    % Method Name: Alternating Direction Method of Multipliers (ADMM)
    x_admm = admm(mixture, target_spectrogram, fs, window, noverlap, nfft, 100);
    x_admm = rescale(x_admm, -0.5, 0.5);
    x_admm = x_admm - mean(x_admm);
    S_admm = abs(stft(x_admm, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    results.x_admm = x_admm;
    results.sdr_admm_time = 10*log10(var(source) / var(source - x_admm));
    results.mse_admm_tf = mean((S_source(:) - S_admm(:)).^2);
    
    % Method Name: Time-Enhanced Spectrogram Alignment (TESA)
    stft_params = struct('fs', fs, 'window', window, 'noverlap', noverlap, 'nfft', nfft);
    tesa_params = struct('lambda', lambda, 'alpha', alpha, 'num_iter', num_iter, ...
                         'beta1', beta1, 'beta2', beta2);
    x_tesa = tesa(mixture, target_spectrogram, stft_params, tesa_params);
    x_tesa = rescale(x_tesa, -0.5, 0.5);
    x_tesa = x_tesa - mean(x_tesa);
    S_tesa = abs(stft(x_tesa, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    results.x_tesa = x_tesa;
    results.sdr_tesa_time = 10*log10(var(source) / var(source - x_tesa));
    results.mse_tesa_tf = mean((S_source(:) - S_tesa(:)).^2);
end
