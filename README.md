# CCA-MATLAB

**Correlation Coefficients Adjustment (CCA)** is a novel spectral decomposition framework for signal and image processing. This repository contains MATLAB implementations of CCA and demonstrates its capabilities across several applications, including frequency subband decomposition, bandpass filtering, time-frequency region extraction, and component separation.

---

## 🔬 Applications Covered

### 1. Signal Subband Decomposition

- Decomposes synthetic signals (e.g., chirp signals) into narrow spectral components
- Visualizes time-domain waveforms and spectrograms for each subband
- Evaluates reconstruction accuracy using SNR, MSE, and PCC

📁 Code: `subband_decomposition/signal_decomposition/`

### 2. Image Subband Decomposition

- Decomposes images (e.g., Cameraman) into interpretable spectral bands
- Compares results with DWT-based subband analysis
- Computes SNR, MSE, and PCC for quantitative evaluation

📁 Code: `subband_decomposition/image_decomposition/`

### 3. Bandpass and Bandstop Filtering

- Selectively retains or suppresses time-frequency regions using CCA
- Demonstrates both passband and stopband behavior using masking

📁 Code: `filtering/`

### 4. Time-Frequency Masking

- Extracts arbitrary regions in the spectrogram using binary masks
- Enables precise localization and reconstruction of energy content

📁 Code: `mask_extraction/`

### 5. Time-Frequency Component Separation

- Decomposes a signal/image into additive components with distinct spectral structures
- Useful for source separation and pattern extraction

📁 Code: `tf_decomposition/`

---

## 📦 Repository Structure

```
CCA-MATLAB/
├── README.md
├── LICENSE
├── subband_decomposition/
├── filtering/
├── mask_extraction/
└── tf_decomposition/             
```

---

## 📊 Dependencies

- MATLAB R2021a or later (recommended)
- Signal Processing Toolbox
- Image Processing Toolbox

---

## 📄 License

This project is released under the Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0).

---

## 📫 Citation

If you use this code in your research, please cite the associated paper:

```
[Paper Title Placeholder]
Authors: [Author Names Placeholder]
Submitted to IEEE Transactions on Signal Processing
```

---

## 🔗 Contact

For questions or collaboration inquiries, contact: mr.aslani@shdu.ac.ir

