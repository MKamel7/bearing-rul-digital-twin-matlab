# Evaluation Protocol

Status: draft, frozen before any lifecycle RUL model is trained.
Date: 2026-09-12

This protocol responds to the external review findings about split support and pooled error metrics. It is intentionally conservative until the official full XJTU-SY lifecycle archive is downloaded and extracted locally.

## Data Gate

The compact Kaggle mirror contains five Condition 1 sensor snapshots. It is valid for ingestion, structural validation, feature smoke tests and compact snapshot screening. It is not valid for lifecycle RUL training, validation or final performance reporting.

The official full lifecycle archive remains required before any RUL model is fit or evaluated.

## Split Rules

All preprocessing, scaling, feature selection, threshold fitting, hyperparameter tuning and model selection must be fit on training bearings only.

The final test bearings must be evaluated once. Do not inspect final test bearing errors to choose features, thresholds, model classes, window lengths or stopping rules.

The current manifest split is retained as a bookkeeping placeholder, not as a final claim design:

| Split | Bearings | Notes |
| --- | ---: | --- |
| train | 9 | Mixed conditions and mechanisms |
| validation | 3 | One per condition |
| test | 3 | One per condition |

The first target claim is narrower than a pooled global RUL score. For an outer-race pilot, the available manifest cells are:

| Condition | Outer-race bearings | Current roles |
| --- | --- | --- |
| Condition 1, 2100 rpm, 12 kN | Bearing1_1, Bearing1_2, Bearing1_3 | train, train, validation |
| Condition 2, 2250 rpm, 11 kN | Bearing2_2, Bearing2_4, Bearing2_5 | train, test, train |
| Condition 3, 2400 rpm, 10 kN | Bearing3_1, Bearing3_5 | train, train |

Because that cell support is small and condition is confounded with lifetime, the acceptable pilot routes are:

1. Mechanism-specific leave-one-bearing-out cross-validation for development only, with all tuning nested inside each outer fold.
2. A condition-held-out stress test after the development protocol is fixed.
3. A final report that names the exact held-out bearings and does not generalize beyond them.

## Metric Rules

Report metrics by condition and by fault mechanism before reporting any pooled metric.

Each RUL report must include:

- absolute error in minutes
- normalized error as a fraction of each bearing lifetime
- signed error so early and late predictions are visible
- per-bearing rows before aggregation
- count of evaluated bearings in every aggregate

Pooled MAE or RMSE is allowed only as a secondary summary. It must not be the headline result because long Condition 3 lifetimes can dominate a pooled minute-scale metric.

## Allowed Current Work

While the full lifecycle data gate is blocked, allowed work is limited to:

- Simscape and visualization scaffolding that does not claim validation
- real compact snapshot ingestion checks
- feature extraction smoke tests on compact snapshots
- documentation and test hardening

Blocked work until the gate passes:

- RUL model fitting
- lifecycle trend plots
- final test evaluation
- public performance claims
