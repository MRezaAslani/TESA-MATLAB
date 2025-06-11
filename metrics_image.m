%--------------------------------------------------------------------------
% Function: metrics_image
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% 
% Description:
%   Computes image quality metrics between original and reconstructed images,
%   and calculates maximum correlation between subbands.
%
% Inputs:
%   original    - original grayscale image
%   reconstructed - reconstructed image from subbands
%   subbands    - 3D array of subband images (e.g., 4 subbands)
%
% Outputs:
%   psnr_val    - Peak Signal-to-Noise Ratio
%   ssim_val    - Structural Similarity Index
%   mse_val     - Mean Squared Error
%   maxCorr     - Maximum correlation between subbands
%--------------------------------------------------------------------------

function [psnr_val, ssim_val, mse_val, maxCorr] = metrics_image(original, reconstructed, subbands)

% Rescale reconstructed image to match original dynamic range
reconstructed = rescale(reconstructed, min(original(:)), max(original(:)));

% Compute PSNR, SSIM, MSE
psnr_val = psnr(reconstructed, original);
ssim_val = ssim(reconstructed, original);
mse_val  = immse(reconstructed, original);

% Compute max correlation between subbands
numBands = size(subbands, 3);
Y = zeros(numBands, numel(subbands(:,:,1)));
for i = 1:numBands
    Y(i,:) = reshape(squeeze(subbands(:,:,i)), 1, size(subbands,1)*size(subbands,2));
end
C = corrcoef(Y');
maxCorr = max(max(C - eye(numBands)));

end
