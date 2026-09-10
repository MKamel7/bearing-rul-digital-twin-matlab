# Bearing RUL First Milestone Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first reproducible MATLAB milestone for the XJTU-SY bearing RUL project: source ledger, lifecycle manifest, manifest loader and tests.

**Architecture:** Keep the first milestone data-first. A manifest table records each physical bearing lifecycle and its operating condition. A small MATLAB loader validates required columns and raw-file presence before any modeling code exists.

**Tech Stack:** MATLAB R2026a, MATLAB unit test framework, tables, no downloaded datasets committed by default.

**Spec:** `E:/Memory/wiki/projects/Robotic Conveyor Bearing RUL Roadmap.md`

## Global Constraints

- Do not reuse or edit the old `Digital-twin-Predictive-maintenance` coursework repo.
- Keep measured bearing validation, simulated conveyor integration and assumed quantities visibly separate.
- Do not concatenate XJTU-SY minute snapshots as continuous vibration.
- Freeze data splits before model tuning.
- Do not claim field-service RUL from accelerated test minutes.
- Write tests before production MATLAB code.

---

### Task 1: Manifest Contract

**Files:**
- Create: `tests/TestBearingManifest.m`
- Create: `docs/data/xjtu_sy_lifecycle_manifest.csv`
- Create: `docs/data/source_ledger.csv`
- Create: `src/data/loadBearingManifest.m`

**Interfaces:**
- Produces: `manifest = loadBearingManifest(manifestPath, rawRoot)` where `manifest` is a MATLAB table with required lifecycle metadata plus `RawFileExists`.

- [x] **Step 1: Write the failing test**

```matlab
classdef TestBearingManifest < matlab.unittest.TestCase
    methods (Test)
        function manifestHasRequiredColumns(testCase)
            manifestPath = fullfile(pwd, "docs", "data", "xjtu_sy_lifecycle_manifest.csv");
            rawRoot = fullfile(pwd, "data", "raw", "xjtu-sy");
            manifest = loadBearingManifest(manifestPath, rawRoot);
            required = ["BearingID", "ConditionID", "SpeedRPM", "LoadKN", "SampleRateHz", "SnapshotSeconds", "SnapshotPeriodSeconds", "ChannelCount", "FailureLabel", "Split", "RawRelativePath", "RawFileExists"];
            testCase.verifyTrue(all(ismember(required, string(manifest.Properties.VariableNames))));
        end

        function manifestPreservesKnownOperatingConditions(testCase)
            manifestPath = fullfile(pwd, "docs", "data", "xjtu_sy_lifecycle_manifest.csv");
            rawRoot = fullfile(pwd, "data", "raw", "xjtu-sy");
            manifest = loadBearingManifest(manifestPath, rawRoot);
            testCase.verifyEqual(height(manifest), 15);
            testCase.verifyEqual(unique(manifest.SpeedRPM)', [2100 2250 2400]);
            testCase.verifyEqual(unique(manifest.LoadKN)', [10 11 12]);
            testCase.verifyEqual(unique(manifest.SampleRateHz), 25600);
            testCase.verifyEqual(unique(manifest.SnapshotSeconds), 1.28);
            testCase.verifyEqual(unique(manifest.SnapshotPeriodSeconds), 60);
        end

        function missingRawDataIsVisible(testCase)
            manifestPath = fullfile(pwd, "docs", "data", "xjtu_sy_lifecycle_manifest.csv");
            rawRoot = fullfile(pwd, "data", "raw", "xjtu-sy");
            manifest = loadBearingManifest(manifestPath, rawRoot);
            testCase.verifyClass(manifest.RawFileExists, "logical");
            testCase.verifyFalse(any(manifest.RawFileExists), "Before dataset download, no raw lifecycle files should be silently treated as present.");
        end
    end
end
```

- [x] **Step 2: Run test to verify it fails**

Run: `matlab -batch "addpath(genpath('src')); results = runtests('tests'); assertSuccess(results);"`
Expected: FAIL because `loadBearingManifest` is not defined.

- [x] **Step 3: Write minimal implementation**

Implement `loadBearingManifest.m` to read the manifest, validate required columns and append `RawFileExists` from `rawRoot` plus `RawRelativePath`.

- [x] **Step 4: Run test to verify it passes**

Run: `matlab -batch "addpath(genpath('src')); results = runtests('tests'); assertSuccess(results);"`
Expected: PASS.

- [ ] **Step 5: Commit**

```powershell
git add README.md docs src tests .gitignore
git commit -m "feat: scaffold bearing RUL manifest"
```

