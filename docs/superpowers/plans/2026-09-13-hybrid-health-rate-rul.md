# Hybrid Health-Rate RUL Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a leakage-safe hybrid RUL estimator that keeps the age-only baseline for ordinary trajectories and switches to health-rate extrapolation when a held-out bearing remains healthy beyond the training-lifetime prior.

**Architecture:** Fit model parameters from training bearings only: training lifetimes, a measured RMS end-of-life threshold, a minimum positive health slope, and age/health gates. Prediction runs over a chronological held-out prefix sequence so each displayed or scored row uses only measurements available up to that row.

**Tech Stack:** MATLAB tables, MATLAB unit tests, existing XJTU-SY lifecycle feature CSV, existing manifest-derived fold utilities.

**Spec:** `E:\Memory\wiki\projects\Robotic Conveyor Bearing RUL Roadmap.md`

## Global Constraints

- Use official XJTU-SY lifecycle feature rows only for measured RUL scoring.
- Fit thresholds, slopes, gates and lifetimes on training bearings only inside each fold.
- Do not use held-out future rows when predicting an earlier held-out snapshot.
- Report both snapshot-weighted and per-bearing metrics.
- Do not present accelerated-test minutes as field-service years.

---

### Task 1: Hybrid Fit/Predict API

**Files:**
- Create: `src/modeling/fitHybridHealthRateRulModel.m`
- Create: `src/modeling/predictHybridHealthRateRul.m`
- Test: `tests/TestHybridHealthRateRulModel.m`

**Interfaces:**
- Consumes: training feature table with `BearingID`, `SnapshotIndex`, `HorizontalRMS`, `VerticalRMS`.
- Produces: `fitHybridHealthRateRulModel(trainingFeatures, options)` model struct.
- Produces: `predictHybridHealthRateRul(model, heldoutPrefixRows)` RUL vector, one prediction per chronological prefix row.

- [ ] **Step 1: Write failing tests**

Test that model fitting stores training-only lifetimes and rejects missing feature columns. Test that prefix prediction uses the age baseline before the gate, then switches to health-rate extrapolation when age and health gates are satisfied.

- [ ] **Step 2: Run tests and verify RED**

Run:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "addpath(genpath('src')); results = runtests('tests/TestHybridHealthRateRulModel.m'); assertSuccess(results);"
```

Expected: failure because the fit/predict functions do not exist.

- [ ] **Step 3: Implement minimal API**

Use mean RMS as the health indicator. Fit threshold from training bearing final-window mean RMS quantile. Fit minimum slope from positive training full-life RMS slopes. Predict from chronological prefixes only.

- [ ] **Step 4: Run tests and verify GREEN**

Run the same focused MATLAB test command and require success.

### Task 2: Fold Evaluation And Comparison Script

**Files:**
- Create: `src/modeling/evaluateHybridHealthRateRulModel.m`
- Create: `scripts/run_hybrid_health_rate_rul_model.m`
- Test: `tests/TestHybridHealthRateRulEvaluation.m`

**Interfaces:**
- Consumes: existing `buildEvaluationFolds`, `evaluateAgeOnlyRulBaseline`, and feature CSV.
- Produces: prediction rows with the existing RUL metric columns plus `Model` in the script output.
- Writes ignored artifacts under `results/hybrid_health_rate_rul`.

- [ ] **Step 1: Write failing tests**

Test that evaluation returns held-out rows only and that actual RUL, predicted RUL and normalized errors are computed with held-out lifetimes.

- [ ] **Step 2: Run tests and verify RED**

Expected: failure because `evaluateHybridHealthRateRulModel` does not exist.

- [ ] **Step 3: Implement evaluator and script**

Mirror the existing age-only and feature-similarity evaluator shape. The script compares age-only, feature-similarity and hybrid health-rate models on nested and condition-held-out folds.

- [ ] **Step 4: Run focused and regression tests**

Run hybrid tests, changed-file `checkcode`, and the reliable non-Simscape suite.

### Task 3: Reports And Boundaries

**Files:**
- Create: `docs/reports/hybrid_health_rate_rul_2026-09-13.md`
- Modify: `README.md`
- Modify: `docs/model/claim_boundaries.md`
- Modify: `docs/reports/final_correctness_audit_2026-09-13.md`

**Interfaces:**
- Consumes: generated `results/hybrid_health_rate_rul/*summary_metrics.csv`.
- Produces: final report language that states the metric improvement and the remaining limitations.

- [ ] **Step 1: Run hybrid script**

Generate comparison artifacts.

- [ ] **Step 2: Write report**

Record nested and condition-held-out metrics, explain why the hybrid improves the v1 gate, and preserve the no-field-service/no-factory-accuracy boundary.

- [ ] **Step 3: Verify docs and commit**

Run final checks, commit code first, then docs.
