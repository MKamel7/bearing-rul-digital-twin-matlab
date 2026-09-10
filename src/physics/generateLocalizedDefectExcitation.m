function excitation = generateLocalizedDefectExcitation(sampleRateHz, durationSeconds, faultFrequencyHz, resonanceHz, decayRate)
%GENERATELOCALIZEDDEFECTEXCITATION Periodic impact plus damped resonance prototype.
arguments
    sampleRateHz (1,1) double {mustBePositive}
    durationSeconds (1,1) double {mustBePositive}
    faultFrequencyHz (1,1) double {mustBePositive}
    resonanceHz (1,1) double {mustBePositive}
    decayRate (1,1) double {mustBePositive}
end

sampleCount = round(sampleRateHz * durationSeconds);
timeSeconds = (0:sampleCount-1)' / sampleRateHz;
impulseTrain = zeros(sampleCount, 1);
impactTimes = 0:1/faultFrequencyHz:(durationSeconds - 1/sampleRateHz);
impactSamples = unique(round(impactTimes * sampleRateHz) + 1);
impactSamples = impactSamples(impactSamples >= 1 & impactSamples <= sampleCount);
impulseTrain(impactSamples) = 1;

responseTime = timeSeconds;
impulseResponse = exp(-decayRate * responseTime) .* sin(2*pi*resonanceHz*responseTime);
peak = max(abs(impulseResponse));
if peak > 0
    impulseResponse = impulseResponse / peak;
end
signal = conv(impulseTrain, impulseResponse, "same");

excitation = struct();
excitation.TimeSeconds = timeSeconds;
excitation.ImpulseTrain = impulseTrain;
excitation.Signal = signal;
excitation.FaultFrequencyHz = faultFrequencyHz;
excitation.ResonanceHz = resonanceHz;
excitation.DecayRate = decayRate;
end
