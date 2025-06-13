# DSCA Timing Evaluation

This folder presents timing comparisons between **Direct Sinusoidal Component Analysis (DSCA)** and **Discrete Wavelet Transform (DWT)** for signal decomposition and reconstruction.

---

## 📁 Files Included

| File                      | Description                                                     |
|---------------------------|-----------------------------------------------------------------|
| `main_timing_demo.m`     | Runs the timing test across signal lengths (50 to 1500 samples) |
| `fastDSCA.m`             | Optimized DSCA decomposition function using IFFT                |
| `idsca.m`                | Reconstruction function to recover the original signal          |
| `timing.png`             | Plot showing timing performance vs. signal length              |

---

## ⚙️ Setup

- The test script executes each method **100 times per signal length**, and averages are recorded.
- DSCA uses the `fastDSCA` module.
- DWT uses MATLAB's `wavedec` and `wrcoef` functions (db4, level 5).

---

## 📊 Average Reconstruction Times

| Signal Length | DSCA (s) | DWT (s)  |
|---------------|----------|----------|
| 50            | 0.000079 | 0.001778 |
| 100           | 0.000188 | 0.001532 |
| 150           | 0.000443 | 0.002046 |
| 200           | 0.000580 | 0.001508 |
| 250           | 0.000988 | 0.001747 |
| 300           | 0.001334 | 0.001916 |
| 350           | 0.001296 | 0.001396 |
| 400           | 0.001419 | 0.001234 |
| 450           | 0.001678 | 0.001231 |
| 500           | 0.002060 | 0.001308 |
| 550           | 0.003904 | 0.001868 |
| 600           | 0.003191 | 0.001364 |
| 650           | 0.003646 | 0.001395 |
| 700           | 0.004188 | 0.001406 |
| 750           | 0.004721 | 0.001452 |
| 800           | 0.005172 | 0.001449 |
| 850           | 0.005882 | 0.001487 |
| 900           | 0.006419 | 0.001495 |
| 950           | 0.007119 | 0.001526 |
| 1000          | 0.007902 | 0.001534 |

---

## 📈 Timing Plot

![Timing Plot](timing.png)

The chart above shows that **DSCA** has **very low initial latency** for short signals and increases **approximately linearly**, while DWT remains relatively constant regardless of signal length.

---

## 📌 Observations

- DSCA is faster for signals shorter than ~250 samples.
- DSCA timing grows with signal length due to per-frequency component synthesis.
- DWT shows fixed-cost behavior thanks to recursive structure.

---

## 🔧 License

Released under the **Creative Commons Attribution-NonCommercial 4.0 International License**.

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

