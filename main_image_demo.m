%--------------------------------------------------------------------------
% File: main_image_demo.m
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)
% Description:
%   DSCA-based subband decomposition and reconstruction of a grayscale image,
%   compared against classical Discrete Wavelet Transform (DWT) method.
%--------------------------------------------------------------------------

clc; clear; close all;

%% 1. Load and Preprocess the Image
originalImage = imread('cameraman.tif');
originalImage = im2double(imresize(originalImage, 0.25));  % Resize to 64x64
L = size(originalImage, 1);

%% 2. DSCA Decomposition
subbandsDSCA = dsca(originalImage);
numSubbands = size(subbandsDSCA, 3);
jump = numSubbands / 4;
group = zeros(L, L, 4);
for i = 1:4
    group(:,:,i) = mean(subbandsDSCA(:,:,(i-1)*jump+1:i*jump), 3);
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
subbandsDSCA = normalize_subbands(subbandsDSCA, originalImage);
subbandsDWT  = normalize_subbands(subbandsDWT, originalImage);

reconstructedImageDSCA = sum(subbandsDSCA, 3);
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
VLF_energy_dsca = sum(sum(abs(group(:,:,1)).^2));
MF_energy_dsca  = sum(sum(abs(group(:,:,2)).^2));
HF_energy_dsca  = sum(sum(abs(group(:,:,3)).^2));
VHF_energy_dsca = sum(sum(abs(group(:,:,4)).^2));

VLF_energy_dwt = sum(sum(abs(subbandsDWT(:,:,1)).^2));
MF_energy_dwt  = sum(sum(abs(subbandsDWT(:,:,2)).^2));
HF_energy_dwt  = sum(sum(abs(subbandsDWT(:,:,3)).^2));
VHF_energy_dwt = sum(sum(abs(subbandsDWT(:,:,4)).^2));

[psnr_dsca, ssim_dsca, immse_dsca, maxCorr_dsca] = metrics_image(originalImage, reconstructedImageDSCA, group);
[psnr_dwt,  ssim_dwt,  immse_dwt,  maxCorr_dwt ] = metrics_image(originalImage, reconstructedImageDWT, subbandsDWT(:,:,1:4));

%% 7. Print Results
fprintf('\n--- DSCA Subband Energies ---\n');
fprintf('VLF: %.4f | MF: %.4f | HF: %.4f | VHF: %.4f\n', VLF_energy_dsca, MF_energy_dsca, HF_energy_dsca, VHF_energy_dsca);

fprintf('\n--- DWT Subband Energies ---\n');
fprintf('VLF: %.4f | MF: %.4f | HF: %.4f | VHF: %.4f\n', VLF_energy_dwt, MF_energy_dwt, HF_energy_dwt, VHF_energy_dwt);

fprintf('\n--- DSCA Metrics ---\n');
fprintf('PSNR: %.2f | SSIM: %.4f | MSE: %.2e | Max Corr: %.2e\n', psnr_dsca, ssim_dsca, immse_dsca, maxCorr_dsca);

fprintf('\n--- DWT Metrics ---\n');
fprintf('PSNR: %.2f | SSIM: %.4f | MSE: %.2e | Max Corr: %.2e\n', psnr_dwt, ssim_dwt, immse_dwt, maxCorr_dwt);
