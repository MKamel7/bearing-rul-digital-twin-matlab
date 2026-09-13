# Age-Only RUL Baseline

Date: 2026-09-13

## Scope

This report records the first leakage-controlled RUL baseline after the official XJTU-SY lifecycle data gate passed.

The baseline is intentionally simple: for each held-out snapshot, it predicts remaining life from the median remaining life of the training bearings at the same snapshot index. It uses only training-bearing lifetimes inside each fold. It does not use vibration features, failure labels as online observations or future samples from the held-out bearing.

## Protocols

Two outer-race protocols are evaluated:

- nested leave-one-bearing-out pilot
- condition-held-out stress test

## Results

Both protocols produced 3,636 held-out outer-race snapshot predictions across the eight outer-race lifecycle bearings.

| Protocol | Weighted MAE (minutes) | Weighted normalized MAE | Mean per-bearing MAE (minutes) | Worst bearing |
| --- | ---: | ---: | ---: | --- |
| nested leave-one-bearing-out pilot | 898.90 | 0.4425 | 201.12 | Bearing3_1, 1263.61 min MAE |
| condition-held-out stress test | 898.62 | 0.4404 | 200.17 | Bearing3_1, 1263.52 min MAE |

The two scores are nearly tied because this baseline only uses training-bearing lifetimes and snapshot age. It cannot see vibration health progression, so it fails badly on the long Bearing3_1 run. That failure is useful: future feature-based or hybrid RUL methods must beat this baseline under the same fold assignments without using held-out-bearing future data.

Protocol verdict: keep nested leave-one-bearing-out as the development protocol and use condition-held-out as a secondary transfer stress test after the pilot model is frozen.

Generated ignored artifacts:

- `results/rul_baseline/outer_race_age_only_nested_predictions.csv`
- `results/rul_baseline/outer_race_age_only_condition_held_out_predictions.csv`
- `results/rul_baseline/outer_race_age_only_metrics.csv`

## Claim Boundary

This is a baseline yardstick, not a final RUL result. It establishes a reproducible leakage-safe evaluation path and gives future feature-based or hybrid methods something honest to beat. Any public performance claim still requires the model choice, preprocessing, metrics and held-out protocol to remain frozen.
