function x_gla = gla(x, target_spectrogram, fs, window, noverlap, nfft, num_iters)
%% Method Name: Griffin-Lim Algorithm (GLA)
% Inputs: x (input, for initial phase), target_spectrogram (magnitude target), fs, window, noverlap, nfft, num_iters (e.g., 50).
% Outputs: x_gla (reconstructed signal).
% Citation: D. Griffin and J. Lim, "Signal estimation from modified short-time Fourier transform," IEEE Transactions on Acoustics, Speech, and Signal Processing, vol. 32, no. 2, pp. 236-243, April 1984.
% Additional: N. Perraudin et al., "Fast Griffin-Lim based waveform generation strategy for text-to-speech synthesis," Multispeech, Inria Nancy - Grand Est, 2013.

magnitude_target = abs(target_spectrogram);
phase = angle(stft(x, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));  % Initial phase from input
for iter = 1:num_iters
    S_est = magnitude_target .* exp(1i * phase);
    x_est = istft(S_est, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    [S_new, ~, ~] = stft(x_est, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    phase = angle(S_new);
end
x_gla = real(x_est);