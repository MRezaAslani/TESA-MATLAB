% -------------------------------------------------------------------------
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)
% Description: cca-based bandpass or notch filtering of a non-stationary signal
% -------------------------------------------------------------------------
% inputs for bandpass
% no
% [40 40]
% [8 8]
% yes

% inputs for bandstop
% no
% [44 44]
% [8 8]
% yes

clc; clear; close all;

%% ----------------------- USER PARAMETERS ----------------------------
filter_mode = 'bandpass';                   % 'bandpass' or 'bandstop'
selected_freq_indices = [3, 6];             % Indices of frequencies to keep/remove
fs = 1024;                                  % Sampling frequency (Hz)

%% -------------------- SIGNAL CONSTRUCTION ---------------------------
t = 0:1/fs:1-1/fs;                          % Time vector (1 second duration)
N = length(t);
freqs = [10, 50, 96, 140, 183, 226, 270, 313, 356, 400]; % 10 target frequencies
num_segments = length(freqs);
segment_length = floor(N / num_segments);  % Safe truncation to 102

% Build the non-stationary signal by concatenating sinusoids
signal = zeros(1, N);
for seg = 1:num_segments
    idx = (seg-1)*segment_length + 1 : seg*segment_length;
    signal(idx) = sin(2*pi*freqs(seg)*t(idx));
end

% Normalize original signal
signal = (signal - mean(signal)) / std(signal);
signal = signal(:)';

%% -------------------- BUILD TARGET SIGNAL ---------------------------
target_signal = zeros(1, N);
if strcmp(filter_mode, 'bandpass')
    % Keep only selected frequency components
    for seg = selected_freq_indices
        idx = (seg-1)*segment_length + 1 : seg*segment_length;
        target_signal(idx) = sin(2*pi*freqs(seg)*t(idx));
    end
elseif strcmp(filter_mode, 'bandstop')
    % Remove selected frequency components (notch filter)
    target_signal = signal;
    for seg = selected_freq_indices
        idx = (seg-1)*segment_length + 1 : seg*segment_length;
        target_signal(idx) = 0;
    end
end

% Normalize target
target_signal = (target_signal - mean(target_signal)) / std(target_signal);
target_signal = target_signal(:)';

%% -------------------- APPLY CCA BASED FILTER -------------------------
index = freqs(selected_freq_indices);
stack = cca(signal);
signal_preprocessed = zeros(size(signal));
bw = 20;
for i = 1 : length(index)
    signal_preprocessed = signal_preprocessed + sum(stack(index(i)-bw:index(i)+bw,:),1);
end

if strcmp(filter_mode, 'bandstop') 
    signal_preprocessed = sum(stack,1) - signal_preprocessed;
end

signal_preprocessed = rescale(signal_preprocessed, -1, 1);
[~, real_coeffs, imag_coeffs] = cca(signal_preprocessed);
real_coeffs(1) = 0;
signal_preprocessed = icca(real_coeffs, imag_coeffs);

freqs_to_filter = freqs(selected_freq_indices);

[filtered_signal_cca, target_spectrogram] = ccaFilter(signal, signal_preprocessed, fs, freqs_to_filter, filter_mode);

%% -------------------- Algo2 Output ----------------------------------
filtered_signal_algo2 = signal_preprocessed;

%% -------------------- STFT Based ------------------------------------
[S, ~, ~] = stft(signal, fs, 'Window', hamming(64), 'OverlapLength', 60, 'FFTLength', 64);
if strcmp(filter_mode, 'bandpass') 
    S(:,sum(target_spectrogram)<0.75*max(sum(target_spectrogram))) = 0;
    S = S.*(abs(S)>0.25*max(max(abs(S))));
elseif strcmp(filter_mode, 'bandstop') 
    filter_mode = 'stop';
    S(:,sum(target_spectrogram)<0.15*max(sum(target_spectrogram))) = 0;
    S = S.*(abs(S)>0.15*max(max(abs(S))));
end

filtered_signal_stft = real(istft(S, fs, 'Window', hamming(64), 'OverlapLength', 60, 'FFTLength', 64))';

%% -------------------- APPLY FIR FILTER ------------------------------
f_low1 = 96 - 10; % 86 Hz
f_high1 = 96 + 10; % 106 Hz
f_low2 = 226 - 10; % 216 Hz
f_high2 = 226 + 10; % 236 Hz
order_fir = 50; % FIR filter order
b_fir1 = fir1(order_fir, [f_low1 f_high1]/(fs/2), filter_mode);
b_fir2 = fir1(order_fir, [f_low2 f_high2]/(fs/2), filter_mode);
filtered_signal_fir1 = filtfilt(b_fir1, 1, signal);
filtered_signal_fir2 = filtfilt(b_fir2, 1, signal);
filtered_signal_fir = filtered_signal_fir1 + filtered_signal_fir2; % Combine outputs

