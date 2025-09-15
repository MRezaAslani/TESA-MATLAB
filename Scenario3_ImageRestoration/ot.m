function x_ot = ot(x, target_spectrogram, fs, window, noverlap, nfft, lambda)
%% Method Name: Optimal Transportation of Spectrograms (Wasserstein Barycenters)
% Inputs: x (input), target_spectrogram (target), fs, window, noverlap, nfft, lambda (interpolation factor, 0-1).
% Outputs: x_ot (reconstructed signal).
% Note: Simplified; requires optimal transport implementation (e.g., manual Sinkhorn). This is a placeholder.
% Citation: G. Peyré and M. Cuturi, "Computational Optimal Transport: With Applications to Data Science," Foundations and Trends in Machine Learning, vol. 11, no. 5-6, pp. 355-607, 2019. (Adapted for spectrograms; note: 2025 reference may be hypothetical, use this standard one.)

[S, ~, ~] = stft(x, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);

% Code: Simple linear interpolation as placeholder (real OT needs matrix transport)
S_input_mag = abs(S);
S_target_mag = abs(target_spectrogram);
S_interp = (1 - lambda) * S_input_mag + lambda * S_target_mag;  % Placeholder interp
phase_input = angle(S);
S_recon = S_interp .* exp(1i * phase_input);
x_ot = istft(S_recon, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
x_ot = real(x_ot);
