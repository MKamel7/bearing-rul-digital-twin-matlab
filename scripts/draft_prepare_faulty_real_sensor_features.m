%DRAFT_PREPARE_FAULTY_REAL_SENSOR_FEATURES
% Review-only draft. Do not run until Mo reviews and approves.
%
% Purpose:
%   Prepare fault-indicated feature rows from real compact XJTU-SY sensor CSVs.
%   This script reads actual horizontal/vertical vibration snapshots, joins the
%   audited manifest labels and computes the same causal snapshot features used
%   in the compact snapshot screen.
%
% Guardrails:
%   - No synthetic data.
%   - No RUL claims.
%   - No lifecycle concatenation.
%   - Failure labels are joined for reporting only, not for threshold fitting.

projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

rawDir = fullfile(projectRoot, "data", "raw", "kaggle-condition1");
manifestPath = fullfile(projectRoot, "docs", "data", "xjtu_sy_lifecycle_manifest.csv");
geometryPath = fullfile(projectRoot, "docs", "data", "xjtu_sy_bearing_geometry.csv");

manifest = readtable(manifestPath, TextType="string");
geometry = readBearingGeometry(geometryPath);
frequencies = calculateBearingFaultFrequencies(geometry, 2100);

files = dir(fullfile(rawDir, "Bearing 1_*.csv"));
if isempty(files)
    error("BearingRUL:CompactMirrorMissing", "No compact mirror CSV files found in %s", rawDir);
end

snapshotFiles = strings(numel(files), 1);
for idx = 1:numel(files)
    snapshotFiles(idx) = fullfile(files(idx).folder, files(idx).name);
end

features = computeCompactSnapshotScreen(snapshotFiles, 25600, frequencies, 32768);
features.BearingID = normalizeCompactBearingFileName(features.FileName);

manifestSubset = manifest(manifest.ConditionID == 1, ["BearingID", "FaultElement", "FailureLabel", "Split", "FileCount", "LifetimeMinutes"]);
faultRows = outerjoin(features, manifestSubset, Keys="BearingID", MergeKeys=true, Type="left");
faultRows.AnalysisRole = repmat("fault-indicated compact sensor snapshot", height(faultRows), 1);
faultRows.LabelUse = repmat("reporting only, not threshold fitting", height(faultRows), 1);

outDir = fullfile(projectRoot, "results", "faulty_review");
if ~isfolder(outDir)
    mkdir(outDir);
end
writetable(faultRows, fullfile(outDir, "condition1_fault_indicated_real_sensor_features.csv"));

disp(faultRows);
fprintf("Wrote %s\n", fullfile(outDir, "condition1_fault_indicated_real_sensor_features.csv"));

function bearingId = normalizeCompactBearingFileName(fileName)
    bearingId = erase(string(fileName), ".csv");
    bearingId = strtrim(bearingId);
    bearingId = replace(bearingId, " ", "");
end
