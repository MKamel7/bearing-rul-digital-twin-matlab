# Model Claim Boundaries

## Measured claim allowed after validation

The project may claim performance on XJTU-SY LDK UER204 accelerated bearing lifecycle records only after the split is frozen and the final test bearings are evaluated once.

## Simulation claim allowed after integration

The robot and conveyor cell may demonstrate how RUL estimates could drive inspection or maintenance decisions in a representative production cell. It is not evidence of real conveyor, robot-joint, or BMW plant lifetime accuracy.

## Forbidden claims until new evidence exists

- Field-service years of bearing life from accelerated test minutes.
- Complete replication of the XJTU-SY laboratory rig.
- Localized spall-growth physics from the Simscape Bearing block alone.
- Conveyor or robot-joint RUL from XJTU-SY bearing data.

## Current lifecycle-data gate

The official full XJTU-SY lifecycle archive was downloaded, SHA-256 verified, extracted and file-count checked on 2026-09-13. The project may now start measured lifecycle feature extraction and training-protocol work. No RUL performance claim is allowed until the evaluation protocol is frozen, preprocessing is fit on training bearings only and held-out bearings are evaluated without post-hoc tuning.

## Accelerated-life caveat

XJTU-SY Condition 1 applies 12 kN to an LDK UER204 bearing whose recorded static load rating is 6.65 kN. That is a load-to-static-rating ratio of about 1.80. Accelerated-test minutes must therefore not be translated into field-service years without a separately justified life model and application load spectrum.

## Current defect-excitation boundary

The localized-defect excitation subsystem is a prototype signal chain. It may be used to test feature extraction and later parameter-identification plumbing. It is not yet an identified physical force or validated housing transfer path. The current BPFO/BPFI envelope-band features are condition indicators on one compact snapshot mirror, not RUL predictions.

