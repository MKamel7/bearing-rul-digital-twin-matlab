function summary = summarizeXjtuSyLifecycleFolder(lifecycleDir, sampleRateHz, expectedSampleCount)
%SUMMARIZEXJTUSYLIFECYCLEFOLDER Summarize one XJTU-SY bearing lifecycle folder.
arguments
    lifecycleDir (1,1) string
    sampleRateHz (1,1) double {mustBePositive}
    expectedSampleCount (1,1) double {mustBeInteger, mustBePositive} = 32768
end

if ~isfolder(lifecycleDir)
    error("BearingRUL:LifecycleFolderNotFound", "Lifecycle folder not found: %s", lifecycleDir);
end

files = dir(fullfile(lifecycleDir, "*.csv"));
if isempty(files)
    error("BearingRUL:LifecycleFolderEmpty", "No lifecycle CSV files found in %s", lifecycleDir);
end

snapshotIndex = zeros(numel(files), 1);
fileName = strings(numel(files), 1);
for idx = 1:numel(files)
    [~, stem] = fileparts(files(idx).name);
    numericIndex = str2double(stem);
    if ~isfinite(numericIndex) || fix(numericIndex) ~= numericIndex
        error("BearingRUL:UnexpectedLifecycleFileName", "Lifecycle file name is not a numeric index: %s", files(idx).name);
    end
    snapshotIndex(idx) = numericIndex;
    fileName(idx) = string(files(idx).name);
end

[snapshotIndex, order] = sort(snapshotIndex);
files = files(order);
fileName = fileName(order);

elapsedMinutes = snapshotIndex - 1;
horizontalRMS = zeros(numel(files), 1);
verticalRMS = zeros(numel(files), 1);
horizontalCrestFactor = zeros(numel(files), 1);
verticalCrestFactor = zeros(numel(files), 1);

for idx = 1:numel(files)
    snapshotPath = fullfile(files(idx).folder, files(idx).name);
    [horizontal, vertical] = readLifecycleMatrix(snapshotPath, expectedSampleCount);
    features = summarizeVibrationSnapshot(horizontal, vertical, sampleRateHz);
    horizontalRMS(idx) = features.HorizontalRMS;
    verticalRMS(idx) = features.VerticalRMS;
    horizontalCrestFactor(idx) = features.HorizontalCrestFactor;
    verticalCrestFactor(idx) = features.VerticalCrestFactor;
end

summary = table(snapshotIndex, elapsedMinutes, fileName, horizontalRMS, verticalRMS, ...
    horizontalCrestFactor, verticalCrestFactor, ...
    VariableNames=["SnapshotIndex", "ElapsedMinutes", "FileName", "HorizontalRMS", "VerticalRMS", ...
    "HorizontalCrestFactor", "VerticalCrestFactor"]);
end

function [horizontal, vertical] = readLifecycleMatrix(snapshotPath, expectedSampleCount)
data = readmatrix(snapshotPath, NumHeaderLines=1);
if size(data, 1) ~= expectedSampleCount || size(data, 2) ~= 2
    error("BearingRUL:UnexpectedSampleCount", ...
        "Expected %d samples and 2 vibration columns in %s, got %d rows and %d columns.", ...
        expectedSampleCount, snapshotPath, size(data, 1), size(data, 2));
end

horizontal = data(:, 1);
vertical = data(:, 2);
if any(~isfinite(horizontal)) || any(~isfinite(vertical))
    error("BearingRUL:NonFiniteSnapshotValues", "Snapshot contains NaN or Inf vibration values: %s", snapshotPath);
end
end
