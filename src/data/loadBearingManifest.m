function manifest = loadBearingManifest(manifestPath, rawRoot)
%LOADBEARINGMANIFEST Read and validate the XJTU-SY lifecycle manifest.
arguments
    manifestPath (1,1) string
    rawRoot (1,1) string
end

requiredColumns = ["BearingID", "ConditionID", "SpeedRPM", "LoadKN", "SampleRateHz", "SnapshotSeconds", "SnapshotPeriodSeconds", "ChannelCount", "FailureLabel", "Split", "RawRelativePath"];

if ~isfile(manifestPath)
    error("BearingRUL:ManifestNotFound", "Manifest file not found: %s", manifestPath);
end

manifest = readtable(manifestPath, TextType="string");
missingColumns = setdiff(requiredColumns, string(manifest.Properties.VariableNames));
if ~isempty(missingColumns)
    error("BearingRUL:MissingManifestColumns", "Manifest is missing required columns: %s", strjoin(missingColumns, ", "));
end

rawPaths = fullfile(rawRoot, manifest.RawRelativePath);
manifest.RawFileExists = arrayfun(@(p) isfile(p) || isfolder(p), rawPaths);
end
