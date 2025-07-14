%--------------------------------------------------------------------------
% Function: ccaFilter
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)

function [filtered_signal, target_spectrogram] = ccaFilter(signal, signal_preprocessed, fs, freqs_to_filter, filter_mode)
    % ccaFILTER Filters a time-domain signal using STFT and CCA.
    %   filtered_signal = ccaFilter(signal, fs, freqs_to_filter, mode) filters a
    %   time-domain signal by keeping ('bandpass') or removing ('bandstop') specified frequency
    %   bands using Short-Time Fourier Transform (STFT) and Direct Sinusoidal Component
    %   Analysis (CCA). Users can interactively adjust bandwidth (bw) and DC offset (dc)
    %   vectors to refine the target spectrogram, which is compared to the filtered signal's
    %   spectrogram until a correlation threshold is met.
    %
    % Inputs:
    %   signal         - 1D numeric vector, time-domain input signal
    %   fs             - Positive scalar, sampling frequency in Hz
    %   freqs_to_filter - Numeric vector, frequencies to filter in Hz (non-negative)
    %   mode           - String, 'bandpass' or 'bandstop'
    %
    % Outputs:
    %   filtered_signal - 1D numeric vector, filtered time-domain signal
    %
    % Notes:
    %   - Requires external functions: setSTFT, CCA, iCCA (not defined here).
    %   - Displays input and target spectrograms during interaction, and input, target,
    %     and filtered spectrograms at the end.
    %   - Prompts user to continue ('yes'), modify bw/dc ('no'), or exit ('end').
    %   - bw must be even integers; dc can be any numbers (e.g., frequency offsets).
    %   - Uses imresize to adjust spectrogram size, which may affect frequency resolution.


    % Validate inputs to ensure correct types and values
    if ~isvector(signal) || ~isnumeric(signal)
        error('Signal must be a numeric vector.');
    end
    if ~isscalar(fs) || fs <= 0
        error('Sampling frequency fs must be a positive scalar.');
    end
    if ~isvector(freqs_to_filter) || ~isnumeric(freqs_to_filter) || any(freqs_to_filter < 0)
        error('freqs_to_filter must be a vector of non-negative frequencies.');
    end
    if ~ischar(filter_mode) || ~ismember(lower(filter_mode), {'bandpass', 'bandstop'})
        error('Mode must be ''bandpass'' or ''bandstop''.');
    end
    filter_mode = lower(filter_mode);
    
    %% CCA FILTER
    % Initialize parameters for STFT and CCA
    signal = rescale(signal-mean(signal),-1,1);
    signal_preprocessed = rescale(signal_preprocessed-mean(signal_preprocessed),-1,1);

    filtered_signal = signal_preprocessed; % Initialize output signal (overwritten later)
    num_coeffs = length(signal)/2; % Number of cca coefficients to process
    
    time_bins = length(signal);
    freq_bins = time_bins/2;
    window = hamming(64); % 256-point Hamming window for STFT
    noverlap = 60; % 250-sample overlap for STFT
    nfft = 64; % 256-point FFT length for STFT

    [S, ~, ~] = stft(signal, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    spectrogram_mag_show = imresize(flipud(abs(S(1:floor(nfft/2), :))), [freq_bins, time_bins]);

    % Create figure for interactive visualization
    fig = figure('Name', 'Spectrogram Visualization', 'Position', [100, 100, 800, 400]);
    
    % Display input spectrogram
    subplot(2, 1, 1);
    imagesc(spectrogram_mag_show);
    colormap('jet');
    title('Input Spectrogram', 'FontSize', 12, 'Color', 'black');
    xlabel('Time'); ylabel('Frequency Bin');
    
    % Create initial target spectrogram with zero bandwidth and DC offset
    target_spectrogram = setSTFT(spectrogram_mag_show, filter_mode, freqs_to_filter, ...
        zeros(1,length(freqs_to_filter)), zeros(1,length(freqs_to_filter)));
    
    % Display target spectrogram
    subplot(2, 1, 2);
    imagesc(target_spectrogram);
    colormap('jet');
    title('Target Spectrogram', 'FontSize', 12, 'Color', 'black');
    xlabel('Time'); ylabel('Frequency Bin');
    
    % Add main figure title
    sgtitle('Spectrogram Displays', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Prompt user to continue, modify, or exit
    response = lower(input('Do you want to continue? (yes/no/end): ', 's'));
    
    % Handle user response
    if strcmp(response, 'yes')
        fprintf('Please wait...\n');
    elseif strcmp(response, 'no')
        fprintf('Please modify BW & DC arrays:\n');
        % Loop to allow multiple modifications to bw and dc
        while true
            % Prompt for BW vector (must be even numbers)
            while true
                try
                    bw = input('Enter BW vector of even numbers (e.g., [2 4 6]): ');
                    if isnumeric(bw) && isvector(bw) && all(mod(bw, 2) == 0)
                        break; % Valid numeric vector with even numbers
                    else
                        fprintf('Please enter a valid numeric vector with all even numbers (e.g., [2 4 6]).\n');
                    end
                catch
                    fprintf('Invalid input. Please enter a vector like [2 4 6].\n');
                end
            end
    
            % Prompt for DC vector (any numbers, e.g., frequency offsets)
            while true
                try
                    dc = input('Enter DC vector (e.g., [-1 0 1]): ');
                    if isnumeric(dc) && isvector(dc)
                        break; % Valid numeric vector
                    else
                        fprintf('Please enter a valid numeric vector (e.g., [-1 0 1]).\n');
                    end
                catch
                    fprintf('Invalid input. Please enter a vector like [-1 0 1].\n');
                end
            end
    
            % Update display with new target spectrogram
            clf(fig);
            subplot(2, 1, 1);
            imagesc(spectrogram_mag_show);
            colormap('jet');
            title('Input Spectrogram', 'FontSize', 12, 'Color', 'black');
            xlabel('Time'); ylabel('Frequency Bin');
    
            target_spectrogram = setSTFT(spectrogram_mag_show, filter_mode, freqs_to_filter, bw, dc);
    
            subplot(2, 1, 2);
            imagesc(target_spectrogram);
            colormap('jet');
            title('Target Spectrogram', 'FontSize', 12, 'Color', 'black');
            xlabel('Time'); ylabel('Frequency Bin');
    
            sgtitle('Spectrogram Displays', 'FontSize', 14, 'FontWeight', 'bold');
    
            % Prompt again
            response = lower(input('Do you want to continue? (yes/no/end): ', 's'));
    
            if strcmp(response, 'yes')
                fprintf('Please wait...\n');
                break; % Proceed to cca filtering
            elseif strcmp(response, 'no')
                fprintf('Please modify BW & DC arrays.\n');
                continue; % Prompt for new bw and dc
            elseif strcmp(response, 'end')
                fprintf('Bye Bye!\n');
                close(fig);
                filtered_signal = signal; % Return original signal
                return; % Exit function
            else
                fprintf('Invalid input. Please enter ''yes'', ''no'', or ''end''.\n');
            end
        end
    elseif strcmp(response, 'end')
        fprintf('Bye Bye!\n');
        close(fig);
        filtered_signal = signal; % Return original signal
        return; % Exit function
    else
        fprintf('Invalid input. Please enter ''yes'', ''no'', or ''end''.\n');
    end
    
    % Transform signal to cca coefficient domain
    [~, real_coeffs, imag_coeffs] = cca(signal_preprocessed); % Assume cca returns real and imaginary coefficients


    % Define bounds for coefficient adjustments
    real_coeffs_min = (real_coeffs<0).*(real_coeffs-1); % Minimum for real part
    real_coeffs_max = (real_coeffs>0).*(real_coeffs+1); % Maximum for real part
    imag_coeffs_min = (imag_coeffs<0).*(imag_coeffs-1); % Minimum for imaginary part
    imag_coeffs_max = (imag_coeffs>0).*(imag_coeffs+1); % Maximum for imaginary part
    
    % Initialize spectrograms for CCA optimization
    [S, ~, ~] = stft(signal_preprocessed, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    current_spectrogram = imresize(flipud(abs(S(1:floor(nfft/2), :))), [freq_bins, time_bins]);

    mse_matrix = zeros(3,3); % Correlation matrix for coefficient adjustments

    target_spectrogram = target_spectrogram.*(target_spectrogram>0.25*max(target_spectrogram(:)));
    mse_avg_new = mse(target_spectrogram, current_spectrogram);
    mse_avg_old = 0;

    % Iterate until spectrogram correlation exceeds 0.9999
    while round(10000*abs(mse_avg_new-mse_avg_old)) > 0
        fprintf('Progress: %2.2f%% is remain\n', round(10000*abs(mse_avg_new-mse_avg_old))/100);
        for f = 1 : num_coeffs
            % Test adjustments for each coefficient
            for r = 1 : 3
                for i = 1 : 3
                    real_coeffs_temp = real_coeffs;
                    imag_coeffs_temp = imag_coeffs;
                    % Adjust real coefficient: 1=keep, 2=midpoint to max, 3=midpoint to min
                    real_coeffs_temp(f) = (r==1)*real_coeffs(f) + (r==2)*(real_coeffs_max(f)+real_coeffs(f))/2 + ...
                                          (r==3)*(real_coeffs(f)+real_coeffs_min(f))/2;
                    % Adjust imaginary coefficient
                    imag_coeffs_temp(f) = (i==1)*imag_coeffs(f) + (i==2)*(imag_coeffs_max(f)+imag_coeffs(f))/2 + ...
                                          (i==3)*(imag_coeffs(f)+imag_coeffs_min(f))/2;
    
                    % Reconstruct signal and compute spectrogram
                    filtered_signal = icca(real_coeffs_temp, imag_coeffs_temp);
                    [S, ~, ~] = stft(filtered_signal, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
                    spectrogram_mag = imresize(flipud(abs(S(1:floor(nfft/2), :))), [freq_bins, time_bins]);
                    mse_matrix(r,i) =  mse(target_spectrogram, spectrogram_mag);
                end
            end
            
            matrix = mse_matrix;
            % Select best adjustment
            [r, i] = find(matrix==min(min(matrix)));
            r = r(1); % Take first maximum
            i = i(1);
            
            % Compute differences for bound updates
            diffR_Min = abs(real_coeffs(f)-real_coeffs_min(f));
            diffR_Max = abs(real_coeffs(f)-real_coeffs_max(f));
            diffI_Min = abs(imag_coeffs(f)-imag_coeffs_min(f));
            diffI_Max = abs(imag_coeffs(f)-imag_coeffs_max(f));
    
            % Update coefficients
            real_coeffs(f) = (r==1)*real_coeffs(f) + (r==2)*(real_coeffs_max(f)+real_coeffs(f))/2 + ...
                             (r==3)*(real_coeffs(f)+real_coeffs_min(f))/2;
            imag_coeffs(f) = (i==1)*imag_coeffs(f) + (i==2)*(imag_coeffs_max(f)+imag_coeffs(f))/2 + ...
                             (i==3)*(imag_coeffs(f)+imag_coeffs_min(f))/2;
    
            % Update bounds to narrow search space
            real_coeffs_min(f) = (r==1|r==2)*(real_coeffs(f)+real_coeffs_min(f))/2 + ...
                                 (r==3)*(real_coeffs_min(f)-diffR_Min);
            real_coeffs_max(f) = (r==1|r==3)*(real_coeffs(f)+real_coeffs_max(f))/2 + ...
                                 (r==2)*(real_coeffs_max(f)+diffR_Max);
    
            imag_coeffs_min(f) = (i==1|i==2)*(real_coeffs(f)+imag_coeffs_min(f))/2 + ...
                                 (i==3)*(imag_coeffs_min(f)-diffI_Min);
            imag_coeffs_max(f) = (i==1|i==3)*(real_coeffs(f)+imag_coeffs_max(f))/2 + ...
                                 (i==2)*(imag_coeffs_max(f)+diffI_Max);        
        
        end
        
        % Update filtered signal and spectrogram
        filtered_signal = icca(real_coeffs, imag_coeffs);

        [S, ~, ~] = stft(filtered_signal, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
        current_spectrogram = imresize(flipud(abs(S(1:floor(nfft/2), :))), [freq_bins, time_bins]);
        mse_avg_old = mse_avg_new;
        mse_avg_new = mse(target_spectrogram, current_spectrogram);
    end
    
    target_spectrogram = imresize(flipud(target_spectrogram), [size(S,1), size(S,2)]);
    target_spectrogram = [target_spectrogram; flipud(target_spectrogram)];
    target_spectrogram(size(S,1),:) = [];
end

