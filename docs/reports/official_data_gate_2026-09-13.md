# Official Data Gate Result

Date: 2026-09-13

## Result

The official XJTU-SY lifecycle archive is now downloaded, verified and extracted locally.

Downloaded archive parts:

- six MediaFire RAR volumes
- total compressed size: 4,444,600,440 bytes
- each part verified by SHA-256 against the MediaFire API hashes recorded in `docs/data/xjtu_sy_official_mediafire_parts.csv`

Extraction:

- tool: 7-Zip 24.08
- extracted root: `data/raw/xjtu-sy-official/XJTU-SY_Bearing_Datasets`
- extracted files: 9,217
- extracted bytes: 12,220,812,451
- lifecycle CSV files: 9,216
- per-bearing file counts match `docs/data/xjtu_sy_lifecycle_manifest.csv`

7-Zip reported `Everything is Ok` during archive test and extraction. It also reported a warning that there is data after the end of the first archive volume. The extracted lifecycle folder counts match the manifest, so the warning is recorded but not treated as a failed extraction.

## First Lifecycle Sanity Plot

`scripts/plot_official_lifecycle_trend.m` was run for `Bearing1_1`.

Generated ignored artifacts:

- `results/official_lifecycle/Bearing1_1_lifecycle_summary.csv`
- `results/figures/Bearing1_1_official_lifecycle_trend.png`

The plot covers 123 snapshots from elapsed minute 0 to 122. The RMS trend is stable early, rises around minute 78 and spikes near the documented end of life. This is a data-access and plotting sanity check, not an RUL model result.

## Gate Decision

The data-access gate has passed.

The project may proceed to measured lifecycle feature extraction and protocol-bound development. It still must not make RUL performance claims until preprocessing, folds, model choices and metrics are frozen and evaluated according to `docs/model/evaluation_protocol.md`.
