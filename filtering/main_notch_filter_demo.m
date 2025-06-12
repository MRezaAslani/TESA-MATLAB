% -------------------------------------------------------------------------
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)
% Description: DSCA-based bandpass or notch filtering of a non-stationary signal
% -------------------------------------------------------------------------

clc; clear; close all;

%% ----------------------- USER PARAMETERS ----------------------------
filter_mode = 'notch';                        % 'bpf' (bandpass) or 'notch'
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
if strcmp(filter_mode, 'bpf')
    % Keep only selected frequency components
    for seg = selected_freq_indices
        idx = (seg-1)*segment_length + 1 : seg*segment_length;
        target_signal(idx) = sin(2*pi*freqs(seg)*t(idx));
    end
else
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

%% -------------------- APPLY DSCA FILTER -----------------------------
padded_signal = zeros(1, round(1.2 * N));   % Padding for boundary effects
start_idx = round(0.1 * N) + 1;
padded_signal(start_idx:start_idx+N-1) = signal;

filtered_signal = dscaFilter(padded_signal, fs, freqs(selected_freq_indices), filter_mode);
filtered_signal = filtered_signal(start_idx:start_idx+N-1);

%% -------------------- PLOT TIME-DOMAIN SIGNALS ----------------------
figure;
subplot(3,1,1); plot(t, signal);         title('Original Signal');
subplot(3,1,2); plot(t, target_signal);  title('Target Signal');
subplot(3,1,3); plot(t, max(signal)*filtered_signal/max(filtered_signal)); title('Filtered Signal');

%% -------------------- DISPLAY SPECTROGRAMS --------------------------
displaySpectrogram(signal, fs, 'Original Signal Spectrogram');
displaySpectrogram(target_signal, fs, 'Target Signal Spectrogram');
displaySpectrogram(filtered_signal, fs, 'Filtered Signal Spectrogram');

%% -------------------- METRIC EVALUATION -----------------------------
filtered_signal = rescale(filtered_signal, -1, 1);
target_signal   = rescale(target_signal, -1, 1);
evaluateMetrics(filtered_signal, target_signal);
