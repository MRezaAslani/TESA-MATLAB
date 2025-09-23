# 🖼️ Image Restoration Experiment

MATLAB implementation for an **image restoration experiment**, evaluating the proposed **Time-Enhanced Spectrogram Alignment (TESA)** against four baseline methods:

- **GLA** — Griffin-Lim Algorithm  
- **OT** — Optimal Transport  
- **DNN** — Deep Neural Network  
- **ADMM** — Alternating Direction Method of Multipliers  

---

## 📊 Experiment Setup

- **Dataset**: 10 grayscale images  
- **Damage Levels**: `1%, 10%, 30%, 50%, 70%, 90%, 99%`  
- **Damage Simulation**: central square region zeroed  

**Evaluation Metrics**:  
- **PCC** — Pearson Correlation Coefficient (time domain)  
- **MSE** — Mean Square Error (time-frequency domain)  

**Outputs**:  
- Reconstructed signals  
- Per-image and combined PCC/MSE tables  
- Smooth interpolated plots (grayscale-compatible)  

> ℹ️ *Observation* baseline is excluded from summary tables and plots.  
> 📝 This work is part of a forthcoming paper submitted to *IEEE Transactions on Signal Processing*.  

---

## 👤 Author

**Mohammad Reza Aslani**

---

## 📜 License

© 2025 Mohammad Reza Aslani  

Licensed under **CC BY-NC 4.0** (Creative Commons Attribution-NonCommercial 4.0 International).  

- ✅ **Share** — copy and redistribute  
- ✅ **Adapt** — remix, transform, build upon  

**Conditions**:  
- Attribution required (cite author + paper)  
- Non-commercial use only  
- No additional restrictions  

💼 For **commercial licensing inquiries**, please contact the author.  

---

## 📂 Dataset

- **Source**: Standard image processing dataset  
- **Images** (10 total):  
  - `cameraman.tif`  
  - `house.tif`  
  - `lake.tif`  
  - `lena.tif`  
  - `livingroom.tif`  
  - `baboon.tif`  
  - `peppers.tif`  
  - `pirate.tif`  
  - `walkbridge.tif`  
  - `woman.tif`  

**Details**:  
- Resized to `128×128`  
- Normalized to `[0, 1]`  
- RGB → converted to grayscale  

📁 Place all images in the `materials/` folder before running.  

---

## ⚙️ Requirements

- MATLAB **R2021a** or later  
- Image Processing Toolbox (`imread`, `imresize`, `rgb2gray`, `rescale`, `imwrite`)  
- Signal Processing Toolbox (`stft`, `istft`, `corr`)  
- Algorithm implementations:  
  - `gla` (Griffin-Lim)  
  - `ot` (Optimal Transport)  
  - `dnn` (Deep Neural Network)  
  - `admm` (ADMM)  
  - `tesa` (proposed method by M. R. Aslani)  

---

## 📁 Repository Structure

├── Main.m # Runs the full experiment
├── run_restoration.m # Core image restoration + metrics calculation
├── materials/ # Input grayscale images (not included)
├── results/ # Experiment outputs


**Generated Outputs**:  
- `.mat` reconstructed signals → `results/<image_name>/`  
- `.png` subplot visualizations → `results/<image_name>/`  
- Metrics tables (`.txt`, `.mat`) → `results/`  
- Grayscale-compatible plots (`.png`) → `results/`  

---

## 🚀 Usage

1. **Prepare Dataset**
   - Place all 10 images inside `materials/`.

2. **Ensure Algorithms**
   - Add implementations of `gla`, `ot`, `dnn`, `admm`, `tesa` to MATLAB path.

3. **Run Main Script**
   ```matlab
   run Main.m
