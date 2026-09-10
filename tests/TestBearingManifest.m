classdef TestBearingManifest < matlab.unittest.TestCase
    methods (Test)
        function manifestHasRequiredColumns(testCase)
            [manifestPath, rawRoot] = testCase.projectPaths();
            manifest = loadBearingManifest(manifestPath, rawRoot);
            required = ["BearingID", "ConditionID", "SpeedRPM", "LoadKN", "SampleRateHz", "SnapshotSeconds", "SnapshotPeriodSeconds", "ChannelCount", "FailureLabel", "Split", "RawRelativePath", "RawFileExists"];
            testCase.verifyTrue(all(ismember(required, string(manifest.Properties.VariableNames))));
        end

        function manifestPreservesKnownOperatingConditions(testCase)
            [manifestPath, rawRoot] = testCase.projectPaths();
            manifest = loadBearingManifest(manifestPath, rawRoot);
            testCase.verifyEqual(height(manifest), 15);
            testCase.verifyEqual(unique(manifest.SpeedRPM)', [2100 2250 2400]);
            testCase.verifyEqual(unique(manifest.LoadKN)', [10 11 12]);
            testCase.verifyEqual(unique(manifest.SampleRateHz), 25600);
            testCase.verifyEqual(unique(manifest.SnapshotSeconds), 1.28);
            testCase.verifyEqual(unique(manifest.SnapshotPeriodSeconds), 60);
        end

        function missingRawDataIsVisible(testCase)
            [manifestPath, rawRoot] = testCase.projectPaths();
            manifest = loadBearingManifest(manifestPath, rawRoot);
            testCase.verifyClass(manifest.RawFileExists, "logical");
            testCase.verifyFalse(any(manifest.RawFileExists), "Before dataset download, no raw lifecycle files should be silently treated as present.");
        end
    end

    methods (Access = private)
        function [manifestPath, rawRoot] = projectPaths(testCase)
            testFile = string(which(class(testCase)));
            testsDir = fileparts(testFile);
            projectRoot = fileparts(testsDir);
            manifestPath = fullfile(projectRoot, "docs", "data", "xjtu_sy_lifecycle_manifest.csv");
            rawRoot = fullfile(projectRoot, "data", "raw", "xjtu-sy");
        end
    end
end
