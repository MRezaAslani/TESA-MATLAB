%--------------------------------------------------------------------------
% Function: dscaExtraction
% Author: Mohammad Reza Aslani
% Contact: mr.aslani@shdu.ac.ir
% License: CC BY-NC 4.0 (https://creativecommons.org/licenses/by-nc/4.0/)

function extracted_signal = dscaExtraction(signal, fs, target_spectrogram)
    % FREQUENCYFILTER Filters a signal by removing or keeping specified frequencies.
    %   filtered_signal = frequencyFilter(signal, fs, freqs_to_filter, mode) takes a
    %   time-domain signal, sampling frequency (Hz), a vector of frequencies to filter (Hz),
    %   and a mode ('notch' or 'bpf'). It returns the filtered signal.
    
%% DSCA FILTER
 % STFT parameters
    extracted_signal = zeros(size(signal));
    freqNums = length(signal)/2;
    window = hamming(256);
    noverlap = 250;
    nfft = 256;
    freq_bins = size(target_spectrogram,1);
    time_bins = size(target_spectrogram,2);

    % Compute STFT of the input signal
    [S, ~, ~] = stft(signal, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    
    % Take the magnitude of the STFT (positive frequencies only)
    S_mag = imresize(flipud(abs(S(1:floor(nfft/2), :))), ...
                              [freq_bins, time_bins]); % Resize to [sig_len/2, sig_len]
    S_mag = S_mag - min(S_mag(:));
    S_mag = S_mag / max(S_mag(:));    
    
    S_signal = S_mag;

    % Transform signal to coefficient domain using dsca
    [~, realCC, imagCC] = dsca(signal);

    realCC_Min = -10*min(abs(realCC))*ones(size(realCC)); % Minimum values for real part
    realCC_Max = 10*max(abs(realCC))*ones(size(realCC)); % Minimum values for real part
    imagCC_Min = -10*min(abs(imagCC))*ones(size(imagCC)); % Minimum values for imaginery part
    imagCC_Max = 10*max(abs(imagCC))*ones(size(imagCC)); % Minimum values for imaginery part

H2 = target_spectrogram;
H1 = S_mag;
cc = zeros(3,3);
while corr2(H2, H1)<0.9999
    sprintf('%2.2f percent is done', 100*corr2(H2, H1))
    for f = 1 : freqNums
        for r = 1 : 3
            for i = 1 : 3
                realCC_Stack = realCC;
                imagCC_Stack = imagCC;
                realCC_Stack(f) = (r==1)*realCC(f) + (r==2)*(realCC_Max(f)+realCC(f))/2 + ...
                                  (r==3)*(realCC(f)+realCC_Min(f))/2;
                imagCC_Stack(f) = (i==1)*imagCC(f) + (i==2)*(imagCC_Max(f)+imagCC(f))/2 + ...
                                  (i==3)*(imagCC(f)+imagCC_Min(f))/2;

                extracted_signal = idsca(realCC_Stack, imagCC_Stack);
                [S, ~, ~] = stft(extracted_signal, fs, 'Window', window, 'OverlapLength', ...
                            noverlap, 'FFTLength', nfft);
                S_mag = imresize(flipud(abs(S(1:floor(nfft/2), :))), ...
                              [freq_bins, time_bins]); % Resize to [sig_len/2, sig_len]
                S_mag = S_mag - min(S_mag(:));
                S_mag = S_mag / max(S_mag(:));    
                cc(r,i) = corr2(S_mag, target_spectrogram);
            end
        end
        
        [r, i] = find(cc==max(max(cc)));
        r = r(1);
        i = i(1);
        
        diffR_Min = abs(realCC(f)-realCC_Min(f));
        diffR_Max = abs(realCC(f)-realCC_Max(f));

        diffI_Min = abs(imagCC(f)-imagCC_Min(f));
        diffI_Max = abs(imagCC(f)-imagCC_Max(f));

        realCC(f) = (r==1)*realCC(f) + (r==2)*(realCC_Max(f)+realCC(f))/2 + ...
                    (r==3)*(realCC(f)+realCC_Min(f))/2;
        imagCC(f) = (i==1)*imagCC(f) + (i==2)*(imagCC_Max(f)+imagCC(f))/2 + ...
                    (i==3)*(imagCC(f)+imagCC_Min(f))/2;

        realCC_Min(f) = (r==1|r==2)*(realCC(f)+realCC_Min(f))/2 + ...
                        (r==3)*(realCC_Min(f)-diffR_Min);
        realCC_Max(f) = (r==1|r==3)*(realCC(f)+realCC_Max(f))/2 + ...
                        (r==2)*(realCC_Max(f)+diffR_Max);

        imagCC_Min(f) = (i==1|i==2)*(imagCC(f)+imagCC_Min(f))/2 + ...
                        (i==3)*(imagCC_Min(f)-diffI_Min);
        imagCC_Max(f) = (i==1|i==3)*(imagCC(f)+imagCC_Max(f))/2 + ...
                        (i==2)*(imagCC_Max(f)+diffI_Max);        
    end
    
    extracted_signal = idsca(realCC, imagCC);
    [S, ~, ~] = stft(extracted_signal, fs, 'Window', window, 'OverlapLength', ...
                     noverlap, 'FFTLength', nfft);
    S_mag = imresize(flipud(abs(S(1:floor(nfft/2), :))), ...
                              [freq_bins, time_bins]); % Resize to [sig_len/2, sig_len]
    S_mag = S_mag - min(S_mag(:));
    S_mag = S_mag / max(S_mag(:)); 

    H2 = H1;
    H1 = S_mag;
end
sprintf('%2.2f percent is done', 100*corr2(H2, H1))

close all
subplot(1, 3, 1);
imagesc(S_signal)
title('Input signal', 'FontSize', 12, 'Color', 'black');
subplot(1, 3, 2);
imagesc(target_spectrogram)
title('Target output', 'FontSize', 12, 'Color', 'black');
subplot(1, 3, 3);
imagesc(S_mag)
title('DSCA output', 'FontSize', 12, 'Color', 'black');
sgtitle('Spectrogram Desplays', 'FontSize', 14, 'FontWeight', 'bold');
