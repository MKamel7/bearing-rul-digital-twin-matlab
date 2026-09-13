# Bearing RUL Digital Twin V1 Completion Report

Date: 2026-09-13

## V1 Completion Verdict

The project is complete as a defensible v1 MATLAB/Simscape bearing RUL prototype:

- official XJTU-SY lifecycle data was downloaded, SHA-256 verified, extracted and audited
- all 15 lifecycles and 9,216 official snapshots are represented in a measured feature table
- the first RUL target is scoped to the eight outer-race bearings
- nested leave-one-bearing-out is the development protocol
- condition-held-out is retained as a transfer stress test
- age-only and measured-feature similarity models are evaluated on identical held-out folds
- raw data and generated result artifacts remain ignored
- reports preserve the boundary between measured bearing-rig results, reduced Simscape scaffolding and illustrative factory integration

This is not a final industrial deployment and not a field-service lifetime model.

## Current Evidence

Official data gate:

- six official MediaFire RAR parts verified by SHA-256
- archive extracted locally under ignored `data/raw/xjtu-sy-official`
- extracted lifecycle CSV counts match `docs/data/xjtu_sy_lifecycle_manifest.csv`
- first official lifecycle trend generated for `Bearing1_1`

Measured feature gate:

- `results/official_lifecycle/all_bearings_lifecycle_features.csv`
- 9,216 rows across all 15 manifest-labelled lifecycles
- feature columns: horizontal/vertical RMS and crest factor

RUL evaluation gate:

- target subset: eight outer-race bearings
- prediction rows per protocol: 3,636 held-out snapshots
- age-only nested weighted MAE: 898.90 minutes
- feature-similarity nested weighted MAE: 860.98 minutes
- age-only nested mean per-bearing MAE: 201.12 minutes
- feature-similarity nested mean per-bearing MAE: 321.80 minutes

The feature-similarity model reduces the snapshot-weighted error by improving the long `Bearing3_1` case, but it worsens normalized and mean per-bearing error. Therefore it is not promoted as the final public model. It remains an auditable comparator and evidence that measured vibration features contain useful but insufficient signal in the current simple model.

## Reproduction Commands

Generate the official lifecycle feature table:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/summarize_official_lifecycles.m')"
```

Run the age-only baseline:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/run_age_only_rul_baseline.m')"
```

Run the feature-model comparison:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/run_feature_similarity_rul_model.m')"
```

Show the live measured-data RUL replay:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -r "cd('E:\Projects\bearing-rul-digital-twin-matlab'); run('scripts/show_live_rul_replay.m')"
```

Run the reliable non-Simscape regression suite:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "addpath(genpath('src')); files = dir(fullfile('tests','Test*.m')); files = files(~strcmp({files.name}, 'TestSimscapeBody.m')); suites = cell(numel(files), 1); for idx = 1:numel(files), suites{idx} = matlab.unittest.TestSuite.fromFile(fullfile(files(idx).folder, files(idx).name)); end; suite = [suites{:}]; results = run(suite); assertSuccess(results);"
```

## Generated Artifacts

Ignored raw data:

- `data/raw/downloads/`
- `data/raw/xjtu-sy-official/`
- `data/raw/kaggle-condition1/`

Ignored generated results:

- `results/official_lifecycle/`
- `results/rul_baseline/`
- `results/rul_model_comparison/`
- `results/figures/`
- `results/compact_snapshot_screen/`
- `results/evaluation_protocol/`

Tracked reports:

- `docs/reports/official_data_gate_2026-09-13.md`
- `docs/reports/age_only_rul_baseline_2026-09-13.md`
- `docs/reports/rul_model_comparison_2026-09-13.md`
- `docs/reports/v1_completion_report_2026-09-13.md`
- `docs/reports/final_correctness_audit_2026-09-13.md`

## Public Claim Allowed

Allowed:

> MATLAB/Simscape bearing digital-twin prototype using official XJTU-SY LDK UER204 lifecycle data. The project verifies the official archive, extracts measured lifecycle features, evaluates leakage-safe outer-race RUL baselines on held-out bearings and documents where a simple measured-feature model helps and where it fails.

Not allowed:

- field-service RUL or calendar years from accelerated-test minutes
- BMW production accuracy
- conveyor or robot-joint RUL from XJTU-SY bearing data
- a complete XJTU-SY rig replica
- a claim that the feature-similarity model is the final best RUL model

## Future Work

The next technical step is not more scaffolding. It is a stronger health-indicator or hybrid state estimator with a frozen selection rule. It must improve both weighted and per-bearing metrics before becoming the public RUL result.

Factory integration should remain an illustrative demonstrator unless a real conveyor or robot bearing dataset is added.
