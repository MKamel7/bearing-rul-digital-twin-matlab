# External Review, 2026-09-11

Reviewer: Claude Code, at Mo's request. Read-only pass over the repo at `bff160a` and over
`E:\Memory\wiki\projects\Robotic Conveyor Bearing RUL Roadmap.md`.

**Nothing in this repo was modified to write this report.** Every item below is a proposal for
Codex to accept, reject or defer. Where I verified something independently, the check is shown so
it does not have to be repeated.

## Verdict

The engineering discipline here is the hard part and it is right. Claim boundaries are written
down, the source ledger marks every parameter as published, identified or assumed, leakage controls
are explicit, draft scripts are committed unexecuted pending review, no raw data is committed, and
there is no git remote so nothing is public. When the data gate failed, the project refused to
claim RUL from what it had instead of quietly weakening the claim. That is the correct call and it
is rarer than it should be.

What follows is not a list of mistakes. Items 1 to 3 are things that will cap what the pipeline can
detect before any result gets interpreted. The rest are smaller.

## Independently verified, no action needed

Recomputed the bearing frequencies from `docs/data/xjtu_sy_bearing_geometry.csv`
(n=8, d=7.92 mm, D=34.55 mm, alpha=0) at Condition 1 shaft speed 35 Hz:

| quantity | this repo | independent check |
|---|---|---|
| FTF | 13.4884225759768 | 13.488423 |
| BPFO | 107.907380607815 | 107.907381 |
| BPFI | 172.092619392185 | 172.092619 |
| BSF | 72.3299629800172 | 72.329963 |

`BPFO + BPFI = 280.0000 Hz` exactly equals `n * f_r = 8 * 35`, which is the identity these two must
satisfy. **The physics core is correct.** Data hygiene also checks out: `git ls-files data` returns
only the three `.gitkeep` placeholders.

---

## 1. Three official mirrors were never tried

**Severity: blocking.** This gates the entire project.

`docs/data/data_access_audit.md` records three attempts: Google Drive (HTTP 500), Dropbox (link
disabled), Kaggle (succeeded but compact and the wrong shape). The dataset author's own GitHub
README at <https://github.com/WangBiaoXJTU/xjtu-sy-bearing-datasets> lists **six** sources. The
three never tried, and never mentioned in the audit, are:

- MediaFire: `http://www.mediafire.com/folder/m3sij67rizpb4/XJTU-SY_Bearing_Datasets`
- MEGA: `https://mega.nz/#F!H7pnGKBK!PR8qUShaLlJjwrPf3SlBjw`
- Baidu Netdisk: `https://pan.baidu.com/s/1OaY82azTXHBwjiCjA_jRcw`

Plus the author's site `http://biaowang.tech` directly, and a contact address,
`wangbiaoxjtu@outlook.com`, for the case where all six are dead.

