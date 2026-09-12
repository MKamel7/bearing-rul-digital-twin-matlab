function screenedFeatures = computeCompactSnapshotScreen(snapshotFiles, sampleRateHz, faultFrequencies, expectedSampleCount, bpfoRatioRobustZLimit)
%COMPACTSNAPSHOTSCREEN Compute provenance-neutral compact snapshot features.
arguments
    snapshotFiles (:,1) string
    sampleRateHz (1,1) double {mustBePositive}
    faultFrequencies (1,1) struct
    expectedSampleCount (1,1) double {mustBeInteger, mustBePositive} = 32768
    bpfoRatioRobustZLimit (1,1) double {mustBePositive} = 3.5
end

fileCount = numel(snapshotFiles);
fileName = strings(fileCount, 1);
sampleCount = zeros(fileCount, 1);
durationSeconds = zeros(fileCount, 1);
horizontalRMS = zeros(fileCount, 1);
verticalRMS = zeros(fileCount, 1);
horizontalCrestFactor = zeros(fileCount, 1);
verticalCrestFactor = zeros(fileCount, 1);
bpfoEnergy = zeros(fileCount, 1);
bpfiEnergy = zeros(fileCount, 1);
bpfoToBpfiRatio = zeros(fileCount, 1);
dataValidityStatus = strings(fileCount, 1);
screeningLabelAssumption = repmat("compact snapshot baseline candidate", fileCount, 1);

for idx = 1:fileCount
    snapshot = readXjtuSySnapshot(snapshotFiles(idx), expectedSampleCount);
    summary = summarizeVibrationSnapshot(snapshot.Horizontal, snapshot.Vertical, sampleRateHz);
    envelope = extractEnvelopeBandFeatures(snapshot.Horizontal, sampleRateHz, faultFrequencies, 5);

    [~, name, ext] = fileparts(snapshotFiles(idx));
    fileName(idx) = name + ext;
    sampleCount(idx) = summary.SampleCount;
    durationSeconds(idx) = summary.DurationSeconds;
    horizontalRMS(idx) = summary.HorizontalRMS;
    verticalRMS(idx) = summary.VerticalRMS;
    horizontalCrestFactor(idx) = summary.HorizontalCrestFactor;
    verticalCrestFactor(idx) = summary.VerticalCrestFactor;
    bpfoEnergy(idx) = envelope.BPFOEnergy;
    bpfiEnergy(idx) = envelope.BPFIEnergy;
    bpfoToBpfiRatio(idx) = envelope.BPFOToBPFIRatio;
    dataValidityStatus(idx) = snapshot.ValidityStatus;
end

screenedFeatures = table(fileName, sampleCount, durationSeconds, horizontalRMS, verticalRMS, ...
    horizontalCrestFactor, verticalCrestFactor, bpfoEnergy, bpfiEnergy, bpfoToBpfiRatio, ...
    dataValidityStatus, screeningLabelAssumption, ...
    VariableNames=["FileName", "SampleCount", "DurationSeconds", "HorizontalRMS", "VerticalRMS", ...
    "HorizontalCrestFactor", "VerticalCrestFactor", "BPFOEnergy", "BPFIEnergy", "BPFOToBPFIRatio", ...
    "DataValidityStatus", "ScreeningLabelAssumption"]);
screenedFeatures = screenCompactSnapshotCandidates(screenedFeatures, bpfoRatioRobustZLimit);
end
