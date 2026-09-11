function snapshot = readXjtuSySnapshot(snapshotPath, expectedSampleCount)
%READXJTUSYSNAPSHOT Load and validate one two-channel XJTU-SY vibration file.
arguments
    snapshotPath (1,1) string
    expectedSampleCount (1,1) double {mustBeInteger, mustBePositive} = 32768
end

if ~isfile(snapshotPath)
    error("BearingRUL:SnapshotNotFound", "Snapshot file not found: %s", snapshotPath);
end

data = readtable(snapshotPath, TextType="string", VariableNamingRule="preserve");
required = ["Horizontal_vibration_signals", "Vertical_vibration_signals"];
if ~all(ismember(required, string(data.Properties.VariableNames)))
    error("BearingRUL:MissingSnapshotColumns", "Snapshot must contain horizontal and vertical vibration columns.");
end

horizontal = double(data.(required(1)));
vertical = double(data.(required(2)));

if numel(horizontal) ~= expectedSampleCount || numel(vertical) ~= expectedSampleCount
    error("BearingRUL:UnexpectedSampleCount", "Expected %d samples per channel, got %d horizontal and %d vertical.", expectedSampleCount, numel(horizontal), numel(vertical));
end

if any(~isfinite(horizontal)) || any(~isfinite(vertical))
    error("BearingRUL:NonFiniteSnapshotValues", "Snapshot contains NaN or Inf vibration values.");
end

snapshot = struct();
snapshot.SourceFile = snapshotPath;
snapshot.SampleCount = expectedSampleCount;
snapshot.Horizontal = horizontal(:);
snapshot.Vertical = vertical(:);
snapshot.ValidityStatus = "valid";
end
