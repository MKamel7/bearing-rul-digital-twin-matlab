classdef TestEnvelopeBandFeatures < matlab.unittest.TestCase
    methods (Test)
        function detectsInjectedBpfoEnvelopeEnergy(testCase)
            sampleRateHz = 4096;
            durationSeconds = 2;
            t = (0:1/sampleRateHz:durationSeconds-1/sampleRateHz)';
            carrierHz = 800;
            bpfoHz = 107.9074;
            bpfiHz = 172.0926;
            signal = (1 + 0.55 * sin(2*pi*bpfoHz*t)) .* sin(2*pi*carrierHz*t);
            features = extractEnvelopeBandFeatures(signal, sampleRateHz, struct("BPFO", bpfoHz, "BPFI", bpfiHz), 5);
            testCase.verifyGreaterThan(features.BPFOEnergy, 20 * features.BPFIEnergy);
            testCase.verifyEqual(features.BPFOPeakHz, bpfoHz, AbsTol=1.0);
            testCase.verifyGreaterThan(features.BPFOToBPFIRatio, 20);
        end
    end
end
