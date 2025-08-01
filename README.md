# 📄 marginal_rtt_modeling

This repository contains the official MATLAB implementation of the methods presented in the paper:

> **"Goodness-of-fit in the Marginal Modeling of Round-Trip Times for Networked Robot Sensor Transmissions"**

This is a development of the [TYRELL](https://babel.isa.uma.es/research/projects/tyrell/) research project.

When a mobile robot cannot perform certain computations onboard, it must transmit sensory data to a remote station for processing. The resulting actions are sent back to the robot, forming a control loop. This introduces **stochastic round-trip times** due to non-deterministic network behavior or non-real-time software.

Because robots often operate under strict timing constraints, modeling these delays is essential. While **time series forecasting** methods are common, they can be **computationally expensive**, **unsuitable for online use**, fail to account for **all delay sources** in complex systems or do not provide **enough information in their models** (or not model at all) to make relevant decisions.

This work proposes an alternative: **marginal probabilistic modeling** of round-trip times, which ignores temporal dependencies under the assumption that **regime changes** can be detected using statistical tests. We focus on hypothesis testing for regime modeling and change detection, and adapt three classical distributions—**Log-logistic**, **Log-normal**, and **Exponential**—to this setting. We introduce improvements in parameter estimation and goodness-of-fit tests tailored to real-world robotic data.

Over **2150 hours** of computing time have been devoted to validate our approach, demonstrating both statistical robustness and practical suitability for real-time applications.

---

## ⭐ Key Features of the library

- ✅ Unified interface across all distributions  
- ✅ Robust maximum likelihood estimators  
- ✅ Tailored goodness-of-fit tests  
- ✅ Random sample generation support  
- ✅ Parameter validation and diagnostics  
- ✅ MEX acceleration for performance-critical routines  
- ✅ Built-in tools for visual validation and testing  

---

## Requirements

We have evaluated this library in Linux64 systems with Matlab 2023 and the following toolboxes:

- Statistics and Machine Learning Toolbox v23.2
- Curve Fitting Toolbox v23.2
- Global Optimization Toolbox v23.2
- Optimization Toolbox v23.2
- Econometrics Toolbox v23.2
- Signal Processing Toolbox v23.2

---

## 🧪 Evaluation

All models and methods have been tested on a dataset gathered from diverse real-world robot communication scenarios, totaling over **2100 hours** of data. The framework demonstrated consistent, scalable, and interpretable performance under practical constraints, validating its suitability for real-time robotic systems.

---

## 📌 Citation

Authors are: Juan-Antonio Fernández-Madrigal, Vicente Arévalo-Espejo, Ana Cruz-Martín, Cipriano Galindo-Andrades, Adrián Bañuls-Arias, Juan-Manuel Gandarias-Palacios.

If you use this repository or the methods it implements, please cite the original paper (DOI/arXiv to be added here when available).

---

## 💻 Repository overview

This repository provides the full MATLAB implementation of the methods and experiments described in the paper, including:

- Custom **maximum likelihood estimators** for each distribution  
- **Goodness-of-fit** tests for round-trip time modeling  
- **Regime change detection** using sliding-window hypothesis testing  
- Scripts to process real-world data from networked robotic systems
- A copy of the **networked robot round-trip times dataset** previously reported in [Zenodo](https://doi.org/10.5281/zenodo.14967644).

Repository organization:

📦 root/  
 ┣ 📂 src/        – Library source code: estimators, tests, and modeling  
 ┣ 📂 src/dataset – Copy of the networked robot RTTs dataset in [Zenodo](https://doi.org/10.5281/zenodo.14967644)   
 ┣ 📄 LICENSE     – Source code license  
 ┗ 📄 README.md   – This file  

The library is divided in several concerns: 
- [Unified model management](#%EF%B8%8F-unified-model-management)
- [Individual probability distributions](#-individual-probability-distributions) 
- [Utility functions](#%EF%B8%8F-utility-functions) 
- [Main scripts](#-main-scripts)  

### ⚙️ Unified model management

There is a set of functions that define a unified interface for creating, fitting, and validating probabilistic models. Some of them are:

- [`ModelCreate.m`](src/ModelCreate.m) – Create model instances  
- [`ModelCreateRnd.m`](src/ModelCreateRnd.m) – Create randomized models according to typical networked robot RTT characteristics 
- [`ModelFit.m`](src/ModelFit.m) – Fit a model to empirical data  
- [`ModelGof.m`](src/ModelGof.m) – Perform goodness-of-fit tests
- [`ModelRnd.m`](src/ModelRnd.m) – Draw a sample from a model

---

### 📐 Individual probability distributions

We have implemented the following functionality for all the distributions used in the paper:

- Parameter validation
- Pdf, cdf, moments calculations
- Random sample generation
- Model fitting with the distribution (mostly MLE)
- Goodness-of-fit testing
  
In the following there is a list of the most relevant functions for the main distributions of the paper:

#### Log-normal distribution

- [`LognormalCheckParms.m`](src/LognormalCheckParms.m)  
- [`LognormalIsValid.m`](src/LognormalIsValid.m)  
- [`LognormalRnd.m`](src/LognormalRnd.m)  
- [`LognormalFit.m`](src/LognormalFit.m)  
- [`LognormalGof.m`](src/LognormalGof.m)  

#### Log-logistic distribution

- [`LoglogisticCheckParms.m`](src/LoglogisticCheckParms.m)  
- [`LoglogisticIsValid.m`](src/LoglogisticIsValid.m)  
- [`LoglogisticRnd.m`](src/LoglogisticRnd.m)
- [`LoglogisticFit.m`](src/LoglogisticFit.m)  -- Includes optimized C-written, win and lin compiled MEX files
- [`LoglogisticGoF.m`](src/LoglogisticGoF.m)  
 
#### Exponential distribution

- [`ExponentialCheckParms.m`](src/ExponentialCheckParms.m)  
- [`ExponentialIsValid.m`](src/ExponentialIsValid.m)  
- [`ExponentialRnd.m`](src/ExponentialRnd.m)  
- [`ExponentialFit.m`](src/ExponentialFit.m)  
- [`ExponentialGof.m`](src/ExponentialGof.m)  

---

### 🛠️ Utility functions

Additional support tools:

- [`ConstantsInit.m`](src/ConstantsInit.m) – Initialize common constants  
- [`drawHisto.m`](src/drawHisto.m) – Plot histograms of sample distributions with info about the first moments
- [`weld_functions.m`](src/weld_functions.m) – Weld a set of functions smoothly using sigmoid weights, as explained in the paper
- [`progress.m`](src/progress.m) – Show in console a step of the progress of an ongoing procedure, with timing information
- [`gong.m`](src/gong.m) – Play a sound when a process completes  
- [`notify.m`](src/notify.m) – Send a email notification

---

### 🧠 Main scripts

There are a number of scripts that carry out the main procedures reported in the paper.

- [`test_showscenario.m`](src/test_showscenario.m)  This script shows one scenario from the dataset, with detected regimes if desired.
- [`test_tabulategofthrs.m`](src/test_tabulategofthrs.m)   This script generates a .mat file with the threshold pattern for a given distribution.
- [`test_alphapower.m`](src/test_alphapower.m)  This script computes the significance and power of a given target distribution and generates a .mat file with them.
- [`test_alphapowerfigures.m`](src/test_alphapowerfigures.m)   This script shows figures resulting from the data stored by test_alphapower.m.
- [`test_detectregimes.m`](src/test_detectregimes.m)   This script scans all scenarios detecting regimes with the procedures of a given distribution, storing the results. It has also sections to show figures of those results.

## 📄 License

This dataset is released under [GNU General Public 3.0](LICENSE).