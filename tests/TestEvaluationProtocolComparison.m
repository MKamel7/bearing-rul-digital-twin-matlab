classdef TestEvaluationProtocolComparison < matlab.unittest.TestCase
    methods (Test)
        function comparesOuterRacePilotAndConditionHeldOutRoutes(testCase)
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
            manifestPath = fullfile(projectRoot, "docs", "data", "xjtu_sy_lifecycle_manifest.csv");
            manifest = readtable(manifestPath, TextType="string");

            comparison = compareEvaluationProtocols(manifest, "outer race");

            testCase.verifyEqual(height(comparison), 2);
            testCase.verifyEqual(comparison.Protocol(1), "nested leave-one-bearing-out pilot");
            testCase.verifyEqual(comparison.Protocol(2), "condition-held-out stress test");
            testCase.verifyEqual(comparison.IndependentTargetBearings, [8; 8]);
            testCase.verifyEqual(comparison.DevelopmentFolds, [8; 3]);
            testCase.verifyEqual(comparison.MinimumHeldOutBearings, [1; 2]);
            testCase.verifyEqual(comparison.CurrentManifestFinalTestBearings, [1; 1]);
            testCase.verifyGreaterThan(comparison.LifetimeRangeRatio(1), 60);
            testCase.verifyFalse(comparison.TestsRegimeTransfer(1));
            testCase.verifyTrue(comparison.TestsRegimeTransfer(2));
            testCase.verifyEqual(comparison.BestFitRank, [1; 2]);
        end
    end
end
