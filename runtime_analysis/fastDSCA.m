%--------------------------------------------------------------------------
% Function: idsca
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)

function [subx, realCC, imagCC] = fastDSCA(x)
% FASTDSCA - Fast implementation of Direct Sinusoidal Component Analysis (DSCA)
%   [subx, realCC, imagCC] = fastDSCA(x) decomposes the input signal or image
%   into sinusoidal components using inverse FFT.
%
%   Inputs:
%       x       - Input signal (1D row/column vector) or 2D image
%
%   Outputs:
%       subx    - Reconstructed components (frequency x time) for 1D, or 3D (rows x cols x freq) for 2D
%       realCC  - Real part of correlation coefficients
%       imagCC  - Imaginary part of correlation coefficients

    size1 = size(x, 1);
    size2 = size(x, 2);

    %% Case 1: Input is a 1D signal (vector)
    if (size1 == 1) || (size2 == 1)
        x = x(:)';                         % Ensure row vector
        L = length(x);
        t = 0 : 1/L : 1 - 1/L;            % Time vector
        freqNum = fix(L / 2);            % Number of frequency bins

        correlation = ifft(x);           % Inverse FFT to get correlation
        correlation = correlation(1:freqNum);

        realCC = real(correlation);
        imagCC = imag(correlation);

        magnit = abs(correlation);       % Magnitude
        phi = atan2(real(correlation), imag(correlation)); % Phase

        subx = zeros(freqNum, L);
        for fd = 0 : freqNum - 1
            subx(fd+1, :) = magnit(fd+1) * sin(2 * pi * t * fd + phi(fd+1));
        end

    %% Case 2: Input is a 2D image
    else
        x1 = x(:)';                      % Flatten image to vector
        L = length(x1);
        t = 0 : 1/L : 1 - 1/L;
        freqNum = fix(L / 2);

        correlation1 = ifft(x1);
        correlation1 = correlation1(1:freqNum);

        realCC = real(correlation1);
        imagCC = imag(correlation1);

        magnit1 = abs(correlation1);
        phi1 = atan2(real(correlation1), imag(correlation1));

        subx = zeros(size1, size2, freqNum);
        for fd = 0 : freqNum - 1
            comp = magnit1(fd+1) * sin(2 * pi * t * fd + phi1(fd+1));
            subx(:, :, fd+1) = reshape(comp, size1, size2);
        end
    end
end
