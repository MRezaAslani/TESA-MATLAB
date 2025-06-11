function [SNR_val, RMSE_val, Corr_val, maxCorr] = metrics_signal(x, x_recon, subbands)
% Evaluate reconstruction accuracy and subband independence
% Inputs:
%   x        - Original signal
%   x_recon  - Reconstructed signal
%   subbands - Matrix of grouped subbands (4×N)
% Outputs:
%   SNR_val   - Signal-to-noise ratio (dB)
%   RMSE_val  - Root mean square error
%   Corr_val  - Correlation between x and x_recon
%   maxCorr   - Max inter-subband correlation

SNR_val = snr(x_recon, x - x_recon);
RMSE_val = sqrt(mean((x - x_recon).^2));
Corr_val = corr(x(:), x_recon(:));

C = corrcoef(subbands');
maxCorr = max(max(C - eye(4)));
end
