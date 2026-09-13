# Bearing RUL V1 Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete a defensible v1 of the MATLAB bearing RUL project with a leakage-safe feature-based model, comparison against the age-only baseline and a final report that separates measured, simulated and assumed claims.

**Architecture:** Keep the v1 model deliberately simple and auditable. Use manifest-derived folds, training-only scaling and nearest-neighbor similarity over measured lifecycle features to predict held-out RUL. Compare against the committed age-only baseline on identical outer-race folds and report per-bearing metrics before any pooled summary.

**Tech Stack:** MATLAB R2026a, MATLAB unit test framework, tables, official XJTU-SY lifecycle feature CSV, ignored `results/` artifacts.

**Spec:** `E:/Memory/wiki/projects/Robotic Conveyor Bearing RUL Roadmap.md`

## Global Constraints

- Do not claim field-service lifetime from XJTU-SY accelerated-test minutes.
- Do not call compact mirror snapshots official healthy or RUL labels.
- Fit all scaling and similarity data on training bearings only inside each fold.
- Use nested leave-one-bearing-out as the development protocol and condition-held-out as a transfer stress test.
- Report per-bearing rows and the number of independent bearings behind any aggregate.
- Do not claim the full Simscape-inclusive MATLAB suite passed if the Simscape browser crash remains unreproduced or unresolved.
- Write tests before production MATLAB code.

---

### Task 1: Feature Similarity RUL Evaluator

**Files:**
- Create: `tests/TestFeatureSimilarityRulModel.m`
- Create: `src/modeling/evaluateFeatureSimilarityRulModel.m`

**Interfaces:**
- Consumes: measured feature table with `BearingID`, `ConditionID`, `FailureLabel`, `SnapshotIndex`, `ElapsedMinutes`, `HorizontalRMS`, `VerticalRMS`, `HorizontalCrestFactor`, `VerticalCrestFactor`
- Consumes: fold table from `buildEvaluationFolds`
- Produces: `predictions = evaluateFeatureSimilarityRulModel(features, folds, featureNames, options)` with per-snapshot actual RUL, predicted RUL, signed error, absolute error and normalized absolute error.

- [x] **Step 1: Write failing tests**

Create tests that prove the evaluator:

```matlab
% 1. Uses only training-bearing feature statistics.
% 2. Predicts held-out RUL from nearest training snapshots.
% 3. Rejects missing feature columns.
```

- [x] **Step 2: Verify red**

Run:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "addpath(genpath('src')); results = runtests('tests/TestFeatureSimilarityRulModel.m'); assertSuccess(results);"
```

Expected: fail because `evaluateFeatureSimilarityRulModel` is undefined.

- [x] **Step 3: Implement evaluator**

Implementation requirements:

```matlab
function predictions = evaluateFeatureSimilarityRulModel(features, folds, featureNames, options)
```

- Default `featureNames`: `["HorizontalRMS", "VerticalRMS", "HorizontalCrestFactor", "VerticalCrestFactor"]`
- Default `options.NeighborCount`: `25`
- Standardize selected features using training rows only inside each fold.
- Find nearest training snapshots by squared Euclidean distance.
- Predict RUL as the median actual RUL of the nearest training snapshots.
- Clamp predictions at zero.
- Return per-held-out-snapshot rows.

- [x] **Step 4: Verify green**

Run focused tests until they pass.

- [x] **Step 5: Commit**

```powershell
git add src/modeling/evaluateFeatureSimilarityRulModel.m tests/TestFeatureSimilarityRulModel.m
git commit -m "feat: add feature similarity RUL model"
```

---

### Task 2: RUL Model Comparison Script and Report

**Files:**
- Create: `scripts/run_feature_similarity_rul_model.m`
- Create: `docs/reports/rul_model_comparison_2026-09-13.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: `results/official_lifecycle/all_bearings_lifecycle_features.csv`
- Consumes: `docs/data/xjtu_sy_lifecycle_manifest.csv`
- Consumes: `evaluateAgeOnlyRulBaseline`
- Consumes: `evaluateFeatureSimilarityRulModel`
- Produces ignored artifacts under `results/rul_model_comparison/`

- [x] **Step 1: Write failing script/report test**

Create `tests/TestRulModelComparisonArtifacts.m` that verifies the script exists, the report names both protocols, and the report contains claim-boundary text.

- [x] **Step 2: Verify red**

Run the focused artifact test. Expected: fail because the script/report do not exist.

- [x] **Step 3: Implement script and report**

Script requirements:

- Read official lifecycle features and manifest.
- Filter to outer-race bearings.
- Build nested and condition-held-out folds.
- Run both age-only and feature-similarity predictors on identical folds.
- Write prediction CSVs and metrics CSVs under `results/rul_model_comparison/`.
- Generate one validation plot for a representative held-out bearing.

Report requirements:

- State model inputs and leakage controls.
- Compare age-only and feature-similarity results.
- Give a direct project verdict.
- Preserve claim boundaries.

- [x] **Step 4: Verify script**

Run:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/run_feature_similarity_rul_model.m')"
```

- [x] **Step 5: Commit**

```powershell
git add README.md scripts/run_feature_similarity_rul_model.m tests/TestRulModelComparisonArtifacts.m docs/reports/rul_model_comparison_2026-09-13.md
git commit -m "feat: compare feature RUL model"
```

---

### Task 3: V1 Completion Documentation and Verification

**Files:**
- Create: `docs/reports/v1_completion_report_2026-09-13.md`
- Modify: `docs/model/evaluation_protocol.md`
- Modify: `docs/model/claim_boundaries.md`
- Modify: `README.md`
- Modify: `E:/Memory/log.md`
- Modify: `E:/Memory/wiki/projects/Robotic Conveyor Bearing RUL Roadmap.md`

**Interfaces:**
- Consumes: committed model comparison metrics and verification output.
- Produces: final project status for future work and portfolio claims.

- [x] **Step 1: Write docs**

Document:

- What is complete in v1.
- What remains future work.
- Exact verification commands.
- Which raw/result artifacts are ignored.
- What public claim is allowed.

- [x] **Step 2: Run verification**

Run:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "issues = checkcode('src/modeling/evaluateFeatureSimilarityRulModel.m','scripts/run_feature_similarity_rul_model.m'); assert(all(cellfun(@isempty, issues)));"
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "addpath(genpath('src')); files = dir(fullfile('tests','Test*.m')); files = files(~strcmp({files.name}, 'TestSimscapeBody.m')); suites = cell(numel(files), 1); for idx = 1:numel(files), suites{idx} = matlab.unittest.TestSuite.fromFile(fullfile(files(idx).folder, files(idx).name)); end; suite = [suites{:}]; results = run(suite); assertSuccess(results);"
```

- [x] **Step 3: Commit**

```powershell
git add README.md docs/model docs/reports/v1_completion_report_2026-09-13.md docs/superpowers/plans/2026-09-13-bearing-rul-v1-completion.md
git commit -m "docs: complete bearing RUL v1 report"
```
