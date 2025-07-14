function x = generate_chirp(fs, N)
% Generate composite chirp signal
% Inputs:
%   fs - Sampling frequency
%   N  - Signal length
% Output:
%   x  - Combined chirp signal (normalized)

t = (0:N-1)/fs;
x1 = sin(2*pi*(20*t + 180*t.^2));
x2 = sin(2*pi*(280*t - 100*t.^2));
x = rescale(x1 + x2, -1, 1);
end
