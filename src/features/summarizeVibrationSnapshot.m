function features = summarizeVibrationSnapshot(horizontal, vertical, sampleRateHz)
%SUMMARIZEVIBRATIONSNAPSHOT Compute basic two-channel vibration statistics.
arguments
    horizontal (:,1) double
    vertical (:,1) double
    sampleRateHz (1,1) double {mustBePositive}
end

if numel(horizontal) ~= numel(vertical)
    error("BearingRUL:ChannelLengthMismatch", "Horizontal and vertical channels must have the same number of samples.");
end

sampleCount = numel(horizontal);
features = struct();
features.SampleCount = sampleCount;
features.DurationSeconds = sampleCount / sampleRateHz;
features.HorizontalRMS = rms(horizontal);
features.VerticalRMS = rms(vertical);
features.HorizontalPeakAbs = max(abs(horizontal));
features.VerticalPeakAbs = max(abs(vertical));
features.HorizontalCrestFactor = features.HorizontalPeakAbs / features.HorizontalRMS;
features.VerticalCrestFactor = features.VerticalPeakAbs / features.VerticalRMS;
end
