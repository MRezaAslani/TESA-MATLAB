TESA-MATLAB
Time-Enhanced Spectrogram Alignment (TESA) is a novel phase estimation algorithm for spectrogram magnitudes, enabling signal and image reconstruction in noisy, distorted, or perturbed environments. This repository contains MATLAB implementations of TESA, demonstrating its capabilities across three applications: noise reduction, source separation, and image restoration.

🔬 Applications Covered
1. Noise Reduction

Applies TESA to denoise audio signals in noisy environments, using 10 clean audio files from the Voice Bank Corpus at 6 SNR levels (-50, -40, -30, -20, -10, 0 dB).
Compares TESA against baseline methods (GLA, OT, DNN, ADMM), computing SNR (time domain) and MSE (time-frequency domain).
Generates reconstructed signals, metrics tables, and grayscale-compatible plots (excluding Observation baseline).

📁 Code: noise-reduction/
Dataset Citation:C. Valentini-Botinhão, Noisy speech database for training speech enhancement algorithms and TTS models, University of Edinburgh, Edinburgh DataShare, 2017, DOI: 10.7488/ds/2117.
2. Source Separation

Applies TESA to separate multiple sources in distorted environments, using polyphonic audio mixtures (e.g., Bach10 dataset).
Evaluates performance with Signal-to-Distortion Ratio (SDR) in time and time-frequency domains.
Visualizes separation results and computes quantitative metrics.

📁 Code: source-separation/
3. Image Restoration

Applies TESA to restore images in perturbed environments, using test images (e.g., Lena, Cameraman) with missing pixels (e.g., central square zeroing).
Evaluates reconstruction using Pearson Correlation Coefficient (PCC).
Visualizes restored images and quantitative metrics.

📁 Code: image-restoration/

📦 Repository Structure
TESA-MATLAB/
├── README.md
├── LICENSE
├── noise-reduction/
│   ├── main_experiment.m
│   ├── run_denoising.m
│   └── materials/
├── source-separation/
└── image-restoration/


📊 Dependencies

MATLAB R2021a or later (recommended)
Signal Processing Toolbox (for stft and istft functions)
Image Processing Toolbox (for image restoration)
Algorithm implementations (not included):
gla: Griffin-Lim Algorithm
ot: Optimal Transport-based denoising
dnn: Deep Neural Network-based denoising
admm: Alternating Direction Method of Multipliers
tesa: Time-Enhanced Spectrogram Alignment (authored by Mohammad Reza Aslani)




📄 License
Copyright © 2025 Mohammad Reza Aslani
This project is released under the Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0).
You are free to:

Share — copy and redistribute the material in any medium or format.
Adapt — remix, transform, and build upon the material.

Under the following terms:

Attribution: Please give appropriate credit to Mohammad Reza Aslani, provide a link to the license, and indicate if changes were made. Proper citation of the associated paper is required.
NonCommercial: You may not use the material for commercial purposes without explicit permission.

For commercial licensing, please contact Mohammad Reza Aslani (see Contact).

📫 Citation
If you use this code in your research, please cite the associated paper:

M. R. Aslani, "Time-Enhanced Spectrogram Alignment Based on Adam Optimization," IEEE Transactions on Signal Processing, vol. 73, pp. 1–10, 2025 (to be updated upon publication).

Additionally, for noise reduction, please cite the Voice Bank Corpus:

C. Valentini-Botinhão, Noisy speech database for training speech enhancement algorithms and TTS models, University of Edinburgh, Edinburgh DataShare, 2017, DOI: 10.7488/ds/2117.


🔗 Contact
For questions, bug reports, or commercial licensing inquiries, please contact:Mohammad Reza Aslani📧 mr.aslani@shdu.ac.ir📧 as.td@yahoo.com
