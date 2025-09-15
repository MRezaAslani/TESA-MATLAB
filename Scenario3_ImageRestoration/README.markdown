# Image Restoration Experiment

This repository contains MATLAB code for an image restoration experiment that reconstructs damaged images using multiple algorithms. The project evaluates the performance of five methods—Griffin-Lim Algorithm (GLA), Optimal Transport (OT), Deep Neural Network (DNN), Alternating Direction Method of Multipliers (ADMM), and Time-Enhanced Spectrogram Alignment (TESA)—using Signal-to-Noise Ratio (SNR), Mean Square Error (MSE), and Pearson Correlation Coefficient (PCC) in both time and time-frequency domains. The main script processes 10 images, computes metrics, and visualizes results.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [TESA Implementation](#tesa-implementation)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [File Structure](#file-structure)
- [Output](#output)
- [Customization](#customization)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

## Overview
The project consists of a MATLAB function (`run_restoration.m`) and a main script (`scenario3_main.m`). The `run_restoration` function processes a single image by:
1. Loading and preprocessing the image (converting to grayscale, resizing to 128x128, normalizing).
2. Simulating damage by zeroing a central square region.
3. Computing Short-Time Fourier Transform (STFT) to obtain spectrograms.
4. Applying restoration algorithms: GLA, OT, DNN, ADMM, and TESA.
5. Calculating SNR, MSE, and PCC in time and time-frequency domains.
6. Displaying and saving restored images.

The main script (`scenario3_main.m`) runs the experiment on 10 images, computes the mean and standard deviation of metrics, and generates bar plots for visualization.

## Features
- Processes grayscale images resized to 128x128.
- Simulates damage by zeroing a central square region.
- Applies five restoration algorithms: GLA, OT, DNN, ADMM, and TESA.
- Evaluates performance with SNR, MSE, and PCC in time and time-frequency domains.
- Visualizes restored images (Clean, Damaged, GLA, OT, DNN, ADMM, TESA).
- Saves results in the `results` folder as high-quality PNG images (300 DPI).
- Computes and plots average metrics with standard deviation error bars across multiple images.
- Saves metrics in a `.mat` file for further analysis.

## TESA Implementation
The Time-Enhanced Spectrogram Alignment (TESA) algorithm, implemented in `tesa.m`, uses Adam optimization to reconstruct time-domain signals from a target magnitude spectrogram. Key details:
- **Author**: Mohammad Reza Aslani (mr.aslani@shdu.ac.ir)
- **License**: CC BY-NC 4.0 ([Creative Commons Attribution-NonCommercial 4.0](https://creativecommons.org/licenses/by-nc/4.0/))
- **Description**: TESA optimizes time-domain signal samples using gradient-driven Adam optimization, balancing spectrogram alignment and regularization.
- **Inputs**:
  - `x`: Initial damaged signal (1D column vector, real-valued).
  - `S_target`: Target magnitude spectrogram (same size as `abs(stft(x))`).
  - `stft_params`: Struct with STFT parameters (`fs`, `window`, `noverlap`, `nfft`).
  - `tesa_params`: Struct with TESA parameters (`lambda`, `alpha`, `num_iter`, `beta1`, `beta2`).
- **Output**: Optimized signal (`x_opt`).
- **Default Parameters**:
  - `lambda`: 0.001 (regularization strength).
  - `alpha`: 0.1 (learning rate).
  - `num_iter`: 2000 (number of iterations).
  - `beta1`: 0.9 (Adam first moment).
  - `beta2`: 0.999 (Adam second moment).

The TESA implementation is included in the repository and is critical for the experiment, particularly for tuning its hyperparameters to optimize restoration performance.

## Prerequisites
- **MATLAB**: Version R2018b or later.
- **Toolboxes**:
  - Image Processing Toolbox (for `imread`, `imresize`, `imagesc`).
  - Signal Processing Toolbox (for `stft`, `istft`).
- **Input Images**: Place images in the `materials` folder (e.g., `cameraman.tif`, `lena.tif`, etc.).
- **Write Permissions**: Ensure MATLAB has write access to create the `results` folder.

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/image-restoration-experiment.git
   cd image-restoration-experiment
   ```
2. Create a `materials` folder in the project root and add the following images:
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
3. Verify MATLAB toolboxes:
   ```matlab
   ver
   ```
4. Ensure write permissions for the `results` folder:
   - **Windows**: Check folder properties under Security.
   - **Linux/Mac**: Run `chmod -R u+w results` in the terminal.

## Usage
1. Open MATLAB and navigate to the project directory:
   ```matlab
   cd /path/to/image-restoration-experiment
   ```
2. Run the main script:
   ```matlab
   scenario3_main
   ```
   This will:
   - Process 10 images in the `materials` folder.
   - Apply restoration algorithms and compute metrics (SNR, MSE, PCC).
   - Display restored images for each input.
   - Generate bar plots for average metrics with standard deviation error bars.
   - Save results in the `results` folder.

To run the restoration function on a single image:
```matlab
results = run_restoration('materials/cameraman.tif');
```

## File Structure
```
image-restoration-experiment/
├── materials/                # Folder containing input images
│   ├── cameraman.tif
│   ├── lena.tif
│   └── ...
├── results/                  # Output folder for restored images and metrics
│   ├── restoration_cameraman.png
│   ├── time_domain_metrics.png
│   ├── tf_domain_metrics.png
│   ├── restoration_results.mat
│   └── ...
├── run_restoration.m         # Function to process a single image
├── scenario3_main.m          # Main script to run the experiment on multiple images
├── tesa.m                   # TESA algorithm implementation
└── README.md                # This file
```

## Output
- **Images**: Restored images saved as `results/restoration_<image_name>.png` (300 DPI).
- **Plots**: Bar plots of average metrics (SNR, MSE, PCC) with standard deviation error bars:
  - `results/time_domain_metrics.png`
  - `results/tf_domain_metrics.png`
- **Metrics**: Mean and standard deviation of metrics saved in `results/restoration_results.mat`.
- **Console Output**: Progress for each image and average metrics for all methods.

## Customization
- **Change Input Images**:
  Modify the `images` array in `scenario3_main.m`:
  ```matlab
  images = {'materials/my_image.tif', ...};
  ```
- **Tune TESA Parameters**:
  Adjust `tesa_params` in `run_restoration.m`:
  ```matlab
  tesa_params = struct('lambda', 1e-4, 'alpha', 5e-3, 'num_iter', 15000, 'beta1', 0.9, 'beta2', 0.999);
  ```
- **Modify STFT Parameters**:
  Edit STFT parameters in `run_restoration.m`:
  ```matlab
  win_len = 256;
  noverlap = round(0.9 * win_len);
  nfft = win_len;
  window = hamming(win_len);
  ```

## Dependencies
The project requires the following MATLAB functions (not included in this repository except for `tesa.m`):
- `gla`: Griffin-Lim Algorithm.
- `ot`: Optimal Transport (Wasserstein Barycenters).
- `dnn`: DNN-based phase reconstruction.
- `admm`: Alternating Direction Method of Multipliers.

For testing without these functions, you can use placeholder implementations:
```matlab
function x = gla(varargin)
    x = rand(size(varargin{1}));
end
```

The `tesa.m` function is included and licensed under CC BY-NC 4.0 by Mohammad Reza Aslani.

## Contributing
Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes and commit (`git commit -m "Add feature"`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a Pull Request.

## License
This project is licensed under the MIT License, except for `tesa.m`, which is licensed under CC BY-NC 4.0 by Mohammad Reza Aslani. See the [LICENSE](LICENSE) file for details.