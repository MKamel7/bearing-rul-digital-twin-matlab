# Evaluation Protocol Comparison

Date: 2026-09-12

## Scope

This report compares two candidate evaluation routes for the first outer-race RUL target, using only the audited manifest. It does not train an RUL model and does not inspect raw lifecycle signals.

## Compared Routes

| Route | Independent outer-race bearings | Development folds | Minimum held-out bearings | Tests regime transfer | Best fit |
| --- | ---: | ---: | ---: | --- | --- |
| Nested leave-one-bearing-out pilot | 8 | 8 | 1 | no | first |
| Condition-held-out stress test | 8 | 3 | 2 | yes | second |

## Verdict

Nested leave-one-bearing-out is the better first fit for this project. It gives the largest number of independent outer folds available from the manifest, keeps each held-out unit physically separate, and can force all preprocessing and tuning to happen inside the outer fold.

The condition-held-out route is still useful, but it should be a secondary transfer stress test. Holding out an entire operating condition changes speed, load and lifetime distribution at the same time, so a weak result may reflect regime transfer rather than only model quality.

## Guardrails

- Use the nested pilot during development only.
- Freeze features, preprocessing, thresholds, model class and reporting metrics before any final test claim.
- Report per-bearing rows before aggregation.
- Report per-condition and per-mechanism metrics before any pooled metric.
- Keep normalized-by-lifetime error beside absolute minute error because outer-race lifetimes span from 42 to 2538 minutes in the manifest.

## Generated Artifacts

`scripts/compare_evaluation_protocols.m` writes:

- `results/evaluation_protocol/outer_race_protocol_comparison.csv`
- `results/evaluation_protocol/outer_race_nested_leave_one_bearing_out_folds.csv`
- `results/evaluation_protocol/outer_race_condition_held_out_folds.csv`
