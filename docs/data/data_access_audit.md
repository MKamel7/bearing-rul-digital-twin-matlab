# XJTU-SY Data Access Audit

Date checked: 2026-09-10. Updated: 2026-09-13.

## Official source

Author page: https://biaowang.tech/xjtu-sy-bearing-datasets/

The author page states that XJTU-SY contains 15 complete rolling-element bearing run-to-failure records. The tested bearing is LDK UER204. Each raw sampling file contains two columns, horizontal and vertical acceleration, with 32,768 points sampled at 25.6 kHz. Sampling duration is 1.28 s and the sampling period is 1 min.

The geometry table and per-bearing lifecycle table from the author page were manually transcribed into `xjtu_sy_bearing_geometry.csv` and `xjtu_sy_lifecycle_manifest.csv`.

## Download attempts

- Author GitHub README, `https://github.com/WangBiaoXJTU/xjtu-sy-bearing-datasets`: loaded on 2026-09-11 and confirmed the official source list includes the author website, Google Drive, Dropbox, MediaFire, MEGA and Baidu Netdisk. The MediaFire link file also lists Tencent Weiyun as an additional mirror.
- Google Drive mirror, `https://drive.google.com/uc?export=download&id=1_ycmG46PARiykt82ShfnFfyQsaXv3_VK`: scripted download returned HTTP 500.
- Google Drive usercontent mirror, `https://drive.usercontent.google.com/download?id=1_ycmG46PARiykt82ShfnFfyQsaXv3_VK&export=download&confirm=t`: scripted download returned HTTP 500.
- Dropbox mirror, `https://www.dropbox.com/sh/qka3b73wuvn5l7a/AADr6oXKbafhOlrBLCNgonzua?dl=0`: browser page reports the shared link was deleted or disabled. The scripted `dl=1` route downloaded an HTML error page, not a zip.
- MediaFire mirror, `http://www.mediafire.com/folder/m3sij67rizpb4/XJTU-SY_Bearing_Datasets`: probed on 2026-09-11. The public folder API loaded successfully. Its `Data` subfolder lists six RAR parts for `XJTU-SY_Bearing_Datasets`, totaling 4,444,600,440 bytes, plus two note files. The six archive parts were downloaded on 2026-09-13 to `data/raw/downloads/mediafire-official`, verified by SHA-256 and extracted with 7-Zip to `data/raw/xjtu-sy-official/XJTU-SY_Bearing_Datasets`. The 7-Zip archive test and extraction both reported `Everything is Ok` with a warning that there is data after the end of the first archive volume. The verified archive hashes are recorded in `xjtu_sy_official_mediafire_parts.csv`.
- MEGA mirror, `https://mega.nz/#F!H7pnGKBK!PR8qUShaLlJjwrPf3SlBjw`: probed on 2026-09-11. The URL returned a generic MEGA HTML shell; no archive contents were enumerated by the scripted request because the folder key is handled client-side.
- Baidu Netdisk mirror, `https://pan.baidu.com/s/1OaY82azTXHBwjiCjA_jRcw`: probed on 2026-09-11. The share page loaded with title `XJTU-SY_Bearing_Datasets`; no archive was downloaded in this pass.
- Tencent Weiyun mirror, `https://share.weiyun.com/5zLCgBL`: discovered from the official MediaFire link file and probed on 2026-09-11. The share page returned HTTP 200 HTML; no archive was downloaded in this pass.
- Kaggle mirror, `https://www.kaggle.com/datasets/zhenxinchen/xjtu-sy`: API download succeeded and produced five Condition 1 CSV files. Downloaded zip SHA-256: `24192A478FB28CF68A1ACF06BB426018F170DFD6B72F0A87186111F11F2E80EA`. This mirror is not the full official per-minute lifecycle package; each extracted CSV has 32,768 rows and two vibration columns.

## Current data status

The project now has the official full lifecycle folder extracted locally. The extraction contains 9,217 files totaling 12,220,812,451 bytes. Of these, 9,216 are lifecycle CSV snapshots in the 15 bearing folders, and the per-bearing file counts match `xjtu_sy_lifecycle_manifest.csv`. The file-count audit is recorded in `xjtu_sy_official_extract_audit.csv`.

The first full-lifecycle sanity plot was generated for `Bearing1_1`: 123 snapshots from elapsed minute 0 to 122. Output files are ignored artifacts under `results/official_lifecycle/Bearing1_1_lifecycle_summary.csv` and `results/figures/Bearing1_1_official_lifecycle_trend.png`.

The data-access gate has passed. RUL modeling is still gated by the evaluation protocol: training-only preprocessing, manifest-derived fold assignments, no final-test tuning and no public performance claim before evaluation is complete.

