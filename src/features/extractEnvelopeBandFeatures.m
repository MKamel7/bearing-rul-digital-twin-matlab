function features = extractEnvelopeBandFeatures(signal, sampleRateHz, faultFrequencies, bandHalfWidthHz, options)
%EXTRACTENVELOPEBANDFEATURES Envelope-spectrum energy around bearing fault bands.
arguments
    signal (:,1) double
    sampleRateHz (1,1) double {mustBePositive}
    faultFrequencies (1,1) struct
    bandHalfWidthHz (1,1) double {mustBePositive}
    options.DemodulationMethod (1,1) string {mustBeMember(options.DemodulationMethod, ["broadband", "kurtogram", "bandpass"])} = "broadband"
    options.DemodulationBandHz (1,2) double = [NaN NaN]
    options.KurtogramLevel (1,1) double {mustBeInteger, mustBePositive} = 4
    options.FilterOrder (1,1) double {mustBeInteger, mustBePositive} = 50
end

centered = signal - mean(signal, "omitnan");
[frequencyHz, powerSpectrum, envelope, demodulationBandHz] = envelopeSpectrum(centered, sampleRateHz, options);

bands = buildBearingFaultBandTable(faultFrequencies);
bandEnergy = zeros(height(bands), 1);
bandPeakHz = zeros(height(bands), 1);
bandPeakValue = zeros(height(bands), 1);
for idx = 1:height(bands)
    [bandEnergy(idx), bandPeakHz(idx), bandPeakValue(idx)] = bandMetrics(frequencyHz, powerSpectrum, bands.CenterHz(idx), bandHalfWidthHz);
end
bands.Energy = bandEnergy;
bands.PeakHz = bandPeakHz;
bands.PeakValue = bandPeakValue;

features = struct();
features.FrequencyHz = frequencyHz;
features.EnvelopePower = powerSpectrum;
features.EnvelopeSignal = envelope;
features.DemodulationMethod = options.DemodulationMethod;
features.DemodulationBandHz = demodulationBandHz;
features.Bands = bands;

for idx = 1:height(bands)
    fieldStem = matlab.lang.makeValidName(bands.BandName(idx));
    features.(fieldStem + "Energy") = bands.Energy(idx);
    features.(fieldStem + "PeakHz") = bands.PeakHz(idx);
    features.(fieldStem + "PeakValue") = bands.PeakValue(idx);
end

features.BPFOToBPFIRatio = features.BPFOEnergy / max(features.BPFIEnergy, eps);
end

function [frequencyHz, powerSpectrum, envelope, demodulationBandHz] = envelopeSpectrum(centered, sampleRateHz, options)
    switch options.DemodulationMethod
        case "broadband"
            envelope = abs(hilbert(centered));
            envelope = envelope - mean(envelope, "omitnan");
            sampleCount = numel(envelope);
            window = hann(sampleCount, "periodic");
            windowed = envelope .* window;
            spectrum = abs(fft(windowed)).^2 / sum(window.^2);
            frequencyHz = (0:floor(sampleCount/2))' * sampleRateHz / sampleCount;
            powerSpectrum = spectrum(1:numel(frequencyHz));
            demodulationBandHz = [0 sampleRateHz/2];
        case "kurtogram"
            [~, ~, ~, centerHz, ~, bandwidthHz] = kurtogram(centered, sampleRateHz, options.KurtogramLevel);
            demodulationBandHz = sanitizeBand([centerHz - bandwidthHz/2, centerHz + bandwidthHz/2], sampleRateHz);
            [powerSpectrum, frequencyHz, envelope] = envspectrum(centered, sampleRateHz, Method="hilbert", Band=demodulationBandHz, FilterOrder=options.FilterOrder);
        case "bandpass"
            demodulationBandHz = sanitizeBand(options.DemodulationBandHz, sampleRateHz);
            [powerSpectrum, frequencyHz, envelope] = envspectrum(centered, sampleRateHz, Method="hilbert", Band=demodulationBandHz, FilterOrder=options.FilterOrder);
    end
    frequencyHz = frequencyHz(:);
    powerSpectrum = powerSpectrum(:);
    envelope = envelope(:);
end

function bandHz = sanitizeBand(bandHz, sampleRateHz)
    if any(~isfinite(bandHz)) || bandHz(2) <= bandHz(1)
        bandHz = [sampleRateHz/4, 3*sampleRateHz/8];
    end
    nyquist = sampleRateHz / 2;
    bandHz(1) = max(1, bandHz(1));
    bandHz(2) = min(nyquist - 1, bandHz(2));
    if bandHz(2) <= bandHz(1)
        bandHz = [max(1, nyquist/4), max(2, nyquist/2)];
    end
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
    if isscalar(bandFrequency)
        energy = bandPower;
    else
        energy = trapz(bandFrequency, bandPower);
    end
    [peakValue, peakIdx] = max(bandPower);
    peakHz = bandFrequency(peakIdx);
end
