# XJTU-SY Data Access Audit

Date checked: 2026-09-10.

## Official source

Author page: https://biaowang.tech/xjtu-sy-bearing-datasets/

The author page states that XJTU-SY contains 15 complete rolling-element bearing run-to-failure records. The tested bearing is LDK UER204. Each raw sampling file contains two columns, horizontal and vertical acceleration, with 32,768 points sampled at 25.6 kHz. Sampling duration is 1.28 s and the sampling period is 1 min.

The geometry table and per-bearing lifecycle table from the author page were manually transcribed into `xjtu_sy_bearing_geometry.csv` and `xjtu_sy_lifecycle_manifest.csv`.

## Download attempts

- Google Drive mirror, `https://drive.google.com/uc?export=download&id=1_ycmG46PARiykt82ShfnFfyQsaXv3_VK`: scripted download returned HTTP 500.
- Google Drive usercontent mirror, `https://drive.usercontent.google.com/download?id=1_ycmG46PARiykt82ShfnFfyQsaXv3_VK&export=download&confirm=t`: scripted download returned HTTP 500.
- Dropbox mirror, `https://www.dropbox.com/sh/qka3b73wuvn5l7a/AADr6oXKbafhOlrBLCNgonzua?dl=0`: browser page reports the shared link was deleted or disabled. The scripted `dl=1` route downloaded an HTML error page, not a zip.
- Kaggle mirror, `https://www.kaggle.com/datasets/zhenxinchen/xjtu-sy`: API download succeeded and produced five Condition 1 CSV files. Downloaded zip SHA-256: `24192A478FB28CF68A1ACF06BB426018F170DFD6B72F0A87186111F11F2E80EA`. This mirror is not the full official per-minute lifecycle package; each extracted CSV has 32,768 rows and two vibration columns.

## Current data status

The project has enough downloaded data for a first vibration snapshot sanity plot. It does not yet have the official full lifecycle folder required for RUL training, validation, or lifecycle plots.

