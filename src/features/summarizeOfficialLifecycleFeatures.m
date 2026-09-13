function features = summarizeOfficialLifecycleFeatures(manifest, rawRoot, sampleRateHz, expectedSampleCount)
%SUMMARIZEOFFICIALLIFECYCLEFEATURES Summarize all manifest lifecycles.
arguments
    manifest table
    rawRoot (1,1) string
    sampleRateHz (1,1) double {mustBePositive} = 25600
    expectedSampleCount (1,1) double {mustBeInteger, mustBePositive} = 32768
end

requiredColumns = ["BearingID", "ConditionID", "SpeedRPM", "LoadKN", "FailureLabel", ...
    "Split", "FileCount", "RawRelativePath"];
missingColumns = setdiff(requiredColumns, string(manifest.Properties.VariableNames));
if ~isempty(missingColumns)
    error("BearingRUL:MissingManifestColumns", ...
        "Manifest is missing required lifecycle feature columns: %s", strjoin(missingColumns, ", "));
end

features = table();
for idx = 1:height(manifest)
    lifecycleDir = fullfile(rawRoot, manifest.RawRelativePath(idx));
    bearingSummary = summarizeXjtuSyLifecycleFolder(lifecycleDir, sampleRateHz, expectedSampleCount);
    if height(bearingSummary) ~= manifest.FileCount(idx)
        error("BearingRUL:LifecycleFileCountMismatch", ...
            "Bearing %s has %d summarized snapshots, expected %d.", ...
            manifest.BearingID(idx), height(bearingSummary), manifest.FileCount(idx));
    end

    rowCount = height(bearingSummary);
    bearingSummary.BearingID = repmat(manifest.BearingID(idx), rowCount, 1);
    bearingSummary.ConditionID = repmat(manifest.ConditionID(idx), rowCount, 1);
    bearingSummary.SpeedRPM = repmat(manifest.SpeedRPM(idx), rowCount, 1);
    bearingSummary.LoadKN = repmat(manifest.LoadKN(idx), rowCount, 1);
    bearingSummary.FailureLabel = repmat(manifest.FailureLabel(idx), rowCount, 1);
    bearingSummary.Split = repmat(manifest.Split(idx), rowCount, 1);

    bearingSummary = movevars(bearingSummary, ...
        ["BearingID", "ConditionID", "SpeedRPM", "LoadKN", "FailureLabel", "Split"], ...
        Before="SnapshotIndex");
    features = [features; bearingSummary]; %#ok<AGROW>
end
end
