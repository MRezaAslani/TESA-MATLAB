# Signal Subband Decomposition using DSCA

This folder contains MATLAB scripts for performing **signal decomposition** using the proposed **Direct Sinusoidal Component Analysis (DSCA)** method. The goal is to decompose a composite signal (e.g., overlapping chirps) into interpretable frequency subbands, visualize their spectral content, and evaluate reconstruction accuracy.

---

## 📂 Files Included

### `main_signal_demo.m`

- Main script to:
  - Generate a synthetic composite chirp signal
  - Decompose it using DSCA
  - Group subbands into four frequency bands (VLF, MF, HF, VHF)
  - Display time-domain plots and spectrograms
  - Reconstruct the original signal and compute evaluation metrics

### `dsca.m`

- Core DSCA algorithm that computes narrowband components using sinusoidal correlation
- Works for both 1D signals and 2D images

### `generate_chirp.m`

- (Optional) Modular function to generate the synthetic test signal

### `metrics_signal.m`

- (Optional) Computes SNR, RMSE, correlation, and subband independence metrics

---

## 🧪 Description of the Experiment

- **Input**: Synthetic signal composed of two overlapping chirp components.
- **Sampling frequency**: 1024 Hz
- **Signal length**: 1024 samples
- **Decomposition**: 512 sinusoidal subbands
- **Grouping**: Four bands (VLF, MF, HF, VHF) based on index ranges

---

## 📈 Evaluation Metrics

- **SNR** (Signal-to-Noise Ratio)
- **RMSE** (Root Mean Square Error)
- **Correlation Coefficient** between original and reconstructed signal
- **Maximum Correlation between Subbands** (decorrelation assessment)

---

## 📄 License

All files are released under the **Creative Commons Attribution-NonCommercial 4.0 International License**.

© 2025 Mohammad Reza Aslani\
📧 [mr.aslani@shdu.ac.ir](mailto\:mr.aslani@shdu.ac.ir)

---

## 📚 Citation

If you use this code, please cite:

```
[Direct Sinusoidal Component Analysis: Advancing Frequency-Domain Techniques]  
Authors: Mohammad Reza Aslani  
Submitted to IEEE Transactions on Signal Processing
```

