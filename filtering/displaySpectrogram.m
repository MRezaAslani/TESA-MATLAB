function displaySpectrogram(x, fs, plotTitle)
    window = hamming(256);
    noverlap = 250;
    nfft = 256;
    N = length(x);
    time_bins = N;
    freq_bins = N/2;

    [S, ~, ~] = stft(x, fs, 'Window', window, 'OverlapLength', noverlap, 'FFTLength', nfft);
    spec = imresize(flipud(abs(S(1:floor(nfft/2), :))), [freq_bins, time_bins]);
    spec = (spec - min(spec(:))) / (max(spec(:)) - min(spec(:)));

    figure;
    imshow(spec);
    colormap('jet');
    title(plotTitle);
end