%% -------------------- APPLY Butterworth FILTER ----------------------
[b_butter1, a_butter1] = butter(4, [f_low1 f_high1]/(fs/2), filter_mode);
[b_butter2, a_butter2] = butter(4, [f_low2 f_high2]/(fs/2), filter_mode);
filtered_signal_butter1 = filtfilt(b_butter1, a_butter1, signal);
filtered_signal_butter2 = filtfilt(b_butter2, a_butter2, signal);
filtered_signal_butter = filtered_signal_butter1 + filtered_signal_butter2; % Combine outputs

%% -------------------- NORMALIZE SIGNALS -----------------------------
signal = rescale(signal, -1, 1);
target_signal = rescale(target_signal, -1, 1);
filtered_signal_butter = rescale(filtered_signal_butter, -1, 1);
filtered_signal_fir = rescale(filtered_signal_fir, -1, 1);
filtered_signal_cca = rescale(filtered_signal_cca, -1, 1);
filtered_signal_algo2 = rescale(filtered_signal_algo2, -1, 1);
filtered_signal_stft = rescale(filtered_signal_stft, -1, 1);

%% -------------------- PLOT TIME-DOMAIN SIGNALS ----------------------
figure;
subplot(7,1,1); plot(t, signal); xlabel('Time (s)'); ylabel('Amplitude'); title('Original Signal');
subplot(7,1,2); plot(t, target_signal); xlabel('Time (s)'); ylabel('Amplitude'); title('Target Signal');
subplot(7,1,3); plot(t, filtered_signal_cca); xlabel('Time (s)'); ylabel('Amplitude'); title('CCA Signal');
subplot(7,1,4); plot(t, filtered_signal_fir); xlabel('Time (s)'); ylabel('Amplitude'); title('FIR Signal');
subplot(7,1,5); plot(t, filtered_signal_butter); xlabel('Time (s)'); ylabel('Amplitude'); title('Butter Signal');
subplot(7,1,6); plot(t, filtered_signal_algo2); xlabel('Time (s)'); ylabel('Amplitude'); title('Algo2 Signal');
subplot(7,1,7); plot(t, filtered_signal_stft); xlabel('Time (s)'); ylabel('Amplitude'); title('STFT Signal');

%% -------------------- DISPLAY SPECTROGRAMS --------------------------
time_bins = length(signal);
freq_bins = time_bins/2;
window = hamming(64); % 256-point Hamming window for STFT
noverlap = 60; % 250-sample overlap for STFT
nfft = 64; % 256-point FFT length for STFT

