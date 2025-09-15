%--------------------------------------------------------------------------
% Function: tesa
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)
% Description:
% TESA_BASED_ON_GRADIENT_DRIVEN_ADAM_OPTIMIZATION
% Implements Time-Enhanced Spectrogram Alignment (TESA) using Adam to optimize time-domain signal samples.
% Inputs:
%   x: Initial observation signal (damaged, 1D column vector, real-valued)
%   S_target: Target magnitude spectrogram (same size as abs(stft(x)))
%   stft_params: Struct with STFT parameters (fs, window, noverlap, nfft)
%   tesa_params: Struct with TESA parameters (lambda, alpha, num_iter, beta1, beta2)
% Output:
%   x_opt: Optimized signal

function x_opt = tesa(x, S_target, stft_params, tesa_params)

if nargin < 3
    stft_params = struct();
end

if nargin < 4
    tesa_params = struct();
end

% Default hyperparameters
fs = getfield_default(stft_params, 'fs', length(x)); % For division by |g| (Eq. 5)
window = getfield_default(stft_params, 'window', hamming(256)); % For division by |g| (Eq. 5)
noverlap = getfield_default(stft_params, 'noverlap', round(0.88 * length(window))); % For division by |g| (Eq. 5)
nfft = getfield_default(stft_params, 'nfft', length(window)); % Epsilon for Adam (Eq. 7)

lambda = getfield_default(tesa_params, 'lambda', 0.001); % Regularization strength (Eq. 3)
alpha = getfield_default(tesa_params, 'alpha', 0.1);     % Learning rate (Eq. 7)
num_iter = getfield_default(tesa_params, 'num_iter', 2000); % Number of iterations
beta1 = getfield_default(tesa_params, 'beta1', 0.9);     % Adam beta1 (Eq. 8)
beta2 = getfield_default(tesa_params, 'beta2', 0.999);   % Adam beta2 (Eq. 8)

% Epsilon values
eps_adam = 1e-8;
eps_div = 1e-8;

% Initialize STFT to get spectrogram dimensions
G = stft(x, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
[K, M] = size(G); % Spectrogram dimensions (Eq. 3)
MK = M * K; % For normalization (Eq. 3, 6)
L = length(x); % Signal length

% Initialize signal and Adam moments
x_current = x(:); % Ensure column vector
m = zeros(L, 1); % First moment
v = zeros(L, 1); % Second moment

for t = 1:num_iter
    % Compute STFT (Eq. 1)
    G = stft(x_current, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    
    % Compute magnitude spectrogram (Eq. 2)
    mag = abs(G);
    
    % Compute normalized complex STFT for error term (Eq. 5)
    phase = G ./ (mag + eps_div);
    
    % Compute error term (Eq. 5)
    error_term = (mag - S_target) .* phase;
    
    % Backpropagate to time domain using ISTFT (Eq. 6)
    grad_loss = real(istft(error_term, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    
    % Add regularization gradient (Eq. 6)
    grad_reg = lambda * x_current;
    
    % Total gradient (Eq. 6)
    grad = (1 / MK) * grad_loss + grad_reg;
    
    % Update first moment (Eq. 8)
    m = beta1 * m + (1 - beta1) * grad;
    
    % Update second moment (Eq. 8)
    v = beta2 * v + (1 - beta2) * (grad .^ 2);
    
    % Bias-corrected moments (Eq. 8)
    m_hat = m / (1 - beta1 ^ t);
    v_hat = v / (1 - beta2 ^ t);
    
    % Update time-domain signal (Eq. 7)
    x_current = x_current - alpha * (m_hat ./ (sqrt(v_hat) + eps_adam));
end

% Output optimized signal
x_opt = x_current;

end

function val = getfield_default(s, field, default)
    if isfield(s, field)
        val = s.(field);
    else
        val = default;
    end
end
