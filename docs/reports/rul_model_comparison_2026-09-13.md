# RUL Model Comparison

Date: 2026-09-13

## Scope

This report compares the committed age-only baseline with a feature-similarity RUL model on the official XJTU-SY outer-race lifecycle subset.

The feature-similarity model uses these measured snapshot features:

- Horizontal RMS
- Vertical RMS
- Horizontal crest factor
- Vertical crest factor

For each fold, feature scaling is fit on training bearings only. Held-out bearing rows are transformed with that training-only scaling, then each held-out snapshot is matched to nearest training snapshots. Predicted RUL is the median remaining life of those nearest training snapshots.

## Protocols

Two protocols are evaluated with identical fold assignments for both models:

- nested leave-one-bearing-out pilot
- condition-held-out stress test

Generated ignored artifacts:

- `results/rul_model_comparison/outer_race_rul_model_predictions.csv`
- `results/rul_model_comparison/outer_race_rul_model_per_bearing_metrics.csv`
- `results/rul_model_comparison/outer_race_rul_model_summary_metrics.csv`
- `results/rul_model_comparison/nested_bearing3_1_rul_comparison.png`

## Results

Both models evaluated the same eight outer-race bearings and 3,636 held-out snapshot predictions per protocol.

| Model | Protocol | Weighted MAE (minutes) | Weighted normalized MAE | Mean per-bearing MAE (minutes) | Worst bearing |
| --- | --- | ---: | ---: | ---: | --- |
| age-only baseline | nested leave-one-bearing-out pilot | 898.90 | 0.4425 | 201.12 | Bearing3_1, 1263.61 min MAE |
| feature-similarity model | nested leave-one-bearing-out pilot | 860.98 | 0.7080 | 321.80 | Bearing3_1, 1139.75 min MAE |
| age-only baseline | condition-held-out stress test | 898.62 | 0.4404 | 200.17 | Bearing3_1, 1263.52 min MAE |
| feature-similarity model | condition-held-out stress test | 863.60 | 0.7180 | 326.31 | Bearing3_1, 1139.86 min MAE |

## Verdict

The feature-similarity model is a mixed result. It improves the weighted minute-scale MAE because the long `Bearing3_1` trajectory dominates the snapshot-weighted score and the feature model reduces that worst-case error by about 124 minutes. That is real, measured signal value.

It is not a clean final RUL model. The normalized error and mean per-bearing MAE are worse than the age-only baseline, especially on shorter bearings where feature similarity maps small lifetimes to inappropriate long-life training snapshots. Therefore the v1 result should not be published as a headline performance improvement.

Project decision: keep the age-only model as the conservative baseline, keep the feature-similarity model as an auditable measured-data comparator, and mark the next research step as a frozen health-indicator or hybrid model that must improve both weighted and per-bearing metrics before it becomes the public RUL result.

## Claim Boundary

These are accelerated-test minutes from XJTU-SY bearing-rig data. They are not field-service years and they are not conveyor, robot-joint or BMW plant lifetime predictions.

The result is a measured-data RUL evaluation on a small outer-race subset. It may support a portfolio claim only when phrased as a bearing digital-twin prototype evaluated on public experimental lifecycle data, with an illustrative factory integration remaining separate from the measured RUL score.