figure;
subplot(3,3,1);
[S, f_spec, t_spec] = stft(signal, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
spectrogram = imresize(flipud(abs(S(1:floor(nfft/2), :))), [freq_bins, time_bins]);
imagesc(t_spec, f_spec(1:floor(nfft/2)), spectrogram);
colormap('jet');
title('Original Signal Spectrogram');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;

% Target Signal Spectrogram
subplot(3,3,2);
[S_target, f_spec, t_spec] = stft(target_signal, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
spectrogram = imresize(flipud(abs(S_target(1:floor(nfft/2), :))), [freq_bins, time_bins]);
imagesc(t_spec, f_spec(1:floor(nfft/2)), spectrogram);
colormap('jet');
title('Target Signal Spectrogram');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;

subplot(3,3,3);
[S_butter, f_spec, t_spec] = stft(filtered_signal_butter, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
spectrogram_butter = imresize(flipud(abs(S_butter(1:floor(nfft/2), :))), [freq_bins, time_bins]);
imagesc(t_spec, f_spec(1:floor(nfft/2)), spectrogram_butter);
colormap('jet');
title('Butter Spectrogram (Butterworth)');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;

subplot(3,3,4);
[S_fir, f_spec, t_spec] = stft(filtered_signal_fir, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
spectrogram_fir = imresize(flipud(abs(S_fir(1:floor(nfft/2), :))), [freq_bins, time_bins]);
imagesc(t_spec, f_spec(1:floor(nfft/2)), spectrogram_fir);
colormap('jet');
title('FIR Spectrogram (FIR)');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;

subplot(3,3,5);
[S_cca, f_spec, t_spec] = stft(filtered_signal_cca, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
spectrogram_cca = imresize(flipud(abs(S_fir(1:floor(nfft/2), :))), [freq_bins, time_bins]);
imagesc(t_spec, f_spec(1:floor(nfft/2)), spectrogram_cca);
colormap('jet');
title('CCA Spectrogram');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;

subplot(3,3,6);
[S_algo2, f_spec, t_spec] = stft(filtered_signal_algo2, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
spectrogram_algo2 = imresize(flipud(abs(S_fir(1:floor(nfft/2), :))), [freq_bins, time_bins]);
imagesc(t_spec, f_spec(1:floor(nfft/2)), spectrogram_algo2);
colormap('jet');
title('Algo2 Spectrogram');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;

subplot(3,3,7);
[S_stft, f_spec, t_spec] = stft(filtered_signal_stft, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
spectrogram_stft = imresize(flipud(abs(S_fir(1:floor(nfft/2), :))), [freq_bins, time_bins]);
imagesc(t_spec, f_spec(1:floor(nfft/2)), spectrogram_stft);
colormap('jet');
title('STFT Spectrogram');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;

%% -------------------- METRIC EVALUATION -----------------------------
% 1. Spectral Similarity (Spectrogram MSE)
mse_spectrogram_butter = mean((S_target(:) - S_butter(:)).^2);
mse_spectrogram_fir = mean((S_target(:) - S_fir(:)).^2);
mse_spectrogram_cca = mean((S_target(:) - S_cca(:)).^2);
mse_spectrogram_algo2 = mean((S_target(:) - S_algo2(:)).^2);
mse_spectrogram_stft = mean((S_target(:) - S_stft(:)).^2);

pcc_spectrogram_butter = corr(S_target(:), S_butter(:));
pcc_spectrogram_fir = corr(S_target(:), S_fir(:));
pcc_spectrogram_cca = corr(S_target(:), S_cca(:));
pcc_spectrogram_algo2 = corr(S_target(:), S_algo2(:));
pcc_spectrogram_stft = corr(S_target(:), S_stft(:));

snr_spectrogram_butter = 10*log10(var(S_target(:))/var(S_target(:) - S_butter(:)));
snr_spectrogram_fir = 10*log10(var(S_target(:))/var(S_target(:) - S_fir(:)));
snr_spectrogram_cca = 10*log10(var(S_target(:))/var(S_target(:) - S_cca(:)));
snr_spectrogram_algo2 = 10*log10(var(S_target(:))/var(S_target(:) - S_algo2(:)));
snr_spectrogram_stft = 10*log10(var(S_target(:))/var(S_target(:) - S_stft(:)));

fprintf('\n--- Butterworth Spectrogram Metrics ---\n');
fprintf('PCC: %2.4f | MSE: %.2e | SNR(db): %4.4f\n', pcc_spectrogram_butter, mse_spectrogram_butter, snr_spectrogram_butter);
fprintf('\n--- FIR Spectrogram Metrics ---\n');
fprintf('PCC: %2.4f | MSE: %.2e | SNR(db): %4.4f\n', pcc_spectrogram_fir, mse_spectrogram_fir, snr_spectrogram_fir);
fprintf('\n--- CCA Spectrogram Metrics ---\n');
fprintf('PCC: %2.4f | MSE: %.2e | SNR(db): %4.4f\n', pcc_spectrogram_cca, mse_spectrogram_cca, snr_spectrogram_cca);
fprintf('\n--- Algo2 Spectrogram Metrics ---\n');
fprintf('PCC: %2.4f | MSE: %.2e | SNR(db): %4.4f\n', pcc_spectrogram_algo2, mse_spectrogram_algo2, snr_spectrogram_algo2);
fprintf('\n--- STFT Spectrogram Metrics ---\n');
fprintf('PCC: %2.4f | MSE: %.2e | SNR(db): %4.4f\n', pcc_spectrogram_stft, mse_spectrogram_stft, snr_spectrogram_stft);


% 2. Time-Domain Fidelity (MSE and SNR)
mse_time_butter = mean((target_signal - filtered_signal_butter).^2);
mse_time_fir = mean((target_signal - filtered_signal_fir).^2);
mse_time_cca = mean((target_signal - filtered_signal_cca).^2);
mse_time_algo2 = mean((target_signal - filtered_signal_algo2).^2);
mse_time_stft = mean((target_signal - filtered_signal_stft).^2);

pcc_time_butter = corr(target_signal(:), filtered_signal_butter(:));
pcc_time_fir = corr(target_signal(:), filtered_signal_fir(:));
pcc_time_cca = corr(target_signal(:), filtered_signal_cca(:));
pcc_time_algo2 = corr(target_signal(:), filtered_signal_algo2(:));
pcc_time_stft = corr(target_signal(:), filtered_signal_stft(:));

snr_time_butter = 10*log10(var(target_signal)/var(target_signal - filtered_signal_butter));
snr_time_fir = 10*log10(var(target_signal)/var(target_signal - filtered_signal_fir));
snr_time_cca = 10*log10(var(target_signal)/var(target_signal - filtered_signal_cca));
snr_time_algo2 = 10*log10(var(target_signal)/var(target_signal - filtered_signal_algo2));
snr_time_stft = 10*log10(var(target_signal)/var(target_signal - filtered_signal_stft));

fprintf('\n\n--- Butterworth Temporal Metrics ---\n');
fprintf('PCC: %2.4f | MSE: %.2e | SNR(db): %4.4f\n', pcc_time_butter, mse_time_butter, snr_time_butter);
fprintf('\n--- FIR Temporal Metrics ---\n');
fprintf('PCC: %2.4f | MSE: %.2e | SNR(db): %4.4f\n', pcc_time_fir, mse_time_fir, snr_time_fir);
fprintf('\n--- CCA Temporal Metrics ---\n');
fprintf('PCC: %2.4f | MSE: %.2e | SNR(db): %4.4f\n', pcc_time_cca, mse_time_cca, snr_time_cca);
fprintf('\n--- Algo2 Temporal Metrics ---\n');
fprintf('PCC: %2.4f | MSE: %.2e | SNR(db): %4.4f\n', pcc_time_algo2, mse_time_algo2, snr_time_algo2);
fprintf('\n--- STFT Temporal Metrics ---\n');
fprintf('PCC: %2.4f | MSE: %.2e | SNR(db): %4.4f\n', pcc_time_stft, mse_time_stft, snr_time_stft);


% Results for bandpass
% --- Butterworth Spectrogram Metrics ---
% PCC: 0.9492 | MSE: 1.78e-02 | SNR(db): 9.5468
% 
% --- FIR Spectrogram Metrics ---
% PCC: 0.9647 | MSE: 1.41e-02 | SNR(db): 11.5027
% 
% --- CCA Spectrogram Metrics ---
% PCC: 0.9718 | MSE: 1.37e-02 | SNR(db): 12.2644
% 
% --- Algo2 Spectrogram Metrics ---
% PCC: 0.9630 | MSE: 1.72e-02 | SNR(db): 10.8495
% 
% --- STFT Spectrogram Metrics ---
% PCC: 0.9671 | MSE: 5.53e-03 | SNR(db): 11.4826
% 
% 
% --- Butterworth Temporal Metrics ---
% PCC: 0.9497 | MSE: 1.11e-02 | SNR(db): 9.5781
% 
% --- FIR Temporal Metrics ---
% PCC: 0.9647 | MSE: 7.04e-03 | SNR(db): 11.5033
% 
% --- CCA Temporal Metrics ---
% PCC: 0.9716 | MSE: 5.96e-03 | SNR(db): 12.2322
% 
% --- Algo2 Temporal Metrics ---
% PCC: 0.9638 | MSE: 8.20e-03 | SNR(db): 10.9174
% 
% --- STFT Temporal Metrics ---
% PCC: 0.9672 | MSE: 7.07e-03 | SNR(db): 11.4981



% Results for bandstop
% --- Butterworth Spectrogram Metrics ---
% PCC: 0.9588 | MSE: 1.96e-02 | SNR(db): 10.8965
% 
% --- FIR Spectrogram Metrics ---
% PCC: 0.9462 | MSE: 1.42e-02 | SNR(db): 9.5890
% 
% --- CCA Spectrogram Metrics ---
% PCC: 0.9825 | MSE: 3.46e-03 | SNR(db): 14.0538
% 
% --- Algo2 Spectrogram Metrics ---
% PCC: 0.9897 | MSE: 2.54e-02 | SNR(db): 15.5700
% 
% --- STFT Spectrogram Metrics ---
% PCC: 0.9494 | MSE: 5.11e-01 | SNR(db): 9.3640
% 
% 
% --- Butterworth Temporal Metrics ---
% PCC: 0.9617 | MSE: 3.05e-02 | SNR(db): 11.1917
% 
% --- FIR Temporal Metrics ---
% PCC: 0.9498 | MSE: 4.07e-02 | SNR(db): 9.9094
% 
% --- CCA Temporal Metrics ---
% PCC: 0.9833 | MSE: 1.49e-02 | SNR(db): 14.2716
% 
% --- Algo2 Temporal Metrics ---
% PCC: 0.9911 | MSE: 1.05e-02 | SNR(db): 15.9881
% 
% --- STFT Temporal Metrics ---
% PCC: 0.9776 | MSE: 4.73e-02 | SNR(db): 11.3267

