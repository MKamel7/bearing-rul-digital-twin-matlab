function features = extractEnvelopeBandFeatures(signal, sampleRateHz, faultFrequencies, bandHalfWidthHz)
%EXTRACTENVELOPEBANDFEATURES Envelope-spectrum energy around bearing fault bands.
arguments
    signal (:,1) double
    sampleRateHz (1,1) double {mustBePositive}
    faultFrequencies (1,1) struct
    bandHalfWidthHz (1,1) double {mustBePositive}
end

centered = signal - mean(signal, "omitnan");
envelope = abs(hilbert(centered));
envelope = envelope - mean(envelope, "omitnan");
sampleCount = numel(envelope);
window = hann(sampleCount, "periodic");
windowed = envelope .* window;
spectrum = abs(fft(windowed)).^2 / sum(window.^2);
frequencyHz = (0:floor(sampleCount/2))' * sampleRateHz / sampleCount;
powerSpectrum = spectrum(1:numel(frequencyHz));

[bpfoEnergy, bpfoPeakHz, bpfoPeakValue] = bandMetrics(frequencyHz, powerSpectrum, faultFrequencies.BPFO, bandHalfWidthHz);
[bpfiEnergy, bpfiPeakHz, bpfiPeakValue] = bandMetrics(frequencyHz, powerSpectrum, faultFrequencies.BPFI, bandHalfWidthHz);

features = struct();
features.FrequencyHz = frequencyHz;
features.EnvelopePower = powerSpectrum;
features.BPFOEnergy = bpfoEnergy;
features.BPFIEnergy = bpfiEnergy;
features.BPFOPeakHz = bpfoPeakHz;
features.BPFIPeakHz = bpfiPeakHz;
features.BPFOPeakValue = bpfoPeakValue;
features.BPFIPeakValue = bpfiPeakValue;
features.BPFOToBPFIRatio = bpfoEnergy / max(bpfiEnergy, eps);
end

function [energy, peakHz, peakValue] = bandMetrics(frequencyHz, powerSpectrum, centerHz, halfWidthHz)
    idx = frequencyHz >= centerHz - halfWidthHz & frequencyHz <= centerHz + halfWidthHz;
    if ~any(idx)
        energy = 0;
        peakHz = NaN;
        peakValue = 0;
        return;
    end
    bandFrequency = frequencyHz(idx);
    bandPower = powerSpectrum(idx);
    if numel(bandFrequency) == 1
        energy = bandPower;
    else
        energy = trapz(bandFrequency, bandPower);
    end
    [peakValue, peakIdx] = max(bandPower);
    peakHz = bandFrequency(peakIdx);
end
