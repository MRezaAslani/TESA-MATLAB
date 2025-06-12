% -------------------------------------------------------------------------
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)
% Description: Arbitrary Time-Frequency Masked Signal Extraction via DSCA
% -------------------------------------------------------------------------

clc; clear; close all;

%% ---------------------- Load Binary Mask -------------------------------
load('mask.mat'); % Assumes variable 'mask' is in grayscale (0–255)

%% ---------------------- Signal Parameters ------------------------------
fs = 1024;                  % Sampling frequency in Hz
t = 0:1/fs:1-1/fs;          % Time vector (1 second duration)
N = length(t);              % Number of samples

% STFT parameters
window = hamming(256);      
noverlap = 250;             
nfft = 256;                 

% Frequency bins and time bins for resized spectrogram
freq_bins = N/2;
time_bins = N;

%% ------------------ Generate Complex Non-Stationary Signal -------------
rng(666);  % For reproducibility

num_components = 25;                          % Number of random segments
available_freqs = [10, 50, 96, 140, 183, ...
                   226, 270, 313, 356, 400]; % Available frequency pool
min_seg_len = 50; max_seg_len = 180;         % Range of segment lengths
plot_flag = false;                           % Disable plotting

signal = generateNonStationarySignal(N, fs, num_components, ...
    available_freqs, min_seg_len, max_seg_len, plot_flag);

%% ------------------ Apply Zero-Padding to Signal ------------------------
padded_signal = zeros(1, round(1.8 * N));
start_idx = round(0.4 * N) + 1;
padded_signal(start_idx:start_idx + N - 1) = signal;

%% ------------------ Compute Spectrogram ---------------------------------
[S, ~, ~] = stft(padded_signal, fs, ...
    'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);

spec_mag = abs(S(1:floor(nfft/2), :));
spec_mag = imresize(flipud(spec_mag), [freq_bins, time_bins]);

% Normalize spectrogram to [0, 1]
spec_mag = spec_mag - min(spec_mag(:));
spec_mag = spec_mag / max(spec_mag(:));

%% ------------------ Resize and Apply Binary Mask ------------------------
% Determine active time columns (energy-based filter)
active_time = sum(spec_mag) > 1.5 * min(sum(spec_mag));

% Resize mask to match frequency x time
mask_resized = imresize(mask / 255, [freq_bins, sum(active_time)]) > 0.5;

% Build binary stack aligned to spectrogram size
mask_stack = zeros(freq_bins, time_bins);
mask_stack(:, active_time) = mask_resized;

% Generate target masked spectrogram
target_spec = spec_mag .* mask_stack;

%% ------------------ DSCA-Based Extraction -------------------------------
extracted = dscaExtraction(padded_signal, fs, target_spec);
extracted = extracted(start_idx:start_idx + N - 1);

% Normalize extracted signal to match amplitude range of original
extracted = extracted - mean(extracted);
extracted = max(signal) * extracted / max(extracted);

%% ------------------ Plot Time-Domain Signals ----------------------------
figure;
subplot(2,1,1); plot(t, signal); title('Original Signal');
subplot(2,1,2); plot(t, extracted); title('Extracted Signal');

%% ------------------ Visualize Spectrograms ------------------------------
% Recompute original spectrogram
[S, ~, ~] = stft(padded_signal, fs, ...
    'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);

orig_spec = imresize(flipud(abs(S(1:floor(nfft/2), :))), ...
    [freq_bins, time_bins]);
orig_spec = orig_spec - min(orig_spec(:));
orig_spec = orig_spec / max(orig_spec(:));

% Apply mask again for visualization
mask_stack = zeros(freq_bins, time_bins);
mask_stack(:, active_time) = mask_resized;
target_spec = orig_spec .* mask_stack;

% Spectrogram of extracted signal
reconstructed = zeros(1, round(1.8 * N));
reconstructed(start_idx:start_idx + N - 1) = extracted;

[S, ~, ~] = stft(reconstructed, fs, ...
    'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);

recon_spec = imresize(flipud(abs(S(1:floor(nfft/2), :))), ...
    [freq_bins, time_bins]);
recon_spec = recon_spec - min(recon_spec(:));
recon_spec = recon_spec / max(recon_spec(:)) * max(target_spec(:));

% Plot spectrograms
figure;
subplot(3,1,1); imshow(orig_spec(:, active_time)); colormap('jet');
title('Original Signal Spectrogram');

subplot(3,1,2); imshow(target_spec(:, active_time)); colormap('jet');
title('Target Masked Spectrogram');

subplot(3,1,3); imshow(recon_spec(:, active_time)); colormap('jet');
title('Extracted Signal Spectrogram');
