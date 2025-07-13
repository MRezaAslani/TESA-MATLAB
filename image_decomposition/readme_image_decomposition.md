# Image Subband Decomposition using CCA

This folder contains MATLAB scripts for performing **image decomposition** using the proposed **Correlation Coefficients Adjustment (CCA)** method. The goal is to decompose a 2D image into interpretable frequency subbands and compare the results with classical methods like the Discrete Wavelet Transform (DWT).

---

## 📂 Files Included

### `main_image_demo.m`
- Loads and preprocesses the `cameraman.tif` image
- Applies CCA to extract 512 spectral subbands and groups them into four main bands (VLF, MF, HF, VHF)
- Applies DWT using `db4` wavelet for baseline comparison
- Reconstructs the image from both methods and evaluates them using PCC
- Displays spatial and frequency-domain visualizations of selected subbands

### `cca.m`
- Core CCA algorithm for both 1D and 2D inputs (shared with signal decomposition)

### `metrics_image.m`
- Computes SNR, MSE, and maximum correlation between subbands

### `normalize_subbands.m`
- Normalizes the subbands so that their sum matches the dynamic range of the original image

---

## 🖼️ Description of the Experiment

- **Input**: Cameraman image resized to 64×64
- **CCA Decomposition**: 512 subbands along third dimension
- **DWT Comparison**: Using `db4` wavelet, level 1 decomposition
- **Subband Grouping**: Four CCA groups by averaging subbands

---

## 📊 Evaluation Metrics

- **Power distribution** across four bands (VLF, MF, HF, VHF)
- **PCC** (Pearson's Correlation Coefficient)
- **Maximum Inter-Subband Correlation** for CCA and DWT

---

## 🧪 Objectives

- Assess the spectral selectivity of CCA
- Visualize the spatial and frequency response of each subband
- Compare fidelity of reconstruction vs. DWT
- Analyze the redundancy or independence of extracted components

---

## 📄 License

All files are released under the **Creative Commons Attribution-NonCommercial 4.0 International License**.

© 2025 Mohammad Reza Aslani  
📧 [mr.aslani@shdu.ac.ir](mailto:mr.aslani@shdu.ac.ir)

---

## 📚 Citation

If you use this code, please cite:

```
[Direct Sinusoidal Component Analysis: Advancing Frequency-Domain Techniques]  
Authors: Mohammad Reza Aslani  
Submitted to IEEE Transactions on Signal Processing
```
