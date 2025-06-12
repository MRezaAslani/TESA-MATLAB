function signal = generateNonStationarySignal(N, fs, num_components, freqs, min_segment_length, max_segment_length, plot_flag)
% GENERATENONSTATIONARYSIGNAL Generates a non-stationary signal with random time-frequency components.
% Inputs:
%   N                 - Total number of samples
%   fs                - Sampling frequency (Hz)
%   num_components    - Number of time-frequency components
%   freqs             - Vector of possible frequencies (Hz)
%   min_segment_length - Minimum segment length (samples)
%   max_segment_length - Maximum segment length (samples)
%   plot_flag         - Boolean to enable/disable plotting (true/false)
% Output:
%   signal            - Normalized non-stationary signal (row vector)

% Default plot_flag if not provided
if nargin < 7
    plot_flag = true;
end

% Time vector
t = (0:N-1)/fs;

% Generate random time window lengths (in samples)
segment_lengths = randi([min_segment_length, max_segment_length], 1, num_components);

% Adjust segment lengths to sum to N
segment_lengths = round(segment_lengths * N / sum(segment_lengths));
while sum(segment_lengths) ~= N
    diff = N - sum(segment_lengths);
    idx = randi(num_components); % Randomly adjust one segment
    if diff > 0 && segment_lengths(idx) < max_segment_length
        segment_lengths(idx) = segment_lengths(idx) + 1;
    elseif diff < 0 && segment_lengths(idx) > min_segment_length
        segment_lengths(idx) = segment_lengths(idx) - 1;
    end
end

% Randomly assign frequencies to each segment (with replacement)
random_freqs = freqs(randi(length(freqs), 1, num_components));

% Initialize the signal
signal = zeros(1, N);

% Generate the signal
current_idx = 1;
for seg = 1:num_components
    start_idx = current_idx;
    end_idx = start_idx + segment_lengths(seg) - 1;
    if end_idx > N
        end_idx = N; % Ensure we don't exceed signal length
    end
    t_segment = t(start_idx:end_idx);
    signal(start_idx:end_idx) = sin(2*pi*random_freqs(seg)*t_segment);
    current_idx = end_idx + 1;
    if current_idx > N
        break; % Stop if we've filled the signal
    end
end

% Normalize the signal: remove mean and scale to unit standard deviation
signal = signal - mean(signal);
signal = signal / std(signal);
signal = signal(:).'; % Ensure row vector

% Plotting (if enabled)
if plot_flag
    % Time-domain plot
    figure;
    plot(t, signal);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Non-Stationary Signal with Random Time-Frequency Components');
    grid on;

    % Spectrogram
    figure;
    spectrogram(signal, 128, 120, 128, fs, 'yaxis');
    title('Spectrogram of Non-Stationary Signal');
    colormap('jet');
end

end
