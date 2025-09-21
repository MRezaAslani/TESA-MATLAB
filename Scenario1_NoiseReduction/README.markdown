# 🎧 Noise Reduction Experiment (Scenario 1)

MATLAB implementation for **Scenario 1** of a noise reduction experiment, evaluating the **Time-frequency Enhanced Speech Algorithm (TESA)** against four baselines:  
- Griffin-Lim Algorithm (**GLA**)  
- Optimal Transport (**OT**)  
- Deep Neural Network (**DNN**)  
- Alternating Direction Method of Multipliers (**ADMM**)  

The experiment processes **10 clean audio files** from the **Voice Bank Corpus** at six Signal-to-Noise Ratio (SNR) levels:  
`-50, -40, -30, -20, -10, 0 dB`.  

**Performance metrics**:  
- **SNR (time domain)**  
- **MSE (time-frequency domain)**  

**Outputs include**: reconstructed signals, per-pair and combined SNR/MSE tables, and smooth interpolated plots (grayscale-compatible), excluding the *Observation* baseline from plots.

> 📝 This work is part of a forthcoming paper submitted to *IEEE Transactions on Signal Processing*.

---

## 👤 Author
**Mohammad Reza Aslani**

---

## 📜 License
Copyright © 2025 Mohammad Reza Aslani  

Licensed under the [Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/).

- **Share**: copy and redistribute the material.  
- **Adapt**: remix, transform, and build upon the material.  

**Conditions**:  
- Attribution required (cite author + paper).  
- Non-commercial use only.  
- No additional restrictions.  

💼 For **commercial licensing inquiries**, please contact the author (see **Contact** section).

---

## 📂 Dataset
- **Source**: 10 clean audio files from the **Voice Bank Corpus**  
- **Details**: 500 utterances from 28 speakers (14 male, 14 female), English, 48 kHz  
- **Location**: stored in the `materials/` folder  

**Citation**:  
C. Valentini-Botinhão, *Noisy speech database for training speech enhancement algorithms and TTS models*, University of Edinburgh, Edinburgh DataShare, 2017. DOI: [10.7488/ds/2117](https://doi.org/10.7488/ds/2117).

---

## ⚙️ Requirements
- MATLAB (R2018a or later)  
- MATLAB Signal Processing Toolbox (for `stft`, `istft`)  
- Implementations of:
  - `gla` (Griffin-Lim)  
  - `ot` (Optimal Transport)  
  - `dnn` (Deep Neural Network)  
  - `admm` (ADMM)  
  - `tesa` (Time-frequency Enhanced Speech Algorithm, authored by M. R. Aslani)  

---

## 📁 Repository Structure
- **`main_experiment.m`** → runs the full experiment  
- **`run_denoising.m`** → core denoising + metrics calculation  
- **`materials/`** → clean audio files (not included; download separately)  
- **`results/`** → outputs (signals, metrics, plots)  

**Generated outputs include**:  
- Reconstructed signals (`.mat`)  
- Metrics tables (`.txt`, `.mat`)  
- Plots (`.png`), grayscale-compatible

---

## 🚀 Usage
1. **Prepare the dataset**  
   - Download from [Edinburgh DataShare](https://doi.org/10.7488/ds/2117).  
   - Place files (`clean_p250_361.wav`, …, `clean_p287_332.wav`) in `materials/`.  

2. **Implement algorithms**  
   - Ensure `gla`, `ot`, `dnn`, `admm`, `tesa` are in MATLAB path.  

3. **Run experiment**  
   ```matlab
   run main_experiment.m
