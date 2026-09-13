# Bearing RUL Digital Twin MATLAB

Physics-informed MATLAB/Simulink/Simscape project for rolling-element bearing remaining-useful-life estimation, using the XJTU-SY LDK UER204 lifecycle dataset as the measured validation anchor.

## V1 status

V1 is complete as a reproducible measured-data bearing RUL prototype. The project verifies the official XJTU-SY archive, extracts measured lifecycle features for all 9,216 official snapshots, evaluates outer-race age-only and feature-similarity RUL models on manifest-derived held-out folds, and records the mixed result without turning it into a field-service or factory-production claim.

The feature-similarity model lowers snapshot-weighted minute MAE versus the age-only baseline, but worsens normalized and mean per-bearing error. It is retained as an auditable comparator, not a final headline RUL model. The live MATLAB view replays official measured XJTU-SY rows and computes each displayed RUL estimate online from the frozen training fold. See `docs/reports/v1_completion_report_2026-09-13.md` and `docs/reports/final_correctness_audit_2026-09-13.md`.

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
- `results/compact_snapshot_screen`: generated compact snapshot screening tables.
## Data status

The official XJTU-SY package has been downloaded from the author-listed MediaFire mirror, verified by SHA-256 and extracted locally under the ignored `data/raw/xjtu-sy-official` folder. The extraction contains all 15 lifecycle folders, with per-bearing CSV counts matching `docs/data/xjtu_sy_lifecycle_manifest.csv`.

The compact Kaggle mirror is still retained only as a small snapshot smoke-test source. It contains five Condition 1 CSV files where each file is one 32,768-sample vibration snapshot, not the official per-minute lifecycle folder.

Generate the compact snapshot sanity check:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/plot_first_snapshot.m')"
```

Output: `results/figures/bearing1_1_first_snapshot.png`.

Generate the first official lifecycle sanity plot:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/plot_official_lifecycle_trend.m')"
```

Outputs:

- `results/official_lifecycle/Bearing1_1_lifecycle_summary.csv`
- `results/figures/Bearing1_1_official_lifecycle_trend.png`

Summarize measured RMS and crest-factor features for all official lifecycle snapshots:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/summarize_official_lifecycles.m')"
```

Output: `results/official_lifecycle/all_bearings_lifecycle_features.csv` with 9,216 manifest-labelled snapshot rows. These are descriptive features only, not an RUL model.
## Current engineering chain

1. `docs/data/xjtu_sy_bearing_geometry.csv` records the LDK UER204 geometry used for fault-frequency calculations.
2. `calculateBearingFaultFrequencies` computes FTF, BPFO, BPFI and BSF for each XJTU-SY operating condition.
3. `models/bearing_body_baseline.slx` is the first reduced Simscape Multibody body: world frame, solver configuration, revolute shaft/inner-ring body and a separated housing body. The shaft revolute joint targets XJTU-SY Condition 1 speed: 2100 rpm, represented as 12600 deg/s.
4. Defect excitation, housing transfer-path identification and RUL state estimation are deliberately later steps.

Generate the frequency table:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/generate_fault_frequency_table.m')"
```

Generate the Simscape body model and exported diagram:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/run_body_simulation.m')"
```

The Simscape model is intentionally a reduced dynamic body, not a CAD-accurate bearing assembly. To inspect the published raceway dimensions as a bearing-like visual approximation, run:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/plot_bearing_visual_geometry.m')"
```

Output: `results/figures/bearing_visual_geometry.png`.
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

## Compact Snapshot Screen

`readXjtuSySnapshot` validates the compact mirror CSV structure before any feature extraction:

- required horizontal and vertical vibration columns
- 32768 samples per channel
- finite numeric values

`computeCompactSnapshotScreen` then computes RMS, crest factor and envelope-band metrics for the five compact Condition 1 snapshots. These rows are labelled `compact snapshot baseline candidate`, not ground-truth healthy data. The compact mirror files are isolated snapshots from run-to-failure bearings, and they are not enough to make a lifecycle RUL claim.

`screenCompactSnapshotCandidates` adds a robust BPFO/BPFI envelope-ratio screen before a row can be used as a baseline candidate. In the current compact mirror run, `Bearing 1_1 .csv` is structurally valid but excluded from accepted baseline statistics because it is an envelope-energy outlier.

Run the screen:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/run_compact_snapshot_screen.m')"
```

Outputs:

- `results/compact_snapshot_screen/condition1_candidate_snapshot_features.csv`
- `results/compact_snapshot_screen/condition1_accepted_baseline_candidate_features.csv`
- `results/figures/condition1_compact_snapshot_screen.png`

## Evaluation protocol

`docs/model/evaluation_protocol.md` defines the split and metric rules that must be followed before RUL modeling starts. In short: fit all preprocessing on training bearings only, keep final test bearings untouched until the end, report per-condition and per-mechanism errors, and include normalized-by-lifetime errors alongside absolute minutes.

Compare the two candidate outer-race evaluation routes:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/compare_evaluation_protocols.m')"
```

Current verdict: nested leave-one-bearing-out is the better first fit for development; condition-held-out evaluation remains a secondary transfer stress test after the pilot is frozen. The tracked summary is `docs/reports/evaluation_protocol_comparison_2026-09-12.md`.

Generated fold assignment CSVs are written under `results/evaluation_protocol` and remain ignored artifacts until full lifecycle data is available.

Run the leakage-safe age-only RUL baseline after generating the official lifecycle feature table:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/run_age_only_rul_baseline.m')"
```

Current baseline verdict: both outer-race protocols are nearly tied, with weighted MAE around 899 minutes, because the baseline only sees snapshot age and training-bearing lifetimes. The tracked summary is `docs/reports/age_only_rul_baseline_2026-09-13.md`; ignored prediction and metric CSVs are written under `results/rul_baseline`.

Compare the age-only baseline with the measured-feature similarity model:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/run_feature_similarity_rul_model.m')"
```

Current model-comparison verdict: the feature-similarity model improves snapshot-weighted minute MAE by reducing the long `Bearing3_1` error, but worsens normalized and mean per-bearing error. It is retained as an auditable comparator, not as a final public RUL performance claim. The tracked summary is `docs/reports/rul_model_comparison_2026-09-13.md`; ignored comparison artifacts are written under `results/rul_model_comparison`.

Show the measured-data live RUL replay in MATLAB:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -r "cd('E:\Projects\bearing-rul-digital-twin-matlab'); run('scripts/show_live_rul_replay.m')"
```

The replay uses official XJTU-SY lifecycle feature rows for held-out `Bearing3_1`, fits the feature-similarity model on the other outer-race bearings in the nested fold, then predicts each incoming replay row as it is displayed. It is genuine measured-data replay, not a live hardware DAQ/serial/OPC UA stream.

