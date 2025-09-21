% run_denoising: Performs noise reduction on a noisy audio signal and evaluates
% the results against a clean signal using SNR for time domain and MSE for time-frequency domain.
%
% Inputs:
%   noisy_speech (vector): Noisy audio signal.
%   clean_speech (vector): Clean audio signal (ground truth).
%   fs (scalar): Sampling frequency.
%
% Outputs:
%   results (struct): Structure containing reconstructed signals and metrics:
%                     x_<method> (reconstructed signals for gla, ot, dnn, admm, tesa)
%                     snr_<method>_time (SNR in time domain)
%                     mse_<method>_tf (MSE in time-frequency domain)

function results = run_denoising(noisy_speech, clean_speech, fs)

% Tesa Parameters
lambda = 0;
alpha = 2e-1;
num_iter = 3000;
beta1 = 0.9;
beta2 = 0.999;

% STFT Parameters
win_len = 512;
noverlap = round(0.85*win_len);
nfft = win_len;
window = hamming(win_len);

% --- 1. Preprocess signals ---
ndown = 1;
clean_speech = clean_speech(1:ndown:end);
noisy_speech = noisy_speech(1:ndown:end);
fs = fs/ndown;

[S_clean, ~, ~] = stft(clean_speech, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
min_len = length(istft(S_clean, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
clean_speech = clean_speech(1:min_len);
noisy_speech = noisy_speech(1:min_len);

results.snr_observe_time = 10*log10(var(clean_speech)/var(clean_speech - noisy_speech));

clean_speech = rescale(clean_speech, -0.5, 0.5);
clean_speech = clean_speech - mean(clean_speech);
noisy_speech = rescale(noisy_speech, -0.5, 0.5);
noisy_speech = noisy_speech - mean(noisy_speech);

[S_clean, ~, ~] = stft(clean_speech, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
[S_noisy, ~, ~] = stft(noisy_speech, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
S_noisy = abs(S_noisy);
S_clean = abs(S_clean);

% --- 2. Create the target spectrogram ---
target_spectrogram = S_clean;

% --- 3. Apply noise reduction methods ---
x_gla = gla(noisy_speech, target_spectrogram, fs, window, noverlap, nfft, 100);
x_gla = rescale(x_gla, -0.5, 0.5);
x_gla = x_gla - mean(x_gla);

x_ot = ot(noisy_speech, target_spectrogram, fs, window, noverlap, nfft, 0.5);
x_ot = rescale(x_ot, -0.5, 0.5);
x_ot = x_ot - mean(x_ot);

x_dnn = dnn(noisy_speech, target_spectrogram, fs, window, noverlap, nfft);
x_dnn = rescale(x_dnn, -0.5, 0.5);
x_dnn = x_dnn - mean(x_dnn);

x_admm = admm(noisy_speech, target_spectrogram, fs, window, noverlap, nfft, 100);
x_admm = rescale(x_admm, -0.5, 0.5);
x_admm = x_admm - mean(x_admm);

stft_params = struct('fs', fs, 'window', window, 'noverlap', noverlap, 'nfft', nfft);
tesa_params = struct('lambda', lambda, 'alpha', alpha, 'num_iter', num_iter, ...
                     'beta1', beta1, 'beta2', beta2);
x_tesa = tesa(noisy_speech, target_spectrogram, stft_params, tesa_params);
x_tesa = rescale(x_tesa, -0.5, 0.5);
x_tesa = x_tesa - mean(x_tesa);

% --- 4. Calculate spectrograms of the outputs ---
S_gla = abs(stft(x_gla, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
S_ot = abs(stft(x_ot, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
S_dnn = abs(stft(x_dnn, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
S_admm = abs(stft(x_admm, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
S_tesa = abs(stft(x_tesa, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));

% --- 5. Evaluation metrics in time domain ---
results.snr_gla_time = 10*log10(var(clean_speech)/var(clean_speech - x_gla));
results.snr_ot_time = 10*log10(var(clean_speech)/var(clean_speech - x_ot));
results.snr_dnn_time = 10*log10(var(clean_speech)/var(clean_speech - x_dnn));
results.snr_admm_time = 10*log10(var(clean_speech)/var(clean_speech - x_admm));
results.snr_tesa_time = 10*log10(var(clean_speech)/var(clean_speech - x_tesa));

% --- 6. Evaluation metrics in time-frequency domain ---
results.mse_observe_tf = mean((S_clean(:) - S_noisy(:)).^2);
results.mse_gla_tf = mean((S_clean(:) - S_gla(:)).^2);
results.mse_ot_tf = mean((S_clean(:) - S_ot(:)).^2);
results.mse_dnn_tf = mean((S_clean(:) - S_dnn(:)).^2);
results.mse_admm_tf = mean((S_clean(:) - S_admm(:)).^2);
results.mse_tesa_tf = mean((S_clean(:) - S_tesa(:)).^2);

% Store reconstructed signals
results.x_gla = x_gla;
results.x_ot = x_ot;
results.x_dnn = x_dnn;
results.x_admm = x_admm;
results.x_tesa = x_tesa;

end