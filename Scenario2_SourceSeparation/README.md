# 🎧 Source Separation Experiment (Scenario 2)

MATLAB implementation for **Scenario 2** of a source separation experiment, evaluating the **Time-Enhanced Spectrogram Alignment (TESA)** against four baselines:

- Griffin-Lim Algorithm (**GLA**)
- Optimal Transport (**OT**)
- Deep Neural Network (**DNN**)
- Alternating Direction Method of Multipliers (**ADMM**)

The experiment processes **11 clean audio files** from the **Voice Bank Corpus** across five mixture cases:\
Mixtures of **3, 5, 7, 9, and 11 sources**, using random mixing coefficients (non-negative, sum-normalized).

**Performance metrics**:

- **SDR (time domain)**
- **MSE (time-frequency domain)**

**Outputs include**: reconstructed signals, per-reference and combined SDR/MSE tables, and smooth interpolated plots (grayscale-compatible), excluding the *Observation* baseline from plots.

> 📝 This work is part of a forthcoming paper submitted to *IEEE Transactions on Signal Processing*.

---

## 👤 Author

**Mohammad Reza Aslani**

---

## 📜 License

Copyright © 2025 Mohammad Reza Aslani

Licensed under the Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0).

- **Share**: copy and redistribute the material.
- **Adapt**: remix, transform, and build upon the material.

**Conditions**:

- Attribution required (cite author + paper).
- Non-commercial use only.
- No additional restrictions.

💼 For **commercial licensing inquiries**, please contact the author (see **Contact** section).

---

## 📂 Dataset

- **Source**: 11 clean audio files from the **Voice Bank Corpus**
- **File Names**:
  - `p273_182.wav`
  - `p279_059.wav`
  - `p259_265.wav`
  - `p258_207.wav`
  - `p276_276.wav`
  - `p250_226.wav`
  - `p228_035.wav`
  - `p283_277.wav`
  - `p279_121.wav`
  - `p270_224.wav`
  - `p254_026.wav`
- **Details**: 500 utterances from 28 speakers (14 male, 14 female), English, 48 kHz
- **Location**: stored in the `materials/` folder

**Citation**:\
C. Valentini-Botinhão, *Noisy speech database for training speech enhancement algorithms and TTS models*, University of Edinburgh, Edinburgh DataShare, 2017. DOI: 10.7488/ds/2117.

---

## ⚙️ Requirements

- MATLAB (2021a or later)
- MATLAB Signal Processing Toolbox (for `stft`, `istft`)
- Implementations of:
  - `gla` (Griffin-Lim)
  - `ot` (Optimal Transport)
  - `dnn` (Deep Neural Network)
  - `admm` (ADMM)
  - `tesa` (Proposed Time-Enhanced Spectrogram Alignment Method, authored by M. R. Aslani)

---

## 📁 Repository Structure

- `Main.m` → runs the full experiment
- `run_separation.m` → core source separation + metrics calculation
- `materials/` → clean audio files (not included; download separately)
- `results/` → outputs (signals, metrics, plots)

**Generated outputs include**:

- Reconstructed signals (`.mat`) in `results/ref_XX_case_YY/`
- Metrics tables (`.txt`, `.mat`)
- Plots (`.png`), grayscale-compatible

---

## 🚀 Usage

1. **Prepare the dataset**

   - Download from Edinburgh DataShare.
   - Place files (`p250_182.wav`, ..., `p254_026.wav`) in `materials/`.

2. **Implement algorithms**

   - Ensure `gla`, `ot`, `dnn`, `admm`, `tesa` are in MATLAB path.

3. **Run experiment**

   ```matlab
   run Main.m
   ```
