classdef TestSnapshotFeatures < matlab.unittest.TestCase
    methods (Test)
        function summarizesTwoChannelSnapshot(testCase)
            horizontal = [1; -1; 1; -1];
            vertical = [2; -2; 2; -2];
            features = summarizeVibrationSnapshot(horizontal, vertical, 4);
            testCase.verifyEqual(features.SampleCount, 4);
            testCase.verifyEqual(features.DurationSeconds, 1);
            testCase.verifyEqual(features.HorizontalRMS, 1, AbsTol=1e-12);
            testCase.verifyEqual(features.VerticalRMS, 2, AbsTol=1e-12);
            testCase.verifyEqual(features.HorizontalCrestFactor, 1, AbsTol=1e-12);
            testCase.verifyEqual(features.VerticalCrestFactor, 1, AbsTol=1e-12);
        end
    end
end
