%--------------------------------------------------------------------------
% File: main_image_demo.m
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)
% Description:
%   cca-based subband decomposition and reconstruction of a grayscale image,
%   compared against classical Discrete Wavelet Transform (DWT) method.
%--------------------------------------------------------------------------

clc; clear; close all;

%% 1. Load and Preprocess the Image
originalImage = imread('cameraman.tif');
originalImage = im2double(imresize(originalImage, 0.25));  % Resize to 64x64
L = size(originalImage, 1);

%% 2. cca Decomposition
subbandsCCA = cca(originalImage);
numSubbands = size(subbandsCCA, 3);
jump = numSubbands / 4;
group = zeros(L, L, 4);
for i = 1:4
    group(:,:,i) = mean(subbandsCCA(:,:,(i-1)*jump+1:i*jump), 3);
end

%% 3. DWT Decomposition (db4, level 1)
wavelet = 'db4';
level = 1;
numSubbandsDWT = 3 * level + 1;
[C, S] = wavedec2(originalImage, level, wavelet);
subbandsDWT = zeros(L, L, numSubbandsDWT);
subbandIdx = 1;
subbandsDWT(:,:,subbandIdx) = wrcoef2('a', C, S, wavelet, level);
subbandIdx = subbandIdx + 1;
for l = level:-1:1
    for type = {'h', 'v', 'd'}
        subbandsDWT(:,:,subbandIdx) = wrcoef2(type{1}, C, S, wavelet, l);
        subbandIdx = subbandIdx + 1;
    end
end

%% 4. Normalize and Reconstruct
subbandsCCA = normalize_subbands(subbandsCCA, originalImage);
subbandsDWT  = normalize_subbands(subbandsDWT, originalImage);

reconstructedImageCCA = sum(subbandsCCA, 3);
reconstructedImageDWT = sum(subbandsDWT, 3);

%% 5. Display Original and Spectra
figure;
subplot(1,2,2);
F = fft2(rescale(originalImage,0,1));
Fshift = fftshift(F);
magF = log(1 + abs(Fshift));
imshow(magF, [], 'XData', [1 L], 'YData', [1 L]);
colormap('default');
title('Original Spectrum (log-scaled)');
subplot(1,2,1); imshow(originalImage, [], 'XData', [1 L], 'YData', [1 L]);
title('Original Image');

%% 6. Evaluate Energies and Metrics
VLF_power_cca = sum(sum(abs(group(:,:,1)).^2))/numel(group(:,:,1));
MF_power_cca  = sum(sum(abs(group(:,:,2)).^2))/numel(group(:,:,2));
HF_power_cca  = sum(sum(abs(group(:,:,3)).^2))/numel(group(:,:,3));
VHF_power_cca = sum(sum(abs(group(:,:,4)).^2))/numel(group(:,:,4));

VLF_power_dwt = sum(sum(abs(subbandsDWT(:,:,1)).^2))/numel(group(:,:,1));
MF_power_dwt  = sum(sum(abs(subbandsDWT(:,:,2)).^2))/numel(group(:,:,2));
HF_power_dwt  = sum(sum(abs(subbandsDWT(:,:,3)).^2))/numel(group(:,:,3));
VHF_power_dwt = sum(sum(abs(subbandsDWT(:,:,4)).^2))/numel(group(:,:,4));

[psnr_cca, ssim_cca, immse_cca, maxCorr_cca] = metrics_image(originalImage, reconstructedImageCCA, group);
[psnr_dwt,  ssim_dwt,  immse_dwt,  maxCorr_dwt ] = metrics_image(originalImage, reconstructedImageDWT, subbandsDWT(:,:,1:4));

%% 7. Print Results
fprintf('\n--- CCA Subband Powers ---\n');
fprintf('VLF: %.4f | MF: %.4f | HF: %.4f | VHF: %.4f\n', VLF_power_cca, MF_power_cca, HF_power_cca, VHF_power_cca);

fprintf('\n--- DWT Subband Powers ---\n');
fprintf('VLF: %.4f | MF: %.4f | HF: %.4f | VHF: %.4f\n', VLF_power_dwt, MF_power_dwt, HF_power_dwt, VHF_power_dwt);

fprintf('\n--- CCA Metrics ---\n');
fprintf('PCC: %.2e | MSE: %.2e | Max Corr: %.2e\n', corr(originalImage(:), reconstructedImageCCA(:)), immse_cca, maxCorr_cca);

fprintf('\n--- DWT Metrics ---\n');
fprintf('PCC: %.2e | MSE: %.2e | Max Corr: %.2e\n', corr(originalImage(:), reconstructedImageCCA(:)), immse_dwt, maxCorr_dwt);
close all