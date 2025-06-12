# Application 4: Time-Frequency Decomposition using DSCA

This folder contains MATLAB code and results demonstrating **time-frequency decomposition** of non-stationary signals using the **Direct Sinusoidal Component Analysis (DSCA)** method.

---

## 📁 Files Included

### `main_decomposition_demo.m`

- Main script for performing signal decomposition.
- Generates a multi-component non-stationary signal.
- Computes the STFT-based spectrogram.
- Applies DSCA decomposition by segmenting the spectrogram into distinct time-frequency components.
- Visualizes the original signal, decomposed components, and corresponding spectrograms.

### `functions/`

| File                            | Description                                                            |
| ------------------------------- | ---------------------------------------------------------------------- |
| `generateNonStationarySignal.m` | Generates a non-stationary synthetic signal with random components     |
| `dscaExtraction.m`              | Extracts signal components from a target spectrogram using DSCA        |
| `decomposeBinaryComponents.m`   | Segments binary spectrogram image into individual connected components |

---

## 🎡 Objective

The goal of this experiment is to evaluate the capability of DSCA in **separating multiple overlapping time-frequency components** from a complex signal.

- The input signal is synthesized by randomly assigning multiple sinusoidal bursts across time.
- A binary spectrogram is constructed to locate dominant time-frequency regions.
- DSCA is applied to extract and reconstruct each region as a separate component.

This demonstrates DSCA's strength in **adaptive segmentation** of non-stationary signals.

---

## 📊 Observations

- The DSCA decomposition successfully identifies and isolates dominant energy components from the time-frequency plane.
- Visual inspection of spectrograms confirms that each component captures a unique frequency pattern.
- The correlation between reconstructed subcomponents is low, indicating **informative and non-overlapping decomposition**.
- Quantitative metrics for reconstruction accuracy:

```
SNR: 2.09 dB
RMSE: 0.492
Correlation with original: 0.735
Max inter-component correlation: 0.0182
```

These values support the fact that the reconstruction retains relevant structures while minimizing interference between components.

---

## 🔖 License

Released under the **Creative Commons Attribution-NonCommercial 4.0 International License**.

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

