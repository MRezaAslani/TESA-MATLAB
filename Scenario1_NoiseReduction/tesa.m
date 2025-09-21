%--------------------------------------------------------------------------
% Function: tesa
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)
% Description:
% TESA_BASED_ON_GRADIENT_DRIVEN_ADAM_OPTIMIZATION
% Implements Time-Enhanced Spectrogram Alignment (TESA) using Adam to optimize time-domain signal samples.
% Computes and stores the loss function value at each iteration.
% Inputs:
%   x: Initial observation signal (damaged, 1D column vector, real-valued)
%   S_target: Target magnitude spectrogram (same size as abs(stft(x)))
%   stft_params: Struct with STFT parameters (fs, window, noverlap, nfft)
%   tesa_params: Struct with TESA parameters (lambda, alpha, num_iter, beta1, beta2)
% Outputs:
%   x_opt: Optimized signal
%   loss_history: Vector of loss values for each iteration (Eq. 7)
% Equations refer to Section 3.2 of the manuscript unless otherwise specified.

function [x_opt, loss_history] = tesa(x, S_target, stft_params, tesa_params)

if nargin < 3
    stft_params = struct();
end

if nargin < 4
    tesa_params = struct();
end

% Default hyperparameters
fs = getfield_default(stft_params, 'fs', length(x)); % Sampling frequency for STFT (Eq. 6)
window = getfield_default(stft_params, 'window', hamming(256)); % Window function for STFT (Eq. 6)
noverlap = getfield_default(stft_params, 'noverlap', round(0.88 * length(window))); % Overlap length for STFT (Eq. 6)
nfft = getfield_default(stft_params, 'nfft', length(window)); % FFT length for STFT (Eq. 6)

lambda = getfield_default(tesa_params, 'lambda', 0.001); % Regularization strength (Eq. 7, 12)
alpha = getfield_default(tesa_params, 'alpha', 0.1);     % Learning rate for Adam (Eq. 5)
num_iter = getfield_default(tesa_params, 'num_iter', 2000); % Number of iterations
beta1 = getfield_default(tesa_params, 'beta1', 0.9);     % Adam beta1 (Eq. 1)
beta2 = getfield_default(tesa_params, 'beta2', 0.999);   % Adam beta2 (Eq. 2)

% Epsilon values
eps_adam = 1e-8; % For Adam update stability (Eq. 5)
eps_div = 1e-8; % For division by magnitude in error term

% Initialize STFT to get spectrogram dimensions
G = stft(x, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
[K, M] = size(G); % Spectrogram dimensions (Eq. 7)
MK = M * K; % Normalization factor for loss (Eq. 7, 15)
L = length(x); % Signal length

% Initialize signal, Adam moments, and loss history
x_current = x(:); % Ensure column vector
m = zeros(L, 1); % First moment for Adam (Eq. 1)
v = zeros(L, 1); % Second moment for Adam (Eq. 2)
loss_history = zeros(num_iter, 1); % Store loss values for each iteration (Eq. 7)

for t = 1:num_iter
    % Compute STFT (Eq. 6)
    G = stft(x_current, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    
    % Compute magnitude spectrogram (Eq. 6)
    mag = abs(G);
    
    % Compute loss function (Eq. 7)
    spec_error = mag - S_target;
    loss_spec = (1 / MK) * sum(spec_error(:).^2); % Spectrogram alignment term
    loss_reg = lambda * sum(x_current.^2); % Regularization term
    loss_history(t) = loss_spec + loss_reg; % Total loss (Eq. 7)
    
    % Compute normalized complex STFT for error term (Eq. 15)
    phase = G ./ (mag + eps_div);
    
    % Compute error term (Eq. 15)
    error_term = spec_error .* phase;
    
    % Backpropagate to time domain using ISTFT (Eq. 15)
    grad_loss = real(istft(error_term, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft));
    
    % Add regularization gradient (Eq. 13)
    grad_reg = lambda * x_current;
    
    % Total gradient (Eq. 15)
    grad = (1 / MK) * grad_loss + grad_reg;
    
    % Update first moment (Eq. 1)
    m = beta1 * m + (1 - beta1) * grad;
    
    % Update second moment (Eq. 2)
    v = beta2 * v + (1 - beta2) * (grad .^ 2);
    
    % Bias-corrected moments (Eqs. 3, 4)
    m_hat = m / (1 - beta1 ^ t);
    v_hat = v / (1 - beta2 ^ t);
    
    % Update time-domain signal (Eq. 5)
    x_current = x_current - alpha * (m_hat ./ (sqrt(v_hat) + eps_adam));
end

% Output optimized signal and loss history
x_opt = x_current;

end

function val = getfield_default(s, field, default)
    if isfield(s, field)
        val = s.(field);
    else
        val = default;
    end
end