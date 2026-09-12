# Defect Data Review and Compact-Screen Comparison

Date: 2026-09-11

## Scope

This report reviews the currently available compact XJTU-SY Condition 1 sensor readings and compares:

- accepted baseline candidate rows from `results/compact_snapshot_screen/condition1_accepted_baseline_candidate_features.csv`
- structurally valid but rejected/suspect rows from `results/compact_snapshot_screen/condition1_candidate_snapshot_features.csv`

This is not a full RUL validation. The compact mirror contains one 1.28 s sensor snapshot per listed bearing file, not the official full minute-by-minute lifecycles.

## Test Status

Before this report was written, the full MATLAB test suite was run with:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "addpath(genpath('src')); results = runtests('tests'); assertSuccess(results);"
```

Result: all tests passed, including Simscape body simulation, snapshot validation, envelope features, compact snapshot screening and bearing visual geometry.

## Data Validity Review

All five compact Condition 1 files are structurally valid as sensor snapshots:

- expected two channels: horizontal and vertical vibration
- expected sample count: 32768 samples per channel
- expected duration: 1.28 s at 25.6 kHz
- finite numeric values

However, the manifest says these bearings are run-to-failure specimens with documented eventual failure labels. The compact files must therefore be treated as real sensor snapshots from fault-labelled lifecycle assets, not as ground-truth healthy data.

## Current Screening Result

The robust BPFO/BPFI envelope-ratio screen rejects one row:

| File | Manifest failure label | Structural validity | Baseline accepted | Reason |
| --- | --- | --- | --- | --- |
| Bearing 1_1 .csv | outer race | valid | no | suspect BPFO/BPFI envelope ratio, robust score 13.095 |
| Bearing 1_2.csv | outer race | valid | yes | accepted baseline candidate |
| Bearing 1_3.csv | outer race | valid | yes | accepted baseline candidate |
| Bearing 1_4.csv | cage | valid | yes | accepted baseline candidate |
| Bearing 1_5.csv | inner and outer race | valid | yes | accepted baseline candidate |

Accepted baseline candidates: 4 of 5.

## Compact-Screen Versus Suspect Comparison

The suspect row, `Bearing 1_1 .csv`, has:

- horizontal RMS: 2.1493
- BPFO energy: 11089.7
- BPFI energy: 31.5341
- BPFO/BPFI envelope-energy ratio: 351.673
- BPFO/BPFI robust score: 13.095

The accepted candidate group has:

- horizontal RMS range: 0.4226 to 3.0014
- BPFO/BPFI ratio range: 0.7789 to 61.4973
- BPFO/BPFI ratio median: about 10.872

Interpretation: `Bearing 1_1 .csv` is not rejected because the file is invalid. It is rejected because its BPFO-dominant envelope response is far outside the compact candidate group. This is consistent with an outer-race fault indicator, but it is not proof of a full degradation trend because only one snapshot is present.

## Leakage Controls

The following controls are active or required:

- Do not use failure labels to fit normalization or thresholds.
- Do not call all compact snapshots healthy.
- Do not let artifact names or table labels imply verified health state.
- Do not use `Bearing 1_1 .csv` in accepted baseline statistics.
- Do not concatenate isolated 1.28 s snapshots as continuous vibration.
- Do not claim RUL from the compact mirror.
- Treat the drafted faulty-data scripts as review-only until approved.

## Next Step Under the Roadmap

The roadmap's Phase 2 requires measured-data baseline features and causal health indicators. With the compact mirror only, the next allowed step is a fault-indicated snapshot comparison using real sensor readings, not an RUL model.

Draft scripts were added for review only:

- `scripts/draft_prepare_faulty_real_sensor_features.m`
- `scripts/draft_compare_fault_indicated_vs_compact_screen_real_sensor_results.m`

These scripts have not been executed.
