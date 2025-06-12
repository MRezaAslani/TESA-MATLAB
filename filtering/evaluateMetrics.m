function evaluateMetrics(filtered, target)
    SNR_val  = snr(filtered, target - filtered);
    RMSE_val = sqrt(mean((filtered - target).^2));
    Corr_val = corr(target(:), filtered(:));

    fprintf('\n--- Quantitative Evaluation ---\n');
    fprintf('SNR: %.4f dB\n', SNR_val);
    fprintf('RMSE: %.4f\n', RMSE_val);
    fprintf('Correlation: %.4f\n', Corr_val);
end