classdef TestOfficialLifecycleFeatureTable < matlab.unittest.TestCase
    methods (Test)
        function combinesManifestMetadataWithLifecycleSummaries(testCase)
            rawRoot = string(testCase.createTemporaryFolder());
            testCase.writeSnapshot(fullfile(rawRoot, "condA", "BearingA"), "1.csv", [1; 0; 0; 0], [0; 2; 0; 0]);
            testCase.writeSnapshot(fullfile(rawRoot, "condA", "BearingA"), "2.csv", [0; 2; 0; 0], [0; 0; 4; 0]);
            testCase.writeSnapshot(fullfile(rawRoot, "condB", "BearingB"), "1.csv", [3; 4; 0; 0], [0; 0; 6; 8]);

            manifest = table(["BearingA"; "BearingB"], [1; 2], [2100; 2250], [12; 11], ...
                ["outer race"; "inner race"], ["train"; "validation"], [2; 1], ...
                ["condA/BearingA"; "condB/BearingB"], ...
                VariableNames=["BearingID", "ConditionID", "SpeedRPM", "LoadKN", "FailureLabel", ...
                "Split", "FileCount", "RawRelativePath"]);

            features = summarizeOfficialLifecycleFeatures(manifest, rawRoot, 4, 4);

            testCase.verifyEqual(height(features), 3);
            testCase.verifyEqual(features.BearingID', ["BearingA" "BearingA" "BearingB"]);
            testCase.verifyEqual(features.SnapshotIndex', [1 2 1]);
            testCase.verifyEqual(features.ElapsedMinutes', [0 1 0]);
            testCase.verifyEqual(features.ConditionID', [1 1 2]);
            testCase.verifyEqual(features.FailureLabel', ["outer race" "outer race" "inner race"]);
            testCase.verifyEqual(features.HorizontalRMS', [0.5 1.0 2.5], AbsTol=1e-12);
        end
    end

    methods (Access = private)
        function writeSnapshot(~, lifecycleDir, fileName, horizontal, vertical)
            if ~isfolder(lifecycleDir)
                mkdir(lifecycleDir);
            end
            data = table(horizontal(:), vertical(:), VariableNames=["Horizontal_vibration_signals", "Vertical_vibration_signals"]);
            writetable(data, fullfile(lifecycleDir, fileName));
        end
    end
end
