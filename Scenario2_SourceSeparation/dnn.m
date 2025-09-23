function x_dnn = dnn(x, target_spectrogram, fs, window, noverlap, nfft)
%% Method Name: DNN-based Phase Reconstruction
% Inputs: x (real input for training/init), target_spectrogram (magnitude), fs, window, noverlap, nfft.
% Outputs: x_dnn (real reconstructed signal).
% Note: Revised to avoid memory errors by downsampling frequency bins, using trainscg for lower memory usage,
% and simplifying DNN architecture. Predicts cos and sin of phase for circular regression with MSE loss.
% Includes GLA refinement for better phase consistency. Dummy training on input; for real use, pre-train on large dataset.
% Fixed dimension mismatch by upsampling both magnitude and phase to original size for reconstruction.
% Adjusted stftmag2sig call for R2021 compatibility: nfft as positional argument, removed 'FFTLength', changed 'NumIterations' to 'MaxIterations'.
% Assumed 'Window' is supported; if not, remove it.
% Citation: Y. Masuyama, K. Yatabe, and Y. Oikawa, "Phase reconstruction from amplitude spectrograms based on von-Mises-distribution deep neural network," arXiv:1807.03474, 2018.
% Additional: Cos/sin trick from angle regression literature.

% Compute input spectrogram
[S_input, ~, ~] = stft(x, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);

% Save original magnitude for target
original_mag_target = abs(target_spectrogram);
original_num_freq = size(S_input, 1);

% Downsample frequency bins to reduce memory (e.g., take every 4th bin), but adjust factor if needed
downsample_factor = 4;
freq_indices = 1:downsample_factor:original_num_freq;
downsampled_num_freq = length(freq_indices);

% Check if downsampled is sufficient; if not, reduce factor
win_len = length(window);
if downsampled_num_freq < win_len
    downsample_factor = max(1, floor(original_num_freq / win_len));
    freq_indices = 1:downsample_factor:original_num_freq;
end

S_input = S_input(freq_indices, :);
magnitude_target_down = abs(target_spectrogram(freq_indices, :));

% Prepare features: Log amplitude of current frame
magnitude_input = abs(S_input);
log_mag = log(magnitude_input + eps);  % Log amplitude
[num_freq, num_frames] = size(log_mag);

% Input features: Single frame log-magnitude
input_features = log_mag;  % num_freq x num_frames

% Normalize features
mean_feat = mean(input_features, 'all');
std_feat = std(input_features, 0, 'all');
input_features = (input_features - mean_feat) / std_feat;

% Target: cos and sin of phase for circular loss approximation
phase_target = angle(S_input);
target = [cos(phase_target); sin(phase_target)];  % (2*num_freq) x num_frames

% DNN architecture: 1 hidden layer, 128 units to minimize memory
net = feedforwardnet(128);
net.layers{1}.transferFcn = 'poslin';  % ReLU
net.layers{end}.transferFcn = 'purelin';  % Linear for outputs

% Use Scaled Conjugate Gradient to reduce memory usage
net.trainFcn = 'trainscg';
net.trainParam.epochs = 50;
net.trainParam.showWindow = false;  % Suppress GUI
net.trainParam.max_fail = 10;  % Early stopping
net.trainParam.min_grad = 1e-6;

% Train (dummy on input)
net = train(net, input_features, target);

% Predict phase for target (downsampled)
log_mag_target = log(magnitude_target_down + eps);
input_target = (log_mag_target - mean_feat) / std_feat;  % Normalize with same stats

outputs = net(input_target);

% Reconstruct phase (downsampled)
cos_pred = outputs(1:num_freq, :);
sin_pred = outputs(num_freq+1:end, :);
phase_pred = atan2(sin_pred, cos_pred);

% Upsample phase and magnitude to original size
phase_full = zeros(original_num_freq, num_frames);
mag_full = zeros(original_num_freq, num_frames);
for t = 1:num_frames
    phase_full(:, t) = interp1(freq_indices, phase_pred(:, t), 1:original_num_freq, 'linear', 'extrap');
    mag_full(:, t) = interp1(freq_indices, magnitude_target_down(:, t), 1:original_num_freq, 'linear', 'extrap');
end

% Reconstruct spectrogram with upsampled components
S_recon = mag_full .* exp(1i * phase_full);

% Optional: Refine with Griffin-Lim (50 iterations) using original magnitude for consistency
x_init = istft(S_recon, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
S_init = stft(x_init, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
x_dnn = stftmag2sig(original_mag_target, nfft, fs, 'Window', window, 'OverlapLength', noverlap, ...
                    'MaxIterations', 50, 'InitialPhase', angle(S_init));

x_dnn = real(x_dnn);  % Ensure real
end