# Final Correctness Audit

Date: 2026-09-13

## Verdict

The project is complete as a v1 MATLAB/Simscape bearing RUL prototype grounded in official measured XJTU-SY lifecycle data.

It is correct to present it as:

- a reproducible MATLAB bearing RUL workflow over official XJTU-SY measured lifecycle data
- a leakage-controlled outer-race RUL evaluation with held-out bearings
- a reduced Simscape body and defect-excitation scaffold for future integration
- a live MATLAB measured-data replay that computes RUL estimates online as replay rows arrive

It is not correct to present it as:

- a deployed factory predictive-maintenance system
- a live hardware sensor acquisition system
- a field-service lifetime model
- a complete physical replica of the XJTU-SY rig
- proof of conveyor, robot-joint or BMW production RUL accuracy

## Completed Evidence Gates

- Official XJTU-SY archive downloaded, SHA-256 verified and extracted locally.
- Manifest file counts match all 15 official lifecycle folders.
- Official lifecycle features were generated for 9,216 measured snapshots.
- Outer-race age-only and feature-similarity RUL models use identical manifest-derived folds.
- Feature-similarity scaling is fit on training bearings only.
- `fitFeatureSimilarityRulModel` and `predictFeatureSimilarityRul` separate historical training from live-frame prediction.
- `scripts/show_live_rul_replay.m` fits from the nested fold training bearings and predicts each held-out replay row online.
- Generated raw data and result artifacts remain ignored rather than committed.

## Current RUL Result

The feature-similarity model has a mixed measured result. It improves snapshot-weighted MAE on the outer-race subset, mainly by reducing the long `Bearing3_1` error, but it worsens normalized and mean per-bearing error. The conservative project conclusion is therefore:

- age-only remains the baseline
- feature similarity remains an auditable measured-feature comparator
- no headline public RUL performance claim should be made from the feature-similarity model alone

## Verified Commands

Focused model and replay tests:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "addpath(genpath('src')); results = [runtests('tests/TestFeatureSimilarityRulModel.m'), runtests('tests/TestFeatureSimilarityFitPredict.m'), runtests('tests/TestRulModelComparisonArtifacts.m'), runtests('tests/TestLiveRulReplayArtifacts.m')]; assertSuccess(results);"
```

MATLAB code analysis for changed files:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "checkcode('src/modeling/fitFeatureSimilarityRulModel.m','src/modeling/predictFeatureSimilarityRul.m','src/modeling/evaluateFeatureSimilarityRulModel.m','scripts/show_live_rul_replay.m','tests/TestFeatureSimilarityFitPredict.m','tests/TestLiveRulReplayArtifacts.m')"
```

Live measured-data replay execution:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/show_live_rul_replay.m')"
```

Reliable non-Simscape regression suite:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "addpath(genpath('src')); files = dir(fullfile('tests','Test*.m')); files = files(~strcmp({files.name}, 'TestSimscapeBody.m')); suites = cell(numel(files), 1); for idx = 1:numel(files), suites{idx} = matlab.unittest.TestSuite.fromFile(fullfile(files(idx).folder, files(idx).name)); end; suite = [suites{:}]; results = run(suite); assertSuccess(results);"
```

## Residual Limits

The reliable non-Simscape suite is the acceptance gate for this v1 software state. The Simscape-inclusive test remains outside the final acceptance gate because the MATLAB desktop previously crashed in a Chromium/Qt browser path during Simscape-inclusive execution. That crash is a tooling stability issue to isolate separately; it should not be hidden, and it should not be used as evidence against the measured-data RUL workflow.

The next real technical improvement is a stronger health indicator or hybrid estimator with a frozen selection rule. It must improve both weighted and per-bearing metrics before becoming the public model.
