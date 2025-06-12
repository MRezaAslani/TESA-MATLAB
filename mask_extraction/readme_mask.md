# Application 3: Arbitrary Time-Frequency Masking using DSCA

This folder contains MATLAB code for **selectively extracting arbitrary time-frequency regions** from the spectrogram of a signal using the **Direct Sinusoidal Component Analysis (DSCA)** method.

---

## 📁 Files Included

### `main_mask_demo.m`
Main script for performing the mask-based extraction experiment:
- Generates a non-stationary signal with multiple frequency segments.
- Loads a custom binary mask (e.g., emoji shape).
- Applies the mask on the STFT spectrogram.
- Uses DSCA to reconstruct a signal based on the masked spectrogram.
- Visualizes original, target, and extracted signals.

### `main_negative_mask_demo.m`
An alternate version of the experiment where the **inverted mask** is used, demonstrating the complementary behavior of DSCA under mask negation.

### `functions/`

| File                         | Description                                                        |
|------------------------------|--------------------------------------------------------------------|
| `generateNonStationarySignal.m` | Generates a synthetic non-stationary signal with random segments |
| `dscaExtraction.m`           | Reconstructs signal from masked spectrogram using DSCA             |

---

## 🎯 Objective

This experiment showcases the **flexibility** of DSCA in extracting user-defined time-frequency regions. Unlike traditional methods that rely on fixed bases, DSCA enables reconstruction of signals from **non-structured** masks.

The experiment uses an **emoji-shaped binary mask** to extract matching patterns from the input signal’s spectrogram. This demonstrates that the method can handle any mask shape, regardless of alignment with true time-frequency atoms.

---

## 📊 Observations

- The extracted signal visually conforms to the masked spectrogram.
- Objective metrics such as SNR or correlation are not optimal, due to the mismatch between the artificial mask and actual time-frequency energy distribution.
- Despite distortions, this proves DSCA’s potential for **customizable, interpretable filtering** in the time-frequency domain.

### 🔁 Negative Mask Experiment (main_negative_mask_demo.m)

In the second variant of the experiment, we apply the **inverted version of the mask**, extracting the complementary portion of the original spectrogram. This allows us to:

- Demonstrate the **selectivity and completeness** of DSCA in signal partitioning
- Observe that summing both DSCA-extracted signals (from original and inverted masks) approximately reconstructs the original signal
- Reinforce the method’s usefulness in segmentation or region-based energy analysis

The experiment highlights how **arbitrary binary masking** in the time-frequency domain can be flexibly utilized for designing interpretable and highly customized decomposition tasks.

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

