# 🕒 Runtime Evaluation of TESA

This directory contains MATLAB scripts for evaluating the **runtime performance** of the **Time-domain Enhanced Spectrogram Alignment (TESA)** algorithm under various signal lengths and spectrogram resolutions.

The runtime evaluation helps analyze TESA’s computational scalability and adaptability for real-time or large-scale applications.

---

## ⚙️ Overview

This experiment measures the **average runtime** of the TESA algorithm for signal lengths ranging from **10,000 to 100,000 samples** (in steps of 10,000) and across **multiple STFT resolutions**.  
Each configuration is repeated **multiple times (100 runs)** to ensure robust average timing statistics.

The script automatically:
1. Generates synthetic signals for testing.
2. Applies TESA using multiple STFT parameter configurations.
3. Records and averages the runtime across repetitions.
4. Saves the runtime data as a CSV table.
5. Produces and saves a comparative runtime plot.

---

## 📂 File Structure

```
Runtime/
├── measure_runtime_tesa.m        # Main script for runtime analysis
└── Results/
    ├── runtime_table_tesa_multi_res.csv   # CSV file with timing data
    └── runtime_plot_tesa_multi_res.png    # Runtime vs. signal length plot
```

---

## 🔍 Experiment Details

### Signal Lengths
- Range: **10,000 to 100,000 samples**
- Step size: **10,000**

### STFT Configurations
| Label | Window Length | Overlap | FFT Length |
|:------|:---------------|:---------|:------------|
| `Win512_Overlap85` | 512 | 85% | 512 |
| `Win384_Overlap80` | 384 | 80% | 384 |
| `Win256_Overlap70` | 256 | 70% | 256 |
| `Win128_Overlap50` | 128 | 50% | 128 |

---

## 🧠 Algorithm Parameters

All runtime evaluations use the following fixed TESA parameters:
| Parameter | Value | Description |
|------------|--------|-------------|
| `λ` (lambda) | 0 | Regularization parameter |
| `α` (alpha) | 1 | Step size scaling factor |
| `β₁` | 0.9 | First moment coefficient (Adam optimizer) |
| `β₂` | 0.999 | Second moment coefficient |
| `num_iter` | 1 | Number of iterations per update |

---

## 📈 Output Files

### 1. **runtime_table_tesa_multi_res.csv**
A tabular dataset where each row represents a signal length and each column corresponds to one STFT configuration.

| Length | Win512_Overlap85 | Win384_Overlap80 | Win256_Overlap70 | Win128_Overlap50 |
|--------:|----------------:|----------------:|----------------:|----------------:|
| 10000 | 0.0153 | 0.0128 | 0.0104 | 0.0089 |
| 20000 | ... | ... | ... | ... |

### 2. **runtime_plot_tesa_multi_res.png**
A comparative plot showing average runtime versus signal length for all STFT configurations.

---

## 🚀 How to Run

1. Open MATLAB (R2021a or later).
2. Ensure that the TESA function (`tesa.m`) and required dependencies are on the MATLAB path.
3. Run the script:

```matlab
measure_runtime_tesa
```

4. After execution, the results and plot will appear in the `Results/` folder.

---

## 📊 Interpretation

- **Slope Analysis:** Steeper slopes indicate higher computational growth with signal length.
- **Resolution Comparison:** Larger window sizes generally lead to longer runtime due to higher FFT complexity.
- **Practical Insight:** Helps determine suitable parameter settings for real-time or low-latency scenarios.

---

## 📄 License

This module follows the same license as the main TESA repository:  
**Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)**

---

## 📫 Contact

For questions or collaborations, contact:  
📧 **mr.aslani@shdu.ac.ir**

---

**© 2025 M. Aslani — TESA Project Runtime Evaluation**