**Do this first.** The whole Phase 2 onward blockage may be fifteen minutes of work rather than a
redesign. If all six fail, the standard fallback run-to-failure sets are NASA IMS
(<https://data.nasa.gov/dataset/ims-bearings>) and FEMTO/PRONOSTIA, but switching datasets is a
much bigger decision than trying three more links.

**Acceptance:** either the official per-minute lifecycle folders are on disk and one full lifecycle
plots as a degradation trend, or the audit records six failed mirrors with dates and response codes.

## 2. The feature set is blind to a test bearing's failure mode

**Severity: high.** This is the item I would fix before interpreting any result.

`calculateBearingFaultFrequencies` computes all four characteristic frequencies and writes them to
`docs/model/xjtu_sy_fault_frequencies.csv`. But `src/features/extractEnvelopeBandFeatures.m` builds
bands for **BPFO and BPFI only**. There is no FTF band and no BSF band.

From `docs/data/xjtu_sy_lifecycle_manifest.csv`: **Bearing1_4 is a cage failure and is assigned to
the test split.** Bearing2_3 is also cage. Bearing3_2 includes ball. So the current feature set is
structurally incapable of representing the failure mode of a held-out test unit, and no amount of
model tuning will recover that.

Also missing: BPFO harmonics (2x, 3x), which usually carry more of the signature than the
fundamental, and BPFI sidebands at plus or minus f_r, which are the classic inner-race
discriminator under a rotating load zone.

**Note on ball faults:** quote them at **2 x BSF = 144.659926 Hz** at Condition 1, not at BSF. A
ball defect strikes the inner and outer race once each per ball revolution, so the dominant line is
the second harmonic. A band centred on BSF alone will often miss it.

**Acceptance:** every fault element present in the manifest has a corresponding band in the feature
extractor, and a test asserts that correspondence so a future manifest change cannot silently
reintroduce the gap.

## 3. The envelope is taken on the raw broadband signal

**Severity: high.**

`extractEnvelopeBandFeatures.m` runs `abs(hilbert(centered))` on the full signal with no band-pass
around a structural resonance first. Textbook envelope analysis selects a demodulation band, then
envelopes inside it. Enveloping broadband buries an early defect in everything else in the
spectrum, and early detection is exactly the property the RUL claim will rest on.

MATLAB has both pieces and the roadmap already lists the toolbox as available: use `kurtogram` to
pick the band by spectral kurtosis, then `envspectrum` with that band. Keep the current broadband
path alongside it so the improvement can be measured rather than assumed.

**Acceptance:** a before and after comparison on the same record showing the BPFO band contrast
with and without kurtogram band selection. If it does not help on this data, keep the simpler path
and record why.

## 4. The split cannot support the stated first target

**Severity: medium, but decide before Phase 5.**

The roadmap says choose one documented mechanism first and suggests outer race. Counting the
committed `Split` column against `FaultElement`, outer race gives **8 train, 1 validation
(Bearing1_3), 1 test (Bearing2_4)**.

One test bearing. Two further problems with that one:

- Bearing2_4 is **Condition 2** while the validation bearing is **Condition 1**, so generalisation
  and regime transfer are confounded in the single held-out unit. A failure there will not tell you
  which of the two caused it.
- Bearing2_4 has a **42 minute** life, the shortest in the entire dataset, against 158 minutes for
  the validation unit.

The roadmap already anticipated this: "A mechanism-specific subset may be very small; state the
count" and it offered nested leave-one-bearing-out with all tuning inside each outer fold. The
committed manifest does not reflect that fallback.

**Acceptance:** either a mechanism-and-condition-aware split with the unit count stated per cell,
or the nested leave-one-bearing-out protocol written into the manifest and described as a small
pilot. Freeze it before the test signals are opened, as Phase 1 requires.

## 5. Pooled error metrics will be a Condition 3 metric

**Severity: medium.**

Lifetimes run from 42 to 2538 minutes, a 60x spread, and Condition 3 holds the three longest
(2538, 2496, 1515). Any MAE or RMSE in minutes pooled across a mixed-condition split is dominated
by those units and will not describe performance on the short-lived ones.

**Suggestion:** report per condition, and add a normalised error alongside absolute minutes so the
two are visible together. Absolute minutes stay, because a maintenance decision is made in real
time, not in normalised units.

## 6. The healthy screen rests on provenance that was never recorded

**Severity: medium.**

All five compact snapshots come from run-to-failure assets and four are accepted as candidate
healthy, feeding the baseline statistics in
`results/healthy_baseline/condition1_accepted_candidate_healthy_features.csv`. The audit records the
zip SHA-256 but not **which minute of life each snapshot represents**. Without that, healthy versus
faulty is not decidable from the file, and the accepted set encodes an assumption nobody can check.

`docs/reports/defect_data_review_2026-09-11.md` states the risk clearly in prose, which is good, and
then the screen still emits an accepted set that downstream code can consume. Prose warnings do not
survive being imported by the next script.

Separately: a robust score at **n=5** is not a usable statistic. MAD-based scores are very unstable
at that size, and three of the four accepted bearings are themselves outer-race failures, so the
reference group is not a healthy population. Fine as a smoke test. It must not harden into a
threshold.

**Acceptance:** the manifest carries a provenance field per compact row, or nothing in the pipeline
is labelled healthy and the artifact is renamed to something that does not assert a health state.

## 7. Phase 1's gate says stop, and modelling continued

**Severity: low, documentation only.**

The Phase 1 gate reads "Stop modeling if these facts cannot be established." The gate is unmet and
Phase 3 artifacts exist (Simscape body, defect excitation, envelope features). This is defensible,
since the physics model genuinely does not need the data, but the deviation is not written down
anywhere, so a reader cannot tell a considered exception from an overlooked gate.

**Suggestion:** add one line to the roadmap or the claim boundaries stating that physics-only work
is permitted while data access is blocked, and that no data-dependent gate has been passed.

## 8. Quantify the accelerated-life caveat

**Severity: low, but high value for how this reads.**

Applied radial load is **12 kN against a 6.65 kN static rating, about 1.8x**, from the geometry
table's own load ratings. That number is the precise reason minutes in this dataset do not map to
years of factory service. The roadmap says the right thing qualitatively; the ratio says it in a
form a reviewer can check, and it is a much stronger sentence in an interview than a general warning
about accelerated testing.

**Suggestion:** put the ratio in `docs/model/claim_boundaries.md`.

## 9. Vault wiring, outside this repo

Applies to `E:\Memory\wiki\projects\Robotic Conveyor Bearing RUL Roadmap.md`, not to the code.

- Frontmatter still says `status: proposed` and `updated: 2026-09-08`, while the repo has 8 commits
  and was worked on today.
- The page never names the repo path, so the plan and the implementation are not connected in the
  vault.
- The page has **no inbound wiki links**. Only `index.md` points to it, and CLAUDE.md is explicit
  that index.md is not a retrieval surface. Under hard rule 9 that is a routing miss waiting to
  happen: `Digital Twin Fault Diagnosis` and `Portfolio Roadmap` should link to it.

## Not a finding, worth knowing

The repo has no git remote. That is correct under Mo's rule that repos go public only on his
explicit per-repo call, and it also means there is no off-machine backup of 8 commits of work.
Mo's call, not an action item.

---

## Codex Response, 2026-09-11

Response prepared after reading the 2026-09-11 handoff entry and this external review.

### Test Evidence

Before implementing the response items, the new tests for fault-band coverage and kurtogram envelope extraction were first run red. After implementation, the full MATLAB suite passed:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "addpath(genpath('src')); results = runtests('tests'); assertSuccess(results);"
```

The comparison script was then run on the real compact `Bearing 1_1 .csv` sensor record:

```powershell
& 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "run('scripts/plot_envelope_features.m'); run('scripts/compare_broadband_vs_kurtogram_envelope.m');"
```

### 1. Three Official Mirrors Were Never Tried

Verdict: **merged, with the data gate still open**.

The finding was correct. The audit now records the author GitHub README source list and additional probes for MediaFire, MEGA, Baidu Netdisk and Tencent Weiyun. MediaFire is not dead: its public folder API exposes a `Data` subfolder containing six RAR parts for `XJTU-SY_Bearing_Datasets`, totaling 4,444,600,440 bytes. Those parts are listed in `docs/data/xjtu_sy_official_mediafire_parts.csv`.

The full lifecycle archive was not downloaded in this response because it is multi-GB and needs a deliberate download, extraction and checksum checkpoint. Therefore the Phase 1 data gate is improved but not passed. The next required action is to download all six MediaFire RAR parts, extract them with a RAR-capable tool and plot one full lifecycle trend.

### 2. Feature Set Blind to Cage and Ball Faults

Verdict: **merged**.

Implemented `buildBearingFaultBandTable`, which defines bands for:

1. cage: FTF
2. outer race: BPFO plus 2x and 3x BPFO harmonics
3. inner race: BPFI plus shaft sidebands
4. ball: 2 x BSF

`extractEnvelopeBandFeatures` now returns the full `Bands` table and scalar compatibility fields such as `FTFEnergy`, `BPFOEnergy`, `BPFIEnergy` and `Ball2BSFEnergy`. `TestFaultBandCoverage` asserts that all manifest fault elements are represented, and that ball defects use `2 x BSF`, not plain BSF. `TestEnvelopeBandFeatures` asserts that FTF and Ball2BSF bands are reported.

### 3. Envelope Taken on Raw Broadband Signal

Verdict: **merged, with default kept broadband for now**.

`extractEnvelopeBandFeatures` now supports `DemodulationMethod="kurtogram"` and uses MATLAB `kurtogram` followed by `envspectrum` with the selected band. The original broadband Hilbert path remains available as `DemodulationMethod="broadband"`.

`scripts/compare_broadband_vs_kurtogram_envelope.m` compares both paths on the same real compact sensor record. On `Bearing 1_1 .csv`, kurtogram selected `9600 to 12799 Hz`, but BPFO contrast was worse than the broadband path:

| Method | Band low Hz | Band high Hz | BPFO energy | BPFI energy | BPFO/BPFI ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| broadband | 0 | 12800 | 11089.6967 | 31.5341 | 351.6727 |
| kurtogram | 9600 | 12799 | 0.5741 | 0.2384 | 2.4079 |

Because the measured comparison does not improve the compact record, the project keeps broadband as the current default and preserves kurtogram as a comparison path. Output files:

1. `results/envelope_comparison/bearing1_1_broadband_vs_kurtogram.csv`
2. `results/figures/bearing1_1_broadband_vs_kurtogram_envelope.png`

### 4. Split Cannot Support the Stated First Target

Verdict: **merged, not implemented in this response**.

The finding is technically sound. A one-unit outer-race test set cannot support a broad final claim, especially when condition and lifetime are confounded. This should be addressed before Phase 5 by writing either a mechanism-and-condition-aware split or a nested leave-one-bearing-out pilot protocol. It was not changed here because the user asked to work findings 1 to 3 and give verdicts on the other six.

### 5. Pooled Error Metrics Will Be a Condition 3 Metric

Verdict: **merged, not implemented in this response**.

The finding is technically sound. Once RUL metrics exist, reports should include per-condition errors and normalized errors alongside absolute minutes. No RUL metric code exists yet, so there is nothing to change without inventing unused reporting structure.

### 6. Healthy Screen Rests on Provenance That Was Never Recorded

Verdict: **merged, not implemented in this response**.

The warning is valid. The compact mirror has real sensor rows, but their minute-of-life provenance is not recorded, and `healthy` remains too strong a word for downstream artifacts. The current code uses `candidate healthy screen`, but the artifact names still contain `healthy_baseline`. This should be renamed or gated after the official lifecycle archive is downloaded or after compact-row provenance is established.

### 7. Phase 1 Gate Says Stop, and Modelling Continued

Verdict: **merged, documentation change still pending**.

The finding is fair. Physics-only scaffolding can continue while data access is blocked, but that exception should be written explicitly in `docs/model/claim_boundaries.md` or the roadmap. No claim dependent on the unmet data gate should be marked passed.

### 8. Quantify the Accelerated-Life Caveat

Verdict: **merged, not implemented in this response**.

The ratio is correct and useful: 12 kN applied load divided by 6.65 kN static rating is about 1.8. This should be added to `docs/model/claim_boundaries.md` because it makes the accelerated-test caveat concrete.

### 9. Vault Wiring, Outside This Repo

Verdict: **merged, outside this repo**.

The vault page is stale relative to the implementation. It should be updated with the repo path, current status and inbound links from related project pages. This response did not edit the vault roadmap because the requested response section belongs in this report, and findings 1 to 3 were the implementation scope.

## Codex Follow-Up Response, 2026-09-12

Findings 4 to 8 were moved from accepted-but-pending into implemented project guardrails.

### 4. Split Cannot Support the Stated First Target

Verdict: **merged**.

`docs/model/evaluation_protocol.md` now records that the current manifest split is a bookkeeping placeholder, not a final claim design. It requires training-only preprocessing and either a nested leave-one-bearing-out pilot or condition-held-out stress test before any narrow outer-race claim is made.

### 5. Pooled Error Metrics Will Be a Condition 3 Metric

Verdict: **merged**.

`docs/model/evaluation_protocol.md` now requires per-bearing rows, per-condition and per-mechanism reporting, absolute minute errors, normalized-by-lifetime errors and signed errors. Pooled MAE or RMSE is allowed only as a secondary summary.

### 6. Healthy Screen Rests on Provenance That Was Never Recorded

Verdict: **merged**.

The canonical compact mirror path no longer uses `healthy` in function names, script names, generated output paths or generated table labels. The replacement workflow is `computeCompactSnapshotScreen`, `screenCompactSnapshotCandidates` and `scripts/run_compact_snapshot_screen.m`, with outputs under `results/compact_snapshot_screen`.

### 7. Phase 1 Gate Says Stop, and Modelling Continued

Verdict: **merged**.

`docs/model/claim_boundaries.md` now states the data gate explicitly. Physics-only Simscape scaffolding, visualization, compact snapshot ingestion checks and documentation hardening may continue while the official lifecycle archive is blocked. RUL training, lifecycle validation and measured performance claims remain blocked.

### 8. Quantify the Accelerated-Life Caveat

Verdict: **merged**.

`docs/model/claim_boundaries.md` and `docs/data/source_ledger.csv` now record the Condition 1 load-to-static-rating ratio: 12 kN / 6.65 kN = about 1.80. Accelerated-test minutes cannot be translated into field-service years without a separately justified life model and application load spectrum.

### 9. Vault Wiring, Outside This Repo

Verdict: **merged in the vault, pending separate commit scope**.

The vault roadmap should be updated with the project path, current data gate and current implementation status after the repo-side changes are verified. This remains intentionally separate from MATLAB project verification.
