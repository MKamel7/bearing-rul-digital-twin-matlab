# Bearing RUL Digital Twin MATLAB

Physics-informed MATLAB/Simulink/Simscape project for rolling-element bearing remaining-useful-life estimation, using the XJTU-SY LDK UER204 lifecycle dataset as the measured validation anchor.

## Claim boundaries

This project targets a bearing digital-twin prototype calibrated with recorded experimental data. The later robotic conveyor cell is an illustrative integration simulation. Measured bearing-rig results must not be presented as robot-joint, conveyor, or BMW production lifetime accuracy.

## First milestone

- Preserve a source ledger for every physical/data parameter.
- Preserve a lifecycle manifest for each XJTU-SY bearing run.
- Load and validate the manifest with MATLAB tests.
- Keep missing raw signal files visible as an auditable data-access gate.

## Run tests

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "addpath(genpath('src')); results = runtests('tests'); assertSuccess(results);"
```

## Layout

- `src/data`: manifest and dataset loading utilities.
- `tests`: MATLAB unit tests.
- `docs/data`: source ledger and lifecycle manifest.
- `docs/model`: model notes and claim boundaries.
- `data/raw`: downloaded original archives and extracted raw data, not committed unless explicitly approved.
- `results/figures`: generated plots.
## Data status

The full official XJTU-SY package is still a data-access gate. On 2026-09-10, the author-listed Google Drive scripted endpoints returned HTTP 500, and the Dropbox mirror reported that the shared link was deleted or disabled. A compact Kaggle mirror downloaded successfully, but it contains five Condition 1 CSV files where each file is one 32,768-sample vibration snapshot, not the official per-minute lifecycle folder.

The first generated figure is therefore a snapshot sanity check, not an RUL or lifecycle result:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/plot_first_snapshot.m')"
```

Output: `results/figures/bearing1_1_first_snapshot.png`.
## Current engineering chain

1. `docs/data/xjtu_sy_bearing_geometry.csv` records the LDK UER204 geometry used for fault-frequency calculations.
2. `calculateBearingFaultFrequencies` computes FTF, BPFO, BPFI and BSF for each XJTU-SY operating condition.
3. `models/bearing_body_baseline.slx` is the first reduced Simscape Multibody body: world frame, solver configuration, revolute shaft/inner-ring body and a separated housing body.
4. Defect excitation, housing transfer-path identification and RUL state estimation are deliberately later steps.

Generate the frequency table:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/generate_fault_frequency_table.m')"
```

Generate the Simscape body model and exported diagram:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "addpath(genpath('src')); buildBearingBodyModel(string(pwd)); load_system('models/bearing_body_baseline.slx'); open_system('bearing_body_baseline'); print('-sbearing_body_baseline','-dpng','-r150',fullfile(pwd,'results','figures','bearing_body_baseline_model.png')); close_system('bearing_body_baseline',0);"
```
## Defect excitation and envelope features

Current status:

- `generateLocalizedDefectExcitation` creates a prototype localized-defect excitation: periodic impact timing at a selected fault frequency, followed by a damped resonance.
- `extractEnvelopeBandFeatures` computes Hilbert-envelope spectral energy around BPFO and BPFI bands.
- `bearing_body_baseline.slx` now includes a visible `Localized Defect Excitation` subsystem. Its output is terminated as a force-injection placeholder until transfer-path parameters are identified from training bearings.

Generate the envelope-spectrum plot:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/plot_envelope_features.m')"
```

Generate the defect-excitation demo:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/plot_defect_excitation_demo.m')"
```

