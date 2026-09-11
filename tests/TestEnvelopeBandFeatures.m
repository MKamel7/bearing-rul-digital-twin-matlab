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

        function reportsCageAndBallBands(testCase)
            sampleRateHz = 4096;
            durationSeconds = 2;
            t = (0:1/sampleRateHz:durationSeconds-1/sampleRateHz)';
            carrierHz = 900;
            faultFrequencies = struct("ShaftHz", 35, "FTF", 13.5, "BPFO", 108, "BPFI", 172, "BSF", 72);
            signal = (1 + 0.35*sin(2*pi*faultFrequencies.FTF*t) + 0.45*sin(2*pi*2*faultFrequencies.BSF*t)) .* sin(2*pi*carrierHz*t);

            features = extractEnvelopeBandFeatures(signal, sampleRateHz, faultFrequencies, 5);

            testCase.verifyTrue(any(features.Bands.BandName == "FTF"));
            testCase.verifyTrue(any(features.Bands.BandName == "Ball2BSF"));
            testCase.verifyGreaterThan(features.FTFEnergy, 0);
            testCase.verifyGreaterThan(features.Ball2BSFEnergy, 0);
        end

        function supportsKurtogramDemodulationBand(testCase)
            sampleRateHz = 4096;
            durationSeconds = 2;
            t = (0:1/sampleRateHz:durationSeconds-1/sampleRateHz)';
            bpfoHz = 107.9074;
            bpfiHz = 172.0926;
            carrierHz = 1200;
            signal = 0.2*sin(2*pi*60*t) + (1 + 0.4*sin(2*pi*bpfoHz*t)) .* sin(2*pi*carrierHz*t);

            features = extractEnvelopeBandFeatures(signal, sampleRateHz, struct("ShaftHz", 35, "FTF", 13.5, "BPFO", bpfoHz, "BPFI", bpfiHz, "BSF", 72), 5, DemodulationMethod="kurtogram");

            testCase.verifyEqual(features.DemodulationMethod, "kurtogram");
            testCase.verifyTrue(all(isfinite(features.DemodulationBandHz)));
            testCase.verifyEqual(numel(features.DemodulationBandHz), 2);
            testCase.verifyGreaterThan(features.DemodulationBandHz(2), features.DemodulationBandHz(1));
        end
    end
end
