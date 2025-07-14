%--------------------------------------------------------------------------
% Function: cca
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)
% Description:
%   Direct Sinusoidal Component Analysis (CCA) for decomposing input signal
%   or image into narrowband sinusoidal subcomponents in the frequency domain.
%
% Inputs:
%   x : input 1D signal (vector) or 2D image (matrix)
%
% Outputs:
%   subx   : reconstructed subband components (2D or 3D)
%   realCC : real part of correlation coefficients (frequency spectrum)
%   imagCC : imaginary part of correlation coefficients
%
% Citation: Please cite our article submitted to IEEE Transactions on Signal Processing.
%--------------------------------------------------------------------------

function [subx, realCC, imagCC] = cca(x)

size1 = size(x,1);
size2 = size(x,2);

% === Case 1: Input is a vector (1D signal) ===
if (size1 == 1) || (size2 == 1)
    x = x(:)';                          % Ensure row vector
    L = length(x);
    t = 0 : 1/L : 1 - 1/L;              % Normalized time base
    numFreq = floor(L / 2);            % Number of frequency bins

    realCC = zeros(numFreq, 1);
    imagCC = zeros(numFreq, 1);
    subx = zeros(numFreq, L);

    for k = 0 : numFreq - 1
        expon = exp(1j * 2 * pi * t * k);         % Complex exponential
        corr = sum(x .* expon);                   % Correlation
        realCC(k + 1) = real(corr);
        imagCC(k + 1) = imag(corr);

        % Reconstruction of subband component
        realComp = realCC(k + 1) * real(expon);
        imagComp = imagCC(k + 1) * imag(expon);
        subx(k + 1, :) = realComp + imagComp;
    end

% === Case 2: Input is a 2D image ===
else
    x1 = x(:)';
    L = length(x1);
    t = 0 : 1/L : 1 - 1/L;
    numFreq = floor(L / 2);

    realCC = zeros(numFreq, 1);
    imagCC = zeros(numFreq, 1);
    subx = zeros(size1, size2, numFreq);

    for k = 0 : numFreq - 1
        expon = exp(1j * 2 * pi * t * k);
        corr = sum(x1 .* expon);
        realCC(k + 1) = real(corr);
        imagCC(k + 1) = imag(corr);

        realComp = realCC(k + 1) * real(expon);
        imagComp = imagCC(k + 1) * imag(expon);
        subx(:,:,k + 1) = reshape(realComp + imagComp, size1, size2);
    end
end

end
