# 📄 Roundtrip Times Dataset for Networked Robot Sensors

This repository contains a dataset of round-trip time measurements from real networked robotic systems, used in the paper "Goodness-of-fit in the Marginal Modeling of Round-Trip Times for Networked Robot Sensor Transmissions".

## 📊 Dataset Overview

The dataset includes measurements from various experimental scenarios with different:

- Network configurations (local, WiFi, 4G, fiber, etc.)
- Data densities (from 20 bytes to 786,432 bytes)
- Geographic locations (local, same building, same city, international)
- Software platforms (Linux, Windows, Android)

## 🔍 Experiment Classes

- `realoct2023`: Recent experiments from October 2023
- `realpapersensors`: Historical experiments from 2014
- `ciprirealrobofeb2025`: Latest robotic experiments

## 📁 File Structure

Each experiment is documented with:

1. A metadata file (`tyrell_roundtripXXX_metadata.txt`) containing:
   - Experiment ID
   - Name
   - Class
   - Time units
   - Data density
   - Network configuration
   - Geographic location
   - Software platforms

2. The corresponding measurement data files

## 🔗 Citation

This dataset was originally published in [Zenodo](https://doi.org/10.5281/zenodo.14967644).

If you use this dataset, please cite both the original Zenodo repository:

```@dataset{fernandez_madrigal_2025,
  author       = {Fernández-Madrigal, Juan-Antonio and Arévalo-Espejo, Vicente and Galindo, Cipriano and Cruz-Martín, Ana and Gago-Benítez, Ana and Gandarias, Juan M.},
  title        = {Roundtrip Times in Networked Telerobots for Sensory Data Transmissions},
  month        = mar,
  year         = {2025},
  publisher    = {Zenodo},
  version      = {1.0.0},
  doi          = {10.5281/zenodo.14967644},
  url          = {https://doi.org/10.5281/zenodo.14967644}
}
```

and the associated paper (DOI to be added when available).

## 📄 License

This dataset is released under [GNU General Public 3.0](LICENSE).
