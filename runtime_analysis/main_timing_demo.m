% Signal Decomposition and Reconstruction Timing Experiment
% This MATLAB script measures the computational delay of decomposition and
% reconstruction for DSCA and DWT on random 1D signals of varying lengths.
% Each method is run 100 times per signal length, and the average delay
% is reported for reconstruction.

clc; clear; close all;
rng(1)

%% 1. Initialize Parameters
signalLengths = 50:50:1000;       % Signal lengths to test
numTrials = 100;                  % Number of trials per signal length
wavelet = 'db4';                 % Wavelet type for DWT
level = 1;                        % DWT decomposition level
numSubbandsDWT = 3 * level + 1;   % Number of subbands in DWT

% Preallocate timing arrays
reconTimesDSCA = zeros(length(signalLengths), numTrials);
reconTimesDWT = zeros(length(signalLengths), numTrials);

%% 2. Timing Loop
for s = 1:length(signalLengths)
    N = signalLengths(s);
    fprintf('Processing signal length: %d\n', N);

    % Generate random normalized signal
    signal = randn(1, N);
    signal = (signal - min(signal)) / (max(signal) - min(signal));

    for t = 1:numTrials
        %% DSCA Timing
        tic;
        subbandsDSCA = fastDSCA(signal);  % Custom DSCA decomposition
        reconstructedDSCA = sum(subbandsDSCA);
        reconTimesDSCA(s, t) = toc;

        %% DWT Timing
        tic;
        [C, S] = wavedec(signal, level, wavelet);
        subbandsDWT = zeros(numSubbandsDWT, N);
        subbandIdx = 1;
        subbandsDWT(subbandIdx, :) = wrcoef('a', C, S, wavelet, level);
        subbandIdx = subbandIdx + 1;
        for l = level:-1:1
            for type = {'d'}
                subbandsDWT(subbandIdx, :) = wrcoef(type{1}, C, S, wavelet, l);
                subbandIdx = subbandIdx + 1;
            end
        end
        reconstructedDWT = sum(subbandsDWT);
        reconTimesDWT(s, t) = toc;
    end
end

%% 3. Compute Average Times
avgReconTimesDSCA = mean(reconTimesDSCA, 2);
avgReconTimesDWT = mean(reconTimesDWT, 2);

%% 4. Display Results
fprintf('\n===================================================\n');
fprintf('Average Reconstruction Times (seconds):\n');
fprintf('Signal Length\tDSCA\t\tDWT\t\n');
for s = 1:length(signalLengths)
    fprintf('%d\t\t%.6f\t%.6f\t\n', signalLengths(s), avgReconTimesDSCA(s), avgReconTimesDWT(s));
end

%% 5. Plot Results
figure('Name', 'Reconstruction Times', 'NumberTitle', 'off');
semilogy(signalLengths, smoothdata(avgReconTimesDSCA, 'movmean', 5), 'o-', 'LineWidth', 1.5, 'DisplayName', 'DSCA');
hold on;
semilogy(signalLengths, smoothdata(avgReconTimesDWT, 'movmean', 5), 'd-', 'LineWidth', 1.5, 'DisplayName', 'DWT');
hold off;
xlabel('Signal Length (samples)');
ylabel('Time (seconds)');
legend('show');
grid on;
