
% spectrogram_collection_time_to_freq.m
% Generates a 3D array of spectrograms from high time resolution to high frequency resolution
% Each spectrogram is resized to [length(signal)/2, length(signal)]
% Input: signal (input signal), fs (sampling frequency), freqs_to_filter (frequency indices)
% Output: spectrogram_mag (3D array: [length(signal)/2 x length(signal) x spectrogram_index])

function spectrogram_mag = spectrogram_collection(signal, fs)
    % Define parameters for time-to-frequency resolution progression
    window_sizes = [128, 256, 512, 1024]; % Short to long windows (time to freq resolution)
    overlaps = [115, 230, 460, 922]; % ~90% overlap for high time resolution
    num_spectrograms = length(window_sizes);
    
    % Ensure signal length is even for exact division
    sig_len = length(signal);
    if mod(sig_len, 2) ~= 0
        signal = signal(1:end-1); % Trim one sample if odd
        sig_len = length(signal);
    end
    
    % Set FFT length to ensure enough frequency bins
    nfft = max(2 * (sig_len/2), 1024); % At least sig_len to get sig_len/2 positive bins
    fft_lengths = repmat(nfft, 1, num_spectrograms); % Same nfft for all spectrograms
    
    % Define output spectrogram dimensions
    freq_bins = round(0.8333*sig_len/2); % Number of frequency bins
    time_bins = sig_len; % Number of time bins
    
    % Initialize 3D array for spectrogram magnitudes
    spectrogram_mag = zeros(freq_bins, time_bins, num_spectrograms);
    
    % Generate spectrograms for each resolution
    for idx = 1:num_spectrograms
        % Define parameters for current spectrogram
        window = hamming(window_sizes(idx));
        noverlap = overlaps(idx);
        nfft = fft_lengths(idx);
        
        % Compute STFT
        [S, ~, ~] = stft(signal, fs, 'Window', window, ...
                         'OverlapLength', noverlap, 'FFTLength', nfft);
        
        % Compute spectrogram magnitude for positive frequencies
        spectrogram = imresize(flipud(abs(S(1:floor(nfft/2), :))), ...
                              [freq_bins, time_bins]); % Resize to [sig_len/2, sig_len]
        
        % Normalize spectrogram
        spectrogram = spectrogram - min(spectrogram(:)); % Subtract minimum
        spectrogram = spectrogram / max(spectrogram(:)); % Divide by maximum
        
        % Store in 3D array
        spectrogram_mag(:, :, idx) = spectrogram;
    end

stack1 = [squeeze(spectrogram_mag(:, :, 1)), squeeze(spectrogram_mag(:, :, 2))];
stack2 = [squeeze(spectrogram_mag(:, :, 3)), squeeze(spectrogram_mag(:, :, 4))];
spectrogram_mag = [stack1, stack2];
end
