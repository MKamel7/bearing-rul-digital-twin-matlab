classdef TestCompactSnapshotFeatures < matlab.unittest.TestCase
    methods (Test)
        function producesFeatureRowsForCompactSnapshots(testCase)
            sampleRateHz = 1024;
            sampleCount = 1024;
            t = (0:sampleCount-1)' / sampleRateHz;
            bpfoHz = 100;
            bpfiHz = 160;
            snapshotFiles = strings(2, 1);
            snapshotFiles(1) = testCase.writeSnapshot("snapshot_a.csv", sin(2*pi*30*t), 0.5*cos(2*pi*30*t));
            snapshotFiles(2) = testCase.writeSnapshot("snapshot_b.csv", 0.8*sin(2*pi*45*t), 0.4*cos(2*pi*45*t));

            features = computeCompactSnapshotScreen(snapshotFiles, sampleRateHz, struct("BPFO", bpfoHz, "BPFI", bpfiHz), sampleCount);

            testCase.verifyEqual(height(features), 2);
            testCase.verifyEqual(features.SampleCount', [sampleCount sampleCount]);
            testCase.verifyTrue(all(features.DataValidityStatus == "valid"));
            testCase.verifyFalse(ismember("HealthLabelAssumption", string(features.Properties.VariableNames)));
            testCase.verifyTrue(all(features.ScreeningLabelAssumption == "compact snapshot baseline candidate"));
            testCase.verifyTrue(all(isfinite(features.HorizontalRMS)));
            testCase.verifyTrue(all(isfinite(features.BPFOToBPFIRatio)));
        end
    end

    methods (Access = private)
        function snapshotPath = writeSnapshot(testCase, fileName, horizontal, vertical)
            tmpDir = string(testCase.createTemporaryFolder());
            snapshotPath = fullfile(tmpDir, fileName);
            data = table(horizontal(:), vertical(:), VariableNames=["Horizontal_vibration_signals", "Vertical_vibration_signals"]);
            writetable(data, snapshotPath);
        end
    end
end
