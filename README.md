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

