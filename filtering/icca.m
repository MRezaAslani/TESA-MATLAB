%--------------------------------------------------------------------------
% Function: icca
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)

function out = icca(realCC, imagCC)
% IDCSA - Inverse Direct Sinusoidal Component Analysis
% Reconstructs a signal from its cca coefficients
%
% Syntax:
%   out = icca(realCC, imagCC)
%
% Inputs:
%   realCC - Vector of real components (length = freqNum)
%   imagCC - Vector of imaginary components (length = freqNum)
%
% Output:
%   out    - Reconstructed time-domain signal (1 x N)
%
% Note:
%   The output is the mean across all reconstructed frequency components.
%   It assumes sampling over [0, 1) with N = 2 * freqNum samples.

freqNum = length(realCC);
N = 2 * freqNum;
t = (0:N-1)/N;

subx = zeros(freqNum, N);
for fd = 0 : freqNum-1
    subx(fd+1,:) = realCC(fd+1)*cos(2*pi*t*fd) + imagCC(fd+1)*sin(2*pi*t*fd);
end

out = mean(subx, 1);
end
