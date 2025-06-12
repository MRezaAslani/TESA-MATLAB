% -------------------------------------------------------------------------
% File: main_decomposition_demo.m
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)
% Description: Time-frequency component decomposition using DSCA
% -------------------------------------------------------------------------

clc; clear; close all;
rng(2);  % For reproducibility

%% ----------------------- Signal Parameters ----------------------------
fs = 1024;                      % Sampling frequency (Hz)
t = 0:1/fs:1-1/fs;              % Time vector (1 second)
N = length(t);

% Window parameters for STFT
window = hamming(256);
noverlap = 250;
nfft = 256;

% Parameters for signal generation
num_components = 6;             % Number of random segments
freqs = [10, 50, 96, 140, 183, 226, 270, 313, 356, 400];
min_segment_length = 50;       % Minimum segment length
max_segment_length = 280;      % Maximum segment length
plot_flag = false;

%% -------------------- Generate Non-Stationary Signal ------------------
signal = generateNonStationarySignal(N, fs, num_components, freqs, min_segment_length, max_segment_length, plot_flag);
signal_zeros = zeros(1, round(1.2 * N));
start_idx = round(0.1 * N) + 1;
signal_zeros(start_idx:start_idx+N-1) = signal;

%% -------------------- Compute Spectrogram -----------------------------
freq_bins = N / 2;
time_bins = N;
[S, ~, ~] = stft(signal_zeros, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
spectrogram = imresize(flipud(abs(S(1:floor(nfft/2), :))), [freq_bins, time_bins]);
spectrogram = spectrogram - min(spectrogram(:));
spectrogram = spectrogram / max(spectrogram(:));

%% ------------------ Binary Mask + Decomposition ------------------------
binary_mask = spectrogram > 0.15;  % Binary segmentation threshold

% Use binary components to build target masks
target_spec = decomposeBinaryComponents(binary_mask);
num_parts = size(target_spec, 3);
target_spec = target_spec .* repmat(spectrogram, 1, 1, num_parts);

%% ------------------ Extract Time-Frequency Components ------------------
num_decomp = num_components - 1;  % Number of components to extract
decomposed_signal = zeros(num_decomp, N);

for i = 1:num_decomp
    extracted = dscaExtraction(signal_zeros, fs, squeeze(target_spec(:,:,i)));
    decomposed_signal(i,:) = extracted(start_idx:start_idx+N-1);
end

%% ---------------------- Time-Domain Plot -------------------------------
figure;
subplot(num_decomp+1,1,1); plot(signal(1:1000)/max(abs(signal(1:1000)))); title('Original Signal');
for i = 1:num_decomp
    subplot(num_decomp+1,1,i+1);
    plot(decomposed_signal(i,1:1000)/max(abs(decomposed_signal(i,1:1000))));
    title("Component " + num2str(i));
end

%% --------------------- Spectrogram Plots -------------------------------
figure;
% Original
subplot(3,2,1);
[S, ~, ~] = stft(signal, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
spectrogram = imresize(flipud(abs(S(1:floor(nfft/2), :))), [freq_bins, time_bins]);
spectrogram = spectrogram - min(spectrogram(:));
spectrogram = spectrogram / max(spectrogram(:));
imshow(spectrogram); colormap('jet'); title('Original Signal');

% Components
for i = 1:num_decomp
    subplot(3,2,i+1);
    [S, ~, ~] = stft(decomposed_signal(i,:), fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    spectrogram = imresize(flipud(abs(S(1:floor(nfft/2), :))), [freq_bins, time_bins]);
    spectrogram = spectrogram - min(spectrogram(:));
    spectrogram = spectrogram / max(spectrogram(:));
    imshow(spectrogram); colormap('jet');
    title(['Component ' num2str(i)]);
end


%% Metrics
reconstructed_signal = sum(decomposed_signal);

reconstructed_signal = 1.3*rescale(reconstructed_signal, -1, 1);
original_signal = rescale(signal, -1, 1);

SNR_val = snr(reconstructed_signal, original_signal - reconstructed_signal);
RMSE_val = sqrt(mean((original_signal - reconstructed_signal).^2));
Corr_val = corr(original_signal(:), reconstructed_signal(:));

C = corrcoef(decomposed_signal');
maxCorr = max(max(abs(C - eye(size(C)))));
