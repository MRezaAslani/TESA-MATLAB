# TESA-MATLAB

**Time-domain Enhanced Spectrogram Alignment (TESA)** is a novel optimization-based framework designed to improve phase estimation and signal reconstruction from spectrogram magnitudes. Unlike conventional methods such as Griffin-Lim, Optimal Transport, Deep Neural Networks, and ADMM-based algorithms, TESA introduces an **adaptive moment estimation optimizer** that iteratively adjusts temporal or spatial samples to align the input spectrogram with the target magnitude distribution.

This repository provides MATLAB implementations of TESA and demonstrates its capabilities across multiple challenging applications, including **noise reduction**, **source separation**, **image restoration**, and **runtime performance analysis**.

---

## 🔬 Overview

TESA formulates a **hypothesis function** based on spectrogram magnitude and optimizes it using a gradient derived analytically in the paper. The algorithm progressively refines the observation in the time domain to minimize the mismatch between reconstructed and target spectrograms.

Comprehensive experiments were conducted on:
- **Voice Bank Corpus** for audio-based scenarios  
- **Ten standard benchmark images** for image-based tasks  

TESA consistently outperformed the best baseline methods in various high-noise, high-distortion, and data-loss conditions.

### 📈 Reported Improvements

| Metric | Improvement over Best Baseline |
|:--------|:------------------------------:|
| Signal-to-Noise Ratio (SNR) | **+1.9416 dB** |
| Signal-to-Distortion Ratio (SDR) | **+3.8635 dB** |
| Pearson Correlation Coefficient (PCC) | **+24.9770%** |

Additionally, runtime analysis demonstrates TESA’s adaptability to real-time or low-resolution spectrogram configurations.

---

## ⚙️ Applications & Scenarios

### 1. Noise Reduction
- Suppresses additive and structural noise using iterative spectrogram refinement  
- Evaluates restoration accuracy via SNR, SDR, and PCC metrics  

📁 Code: `Scenario1_NoiseReduction/`

---

### 2. Source Separation
- Decomposes mixtures into individual sources using optimized phase alignment  
- Benchmarks TESA against Griffin-Lim and deep learning–based separation methods  

📁 Code: `Scenario2_SourceSeparation/`

---

### 3. Image Restoration
- Restores degraded or partially missing images by optimizing frequency–domain consistency  
- Supports grayscale and RGB image recovery under severe corruption levels  

📁 Code: `Scenario3_ImageRestoration/`

---

### 4. Runtime Evaluation
- Analyzes computational performance of TESA under varying spectrogram parameters  
- Measures runtime with respect to:
  - Spectrogram window size  
  - Hop length and overlap  
  - Frequency and temporal resolutions  

📁 Code: `Runtime/`

---

## 📦 Repository Structure

```
TESA-MATLAB/
├── README.md
├── LICENSE
├── Scenario1_NoiseReduction/
├── Scenario2_SourceSeparation/
├── Scenario3_ImageRestoration/
└── Runtime/
```

---

## 📊 Dependencies

- MATLAB R2021a or later (recommended)
- Signal Processing Toolbox
- Image Processing Toolbox
- Optimization Toolbox (for gradient-based solvers)

---

## 📄 License

This project is distributed under the **Creative Commons Attribution–NonCommercial 4.0 International License (CC BY-NC 4.0)**.  
You may use, modify, and distribute the code for academic and research purposes with appropriate citation.

---

## 📚 Citation

If you use this repository in your research, please cite the following paper:

```
Time-Domain Enhanced Spectrogram Alignment Based on Adam Optimization
Authors: M. R. Aslani, A. Nouri, and _et al_.
Submitted to IEEE Transactions, 2025.
```

Or use the BibTeX entry:

```bibtex
@misc{tesa_matlab_2025,
  author       = {M. R. Aslani},
  title        = {Time-domain Enhanced Spectrogram Alignment (TESA): MATLAB Implementation},
  year         = {2025},
  publisher    = {GitHub},
  howpublished = {\url{https://github.com/MRezaAslani/TESA-MATLAB}},
  note         = {Submitted to IEEE Transactions}
}
```

---

## 🔗 Contact

For technical questions or collaboration inquiries, please contact:  
📧 **mr.aslani@shdu.ac.ir**

---

## 🧠 Keywords
`Signal Reconstruction`, `Spectrogram Alignment`, `Phase Estimation`, `Adaptive Optimization`, `Noise Reduction`, `Source Separation`, `Image Restoration`, `Runtime Analysis`, `MATLAB`
