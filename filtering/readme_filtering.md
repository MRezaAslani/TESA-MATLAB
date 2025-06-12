# Application 2: Selective Frequency Filtering using DSCA

This folder contains MATLAB code for applying **Direct Sinusoidal Component Analysis (DSCA)** as a **bandpass** or **notch filter** for selective frequency manipulation in non-stationary signals.

---

## 📁 Files Included

### `main_filter_demo.m`

Main script for performing the filtering experiment:

- Generates a synthetic non-stationary signal composed of sinusoidal segments with different frequencies.
- Constructs a target signal based on selected frequency indices.
- Applies DSCA-based filtering using STFT-domain spectral masking.
- Displays time-domain signals and spectrograms.
- Computes evaluation metrics (SNR, RMSE, Correlation).

### `functions/`

Contains helper functions used in the main experiment:

| File                       | Description                                                   |
| -------------------------- | ------------------------------------------------------------- |
| `dscaFilter.m`             | Main filtering engine using DSCA and interactive STFT masking |
| `dsca.m`                   | Performs DSCA and returns subband components                  |
| `idsca.m`                  | Reconstructs signal from DSCA coefficients                    |
| `stftGoToZero.m`           | Applies masking in the STFT spectrogram domain                |
| `spectrogram_collection.m` | (Optional) Multi-resolution spectrogram collection            |
| `displaySpectrogram.m`     | Displays normalized spectrograms                              |
| `evaluateMetrics.m`        | Computes SNR, RMSE, correlation                               |

---

## 📊 Evaluation Metrics

After filtering, the output signal is compared with the constructed target signal:

- **SNR**: Signal-to-Noise Ratio
- **RMSE**: Root Mean Square Error
- **Correlation Coefficient**: Similarity between filtered and target signals

Example output:

```
--- Evaluation Metrics for 'bpf' Mode ---
SNR: 1.1950 dB
RMSE: 0.2470
Correlation: 0.6658
```
--- Evaluation Metrics for 'notch' Mode ---
SNR: 1.1950 dB
RMSE: 0.2470
Correlation: 0.6658
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

