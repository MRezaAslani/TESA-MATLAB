%--------------------------------------------------------------------------
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)
% Description: DSCA-based signal decomposition using a composite chirp.
%              Includes grouping of subbands, spectrogram visualization,
%              and evaluation using SNR, RMSE, and correlation metrics.
%--------------------------------------------------------------------------

clc; clear; close all;

%% Parameters
fs = 1024;                 % Sampling frequency in Hz
N = 1024;                  % Signal length
time_bins = N;
freq_bins = N / 2;

%% Generate Input Signal
x = generate_chirp(fs, N);

%% STFT Parameters
window = hamming(256);        
noverlap = 250;
nfft = 256;

%% Plot Time-Domain Signal
t = (0:N-1)/fs;
figure;
subplot(2,1,1);
plot(t, x);
title('Time-domain Signal'); xlabel('Time (s)'); ylabel('Amplitude');

%% Spectrogram of Original Signal
subplot(2,1,2);
[S, ~, ~] = stft(x, fs, 'Window', window, ...
    'OverlapLength', noverlap, 'FFTLength', nfft);
spec = imresize(flipud(abs(S(1:floor(nfft/2), :))), [freq_bins, time_bins]);
spec = (spec - min(spec(:))) / (max(spec(:)) - min(spec(:)));  % Normalize
imshow(spec, 'XData', [0 N-1], 'YData', [0 freq_bins-1]);
set(gca, 'YDir', 'normal');
colormap('jet'); axis on;
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
title('Spectrogram of Original Signal');

%% DSCA Decomposition (Assumes dsca.m exists in path)
subbands = dsca(x);

%% Group Subbands into 4 Frequency Bands
num_subbands = size(subbands, 1);
group_size = num_subbands / 4;
groups = zeros(4, N);

figure;
for i = 1:4
    range = (i-1)*group_size + 1 : i*group_size;
    groups(i,:) = mean(subbands(range, :), 1);
    subplot(4,1,i);
    plot(groups(i,1:1000));
    title(['Subband Group ', num2str(i)]);
end

%% Spectrograms of Grouped Subbands
figure;
for i = 1:4
    subplot(2,2,i);
    [Sg, ~, ~] = stft(groups(i,:), fs, 'Window', window, ...
        'OverlapLength', noverlap, 'FFTLength', nfft);
    spec_g = imresize(flipud(abs(Sg(1:floor(nfft/2), :))), [freq_bins, time_bins]);
    spec_g = (spec_g - min(spec_g(:))) / (max(spec_g(:)) - min(spec_g(:)));
    imshow(spec_g, 'XData', [0 N-1], 'YData', [0 freq_bins-1]);
    set(gca, 'YDir', 'normal');
    colormap('jet'); axis on;
    xlabel('Time (ms)'); ylabel('Frequency (Hz)');
    title(['Spectrogram of Group ', num2str(i)]);
    colormap('jet'); axis on;
end

%% Signal Reconstruction
x_recon = sum(groups, 1);
x_recon = rescale(x_recon, -1, 1);

%% Amplitudes and Energies
VLF_amp  = max(abs(groups(1,:)));
MF_amp   = max(abs(groups(2,:)));
HF_amp   = max(abs(groups(3,:)));
VHF_amp  = max(abs(groups(4,:)));

VLF_energy  = sum(groups(1,:).^2);
MF_energy   = sum(groups(2,:).^2);
HF_energy   = sum(groups(3,:).^2);
VHF_energy  = sum(groups(4,:).^2);

%% Evaluate Reconstruction Accuracy
[SNR_val, RMSE_val, Corr_val, maxCorr] = metrics_signal(x, x_recon, groups);

%% Display Metrics
fprintf('\n--- Subband Amplitudes ---\n');
fprintf('VLF: %.4f | MF: %.4f | HF: %.4f | VHF: %.4f\n', VLF_amp, MF_amp, HF_amp, VHF_amp);

fprintf('\n--- Subband Energies ---\n');
fprintf('VLF: %.4f | MF: %.4f | HF: %.4f | VHF: %.4f\n', VLF_energy, MF_energy, HF_energy, VHF_energy);

fprintf('\n--- Reconstruction Metrics ---\n');
fprintf('SNR: %.2f dB | RMSE: %.2e | Corr: %.4f | Max Corr between groups: %.2e\n', ...
        SNR_val, RMSE_val, Corr_val, maxCorr);
