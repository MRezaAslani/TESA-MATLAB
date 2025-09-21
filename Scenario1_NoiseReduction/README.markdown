# Noise Reduction Experiment (Scenario 1)

This repository provides the MATLAB implementation for Scenario 1 of a noise reduction experiment, evaluating the Time-frequency Enhanced Speech Algorithm (TESA) against four baseline methods: Griffin-Lim Algorithm (GLA), Optimal Transport (OT), Deep Neural Network (DNN), and Alternating Direction Method of Multipliers (ADMM). The experiment processes 10 clean audio files from the Voice Bank Corpus at six Signal-to-Noise Ratio (SNR) levels (-50, -40, -30, -20, -10, 0 dB). Performance is assessed using Signal-to-Noise Ratio (SNR) in the time domain and Mean Squared Error (MSE) in the time-frequency (TF) domain. Outputs include reconstructed signals, per-pair and combined SNR/MSE tables, and smooth interpolated plots with grayscale-compatible styles, excluding the Observation baseline from plots.

This work is part of a forthcoming paper submitted to *IEEE Transactions on Signal Processing*.

## Author
Mohammad Reza Aslani

## License
Copyright © 2025 Mohammad Reza Aslani

This work is licensed under the [Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/). You are free to:
- **Share**: Copy and redistribute the material in any medium or format.
- **Adapt**: Remix, transform, and build upon the material.

Under the following terms:
- **Attribution**: Please give appropriate credit to Mohammad Reza Aslani, provide a link to the license, and indicate if changes were made. Proper citation of the associated paper is required.
- **NonCommercial**: You may not use the material for commercial purposes without explicit permission.

No additional restrictions may be applied that legally restrict others from doing anything the license permits.

For commercial licensing inquiries, please contact Mohammad Reza Aslani (see **Contact** section).

## Dataset
The experiment uses 10 clean audio files from the Voice Bank Corpus, comprising 500 utterances from 28 speakers (14 male, 14 female), recorded in English at 48 kHz. These files are stored in the `materials` folder.

