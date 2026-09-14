# Public Release Scorecard

Date: 2026-09-14

## Verdict

This repository is release-ready as a 9/10 portfolio project without hardware, provided the public claim stays inside the measured-data boundary.

The value comes from a complete engineering chain, not from pretending to have a factory asset:

1. documented source provenance
2. verified lifecycle manifest and bearing geometry
3. measured vibration feature extraction
4. leakage-controlled held-out RUL evaluation
5. baseline, comparator and accepted hybrid estimator
6. reduced Simscape body for integration structure
7. online measured-data replay
8. tracked reports, visual evidence and CI-safe tests
9. explicit statements of what is not proven

## Why no hardware is acceptable

The project is still strong without hardware because it uses public measured run-to-failure vibration data from a named bearing type and evaluates held-out lifecycles. That is more defensible than a hardware-looking simulation whose data and failure labels are invented.

The missing hardware path is named clearly:

- no live DAQ, serial or OPC UA acquisition
- no field-service lifetime claim
- no production conveyor or robot-joint RUL validation
- no complete physical replica of the XJTU-SY rig

## Public evidence

| Evidence | Location |
| --- | --- |
| Main README with demo, metrics and boundaries | `README.md` |
| Release evidence scorecard | `docs/reports/public_release_scorecard_2026-09-14.md` |
| Final correctness audit | `docs/reports/final_correctness_audit_2026-09-13.md` |
| Hybrid RUL result | `docs/reports/hybrid_health_rate_rul_2026-09-13.md` |
| Data access audit | `docs/data/data_access_audit.md` |
| Evaluation protocol | `docs/model/evaluation_protocol.md` |
| Public CI script | `scripts/run_public_ci_checks.m` |
| Demo video and plots | `docs/assets/` |

## Current portfolio rating

Score: 9/10 for a MATLAB/Simscape predictive-maintenance portfolio project.

What lifts it above the older digital-twin repository:

- measured lifecycle data instead of purely simulated fault labels
- held-out bearing evaluation instead of ad hoc train/test wording
- baseline versus comparator versus accepted model structure
- explicit leakage controls
- reproducible MATLAB scripts
- small public visual assets
- clear claim boundaries

What prevents a higher claim:

- the replay is measured-data replay, not hardware-live streaming
- the Simscape body is reduced and not CAD-accurate
- factory integration is illustrative until a measured conveyor or robot-bearing dataset exists

## Recommended public wording

> MATLAB/Simscape bearing RUL prototype using official XJTU-SY measured lifecycle vibration data. Includes leakage-controlled held-out evaluation, a hybrid health-rate estimator, a reduced Simscape bearing body and an online measured-data replay.

Avoid wording that implies a deployed industrial prognostics system.
