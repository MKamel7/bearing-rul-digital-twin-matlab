%SUMMARIZE_OFFICIAL_LIFECYCLES Summarize all official XJTU-SY lifecycle folders.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

manifestPath = fullfile(projectRoot, "docs", "data", "xjtu_sy_lifecycle_manifest.csv");
rawRoot = fullfile(projectRoot, "data", "raw", "xjtu-sy-official", "XJTU-SY_Bearing_Datasets");
if ~isfolder(rawRoot)
    error("BearingRUL:OfficialRawRootMissing", "Official raw root not found: %s", rawRoot);
end

manifest = readtable(manifestPath, TextType="string");
outDir = fullfile(projectRoot, "results", "official_lifecycle");
perBearingDir = fullfile(outDir, "per_bearing");
if ~isfolder(perBearingDir)
    mkdir(perBearingDir);
end

allFeatures = table();
for idx = 1:height(manifest)
    bearingID = manifest.BearingID(idx);
    bearingOutPath = fullfile(perBearingDir, bearingID + "_lifecycle_features.csv");
    if isfile(bearingOutPath)
        bearingFeatures = readtable(bearingOutPath, TextType="string");
        if height(bearingFeatures) == manifest.FileCount(idx)
            fprintf("Using cached %s (%d rows)\n", bearingID, height(bearingFeatures));
            allFeatures = [allFeatures; bearingFeatures]; %#ok<AGROW>
            continue
        end
    end

    fprintf("Summarizing %s (%d snapshots)\n", bearingID, manifest.FileCount(idx));
    lifecycleDir = fullfile(rawRoot, manifest.RawRelativePath(idx));
    bearingSummary = summarizeXjtuSyLifecycleFolder(lifecycleDir, 25600, 32768);
    if height(bearingSummary) ~= manifest.FileCount(idx)
        error("BearingRUL:LifecycleFileCountMismatch", ...
            "Bearing %s has %d summarized snapshots, expected %d.", ...
            bearingID, height(bearingSummary), manifest.FileCount(idx));
    end

    bearingFeatures = addManifestMetadata(bearingSummary, manifest(idx, :));
    writetable(bearingFeatures, bearingOutPath);
    fprintf("Wrote %s\n", bearingOutPath);
    allFeatures = [allFeatures; bearingFeatures]; %#ok<AGROW>
end

outPath = fullfile(outDir, "all_bearings_lifecycle_features.csv");
writetable(allFeatures, outPath);

disp(groupcounts(allFeatures, ["ConditionID", "FailureLabel"]));
fprintf("Wrote %s\n", outPath);
fprintf("Summarized %d snapshot rows from %d bearings.\n", height(allFeatures), numel(unique(allFeatures.BearingID)));

function bearingFeatures = addManifestMetadata(bearingSummary, manifestRow)
rowCount = height(bearingSummary);
bearingSummary.BearingID = repmat(manifestRow.BearingID, rowCount, 1);
bearingSummary.ConditionID = repmat(manifestRow.ConditionID, rowCount, 1);
bearingSummary.SpeedRPM = repmat(manifestRow.SpeedRPM, rowCount, 1);
bearingSummary.LoadKN = repmat(manifestRow.LoadKN, rowCount, 1);
bearingSummary.FailureLabel = repmat(manifestRow.FailureLabel, rowCount, 1);
bearingSummary.Split = repmat(manifestRow.Split, rowCount, 1);

bearingFeatures = movevars(bearingSummary, ...
    ["BearingID", "ConditionID", "SpeedRPM", "LoadKN", "FailureLabel", "Split"], ...
    Before="SnapshotIndex");
end