**Citation**:  
C. Valentini-Botinhão, *Noisy speech database for training speech enhancement algorithms and TTS models*, University of Edinburgh, Edinburgh DataShare, 2017, DOI: [10.7488/ds/2117](https://doi.org/10.7488/ds/2117).

## Requirements
- MATLAB (R2018a or later recommended)
- MATLAB Signal Processing Toolbox (for `stft` and `istft` functions)
- Implementations of the following algorithms (not included in this repository):
  - `gla`: Griffin-Lim Algorithm
  - `ot`: Optimal Transport-based denoising
  - `dnn`: Deep Neural Network-based denoising
  - `admm`: Alternating Direction Method of Multipliers
  - `tesa`: Time-frequency Enhanced Speech Algorithm (authored by Mohammad Reza Aslani)

## Repository Structure
- **`main_experiment.m`**: The primary script to execute the noise reduction experiment. It processes 10 audio pairs across 6 SNR levels, producing:
  - SNR (time domain) and MSE (TF domain) metrics for Observation, GLA, OT, DNN, ADMM, and TESA.
  - Per-pair and combined SNR/MSE tables (console and text files).
  - Reconstructed signals saved as `.mat` files.
  - Interpolated plots for SNR (time domain) and MSE (TF domain), excluding Observation, with grayscale-compatible line styles and markers.
- **`run_denoising.m`**: The core function implementing the denoising process and metric calculations. It applies TESA and the baseline methods (GLA, OT, DNN, ADMM), computing reconstructed signals and metrics.
- **`materials/`**: Folder for the 10 clean audio files from the Voice Bank Corpus (not included; download from the cited source).
- **`results/`**: Output folder containing:
  - Subfolders (`snr_<level>dB`) with reconstructed signals (`reconstructed_PairXX_snrXXdB.mat`) and combined metrics tables (`results_snr_XXdB.txt`).
  - All metrics (`denoising_results_all_snr_mse.mat`).
  - Plots: `time_domain_metrics_snr_levels.png` (SNR) and `tf_domain_metrics_mse_levels.png` (MSE).

## Usage
To run the experiment, please execute the main script in MATLAB:

1. **Prepare the Dataset**:
   - Download the Voice Bank Corpus from [Edinburgh DataShare](https://doi.org/10.7488/ds/2117).
   - Place the 10 specified audio files (`clean_p250_361.wav`, ..., `clean_p287_332.wav`) in the `materials` folder.
2. **Implement Algorithms**:
   - Ensure implementations of `gla`, `ot`, `dnn`, `admm`, and `tesa` are available in your MATLAB path. The `tesa` function is authored by Mohammad Reza Aslani.
3. **Run the Experiment**:
   ```matlab
   run main_experiment.m
   ```
   - This script processes each audio pair at each SNR level, invokes `run_denoising.m` to perform denoising and compute metrics, and saves results in the `results` folder.
   - Console outputs display per-pair and combined SNR/MSE tables.
   - Plots are generated for GLA, OT, DNN, ADMM, and TESA, excluding the Observation baseline.
4. **View Results**:
   - Check the `results` folder for reconstructed signals, metrics tables, and plots.

## Core Denoising Function
The `run_denoising.m` function is the heart of the experiment, implementing the denoising process for a noisy audio signal. It applies the following algorithms:
- **TESA** (Time-frequency Enhanced Speech Algorithm): Authored by Mohammad Reza Aslani, using parameters `lambda=0`, `alpha=0.2`, `num_iter=3000`, `beta1=0.9`, `beta2=0.999`.
- **GLA** (Griffin-Lim Algorithm): Iterative phase reconstruction with 100 iterations.
- **OT** (Optimal Transport): Denoising with `lambda=0.5`.
- **DNN** (Deep Neural Network): Neural network-based denoising.
- **ADMM** (Alternating Direction Method of Multipliers): Optimization-based denoising with 100 iterations.
- **Observation**: The noisy input signal, used as a baseline for comparison (metrics computed but not plotted).

The function preprocesses signals (rescaling to [-0.5, 0.5], zero-meaning, length alignment), computes Short-Time Fourier Transform (STFT) with a 512-sample Hamming window and 85% overlap, applies each algorithm, and evaluates performance using:
- **Time Domain**: SNR (dB) = `10 * log10(var(clean_speech) / var(clean_speech - reconstructed))`.
- **TF Domain**: MSE = `mean((S_clean(:) - S_reconstructed(:)).^2)`, computed on STFT magnitudes.

## Output Description
- **Metrics**:
  - **Time Domain**: SNR measures reconstruction quality in decibels.
  - **TF Domain**: MSE quantifies error in the STFT magnitude domain.
- **Tables**:
  - Per-pair tables printed to the console for each audio pair and SNR level.
  - Combined tables saved as `results/snr_XXdB/results_snr_XXdB.txt`, showing mean ± standard deviation for SNR and MSE across all pairs.
- **Plots**:
  - `time_domain_metrics_snr_levels.png`: Interpolated SNR curves for GLA, OT, DNN, ADMM, and TESA.
  - `tf_domain_metrics_mse_levels.png`: Interpolated MSE curves for the same methods.
  - Line styles: GLA (dashed), OT (dotted), DNN (dash-dot), ADMM (dashed), TESA (dotted).
  - Markers: GLA (square), OT (diamond), DNN (upward triangle), ADMM (downward triangle), TESA (circle).
- **Reconstructed Signals**:
  - Saved as `results/snr_XXdB/reconstructed_PairXX_snrXXdB.mat` for GLA, OT, DNN, ADMM, and TESA.

## Citation
Please cite the following paper if you use this code or its results in your research:

> M. R. Aslani, "Time-Enhanced Spectrogram Alignment Based on Adam Optimization," *IEEE Transactions on Signal Processing*, vol. 73, pp. 1–10, 2025 (to be updated upon publication).

Additionally, please cite the Voice Bank Corpus:

> C. Valentini-Botinhão, *Noisy speech database for training speech enhancement algorithms and TTS models*, University of Edinburgh, Edinburgh DataShare, 2017, DOI: [10.7488/ds/2117](https://doi.org/10.7488/ds/2117).

## Contact
For questions, bug reports, or commercial licensing inquiries, please contact:  
**Mohammad Reza Aslani**  
📧 [mr.aslani@shdu.ac.ir](mailto:mr.aslani@shdu.ac.ir)  
📧 [as.td@yahoo.com](mailto:as.td@yahoo.com)