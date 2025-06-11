# Image Subband Decomposition using DSCA

This folder contains MATLAB scripts for performing **image decomposition** using the proposed **Direct Sinusoidal Component Analysis (DSCA)** method. The goal is to decompose a 2D image into interpretable frequency subbands and compare the results with classical methods like Discrete Wavelet Transform (DWT).

---

## 📂 Files Included

### `main_image_demo.m`
- Loads and preprocesses the `cameraman.tif` image
- Applies DSCA to extract 512 spectral subbands and groups them into four main bands (VLF, MF, HF, VHF)
- Applies DWT using `db4` wavelet for baseline comparison
- Reconstructs the image from both methods and evaluates them using PSNR, SSIM, and MSE
- Displays spatial and frequency-domain visualizations of selected subbands

### `dsca.m`
- Core DSCA algorithm for both 1D and 2D inputs (shared with signal decomposition)

### `metrics_image.m`
- Computes PSNR, SSIM, MSE, and maximum correlation between subbands

### `normalize_subbands.m`
- Normalizes the subbands so that their sum matches the dynamic range of the original image

---

## 🖼️ Description of the Experiment

- **Input**: Cameraman image resized to 64×64
- **DSCA Decomposition**: 512 subbands along third dimension
- **DWT Comparison**: Using `db4` wavelet, level 1 decomposition
- **Subband Grouping**: Four DSCA groups by averaging subbands

---

## 📊 Evaluation Metrics

- **Energy distribution** across four bands (VLF, MF, HF, VHF)
- **PSNR** (Peak Signal-to-Noise Ratio)
- **SSIM** (Structural Similarity Index)
- **MSE** (Mean Squared Error)
- **Maximum Inter-Subband Correlation** for DSCA and DWT

---

## 🧪 Objectives

- Assess the spectral selectivity of DSCA
- Visualize spatial and frequency response of each subband
- Compare fidelity of reconstruction vs. DWT
- Analyze redundancy or independence of extracted components

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