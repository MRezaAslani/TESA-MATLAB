# Application 2: Selective Frequency Filtering using CCA

This folder contains MATLAB code for applying **Correlation Coefficients Adjustment (CCA)** as a **bandpass** or **bandstop** filter for selective frequency manipulation in non-stationary signals.

---

## 📁 Files Included

### `main_filter_demo.m`

Main script for performing the filtering experiment:

- Generates a synthetic non-stationary signal composed of sinusoidal segments with different frequencies.
- Constructs a target signal based on selected frequency indices.
- Applies CCA-based filtering using STFT-domain spectral masking.
- Displays time-domain signals and spectrograms.
- Computes evaluation metrics (SNR, RMSE, Correlation).

### `functions/`

Contains helper functions used in the main experiment:

| File                       | Description                                                   |
| -------------------------- | ------------------------------------------------------------- |
| `ccaFilter.m`             | Main filtering engine using CCA and interactive STFT masking |
| `cca.m`                   | Performs CCA and returns subband components                  |
| `icca.m`                  | Reconstructs signal from CCA coefficients                    |
| `setSTFT.m`               | Applies masking in the STFT spectrogram domain                |
| `generateNonStationarySignal.m`        | Generates a non-stationary as input signal                               |

---

## 📊 Evaluation Metrics

After filtering, the output signal is compared with the constructed target signal:

- **SNR**: Signal-to-Noise Ratio
- **MSE**: Mean Square Error
- **PCC**: Pearson's Correlation Coefficient

Example output:

```
--- Evaluation Metrics for 'bandpass' Mode ---
SNR: 1.1950 dB
RMSE: 0.2470
Correlation: 0.6658
```
```
--- Evaluation Metrics for 'bandstop' Mode ---
SNR: 0.2575 dB
RMSE: 0.6831
Correlation: 0.4809
```

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

