# Hybrid Health-Rate RUL Model

Date: 2026-09-13

## Scope

This report adds the next post-v1 estimator gate: a hybrid health-rate RUL model for the official XJTU-SY outer-race lifecycle subset.

The model keeps the age-only lifetime prior as the conservative default. It switches to a measured health-rate extrapolation only when a held-out trajectory remains low-damage beyond the usual training-lifetime prior. This is designed for the failure mode exposed by `Bearing3_1`: a long, stable measured trajectory that age-only and nearest-neighbor models underpredict.

The health indicator is mean RMS from the horizontal and vertical measured acceleration features. Thresholds, minimum slopes, lifetime priors and gates are fit on training bearings only inside each fold. Held-out predictions are generated from chronological prefixes, so a row cannot use future held-out measurements.

## Results

All models use the same eight outer-race bearings and 3,636 held-out snapshot predictions per protocol.

| Model | Protocol | Weighted MAE (minutes) | Weighted normalized MAE | Mean per-bearing MAE (minutes) | Worst bearing |
| --- | --- | ---: | ---: | ---: | --- |
| age-only baseline | nested leave-one-bearing-out pilot | 898.90 | 0.4425 | 201.12 | Bearing3_1, 1263.61 min MAE |
| feature-similarity model | nested leave-one-bearing-out pilot | 860.98 | 0.7080 | 321.80 | Bearing3_1, 1139.75 min MAE |
| hybrid health-rate model | nested leave-one-bearing-out pilot | 757.05 | 0.3806 | 172.97 | Bearing3_1, 1063.77 min MAE |
| age-only baseline | condition-held-out stress test | 898.62 | 0.4404 | 200.17 | Bearing3_1, 1263.52 min MAE |
| feature-similarity model | condition-held-out stress test | 863.60 | 0.7180 | 326.31 | Bearing3_1, 1139.86 min MAE |
| hybrid health-rate model | condition-held-out stress test | 760.62 | 0.3861 | 175.46 | Bearing3_1, 1065.85 min MAE |

Generated ignored artifacts:

- `results/hybrid_health_rate_rul/outer_race_hybrid_health_rate_predictions.csv`
- `results/hybrid_health_rate_rul/outer_race_hybrid_health_rate_per_bearing_metrics.csv`
- `results/hybrid_health_rate_rul/outer_race_hybrid_health_rate_summary_metrics.csv`
- `results/hybrid_health_rate_rul/nested_bearing3_1_hybrid_rul_comparison.png`

## Verdict

The hybrid health-rate model clears the next software gate. Unlike the v1 feature-similarity comparator, it improves all three main nested metrics versus the age-only baseline:

- lower snapshot-weighted MAE
- lower weighted normalized MAE
- lower mean per-bearing MAE

The improvement is still dominated by `Bearing3_1`, but it is not a one-metric-only win. The model also preserves the age-only behavior for most short trajectories and only extrapolates when the measured prefix remains unusually healthy past the training-lifetime gate.

## Claim Boundary

This is a stronger measured-data RUL pilot on public accelerated bearing-rig data. It is not a deployed industrial prognostics system, not a live hardware acquisition system and not a field-service lifetime model.

The result may support this portfolio wording:

> Extended the MATLAB/Simscape bearing RUL prototype with a leakage-safe hybrid health-rate estimator. On official XJTU-SY outer-race held-out folds, it improved weighted, normalized and per-bearing MAE versus the age-only baseline while preserving explicit accelerated-test and hardware-live claim boundaries.

Do not claim conveyor, robot-joint or BMW production RUL accuracy from this result.
