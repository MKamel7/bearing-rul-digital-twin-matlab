classdef TestEvaluationFoldAssignments < matlab.unittest.TestCase
    methods (Test)
        function buildsNestedLeaveOneBearingOutOuterRaceFolds(testCase)
            manifest = testCase.loadManifest();

            folds = buildEvaluationFolds(manifest, "outer race", "nested leave-one-bearing-out pilot");

            testCase.verifyEqual(height(folds), 64);
            testCase.verifyEqual(numel(unique(folds.FoldID)), 8);
            testCase.verifyEqual(numel(unique(folds.BearingID)), 8);

            for foldID = unique(folds.FoldID)'
                foldRows = folds(folds.FoldID == foldID, :);
                testCase.verifyEqual(nnz(foldRows.Role == "heldout"), 1);
                testCase.verifyEqual(nnz(foldRows.Role == "train"), 7);
                testCase.verifyEqual(numel(unique(foldRows.ConditionID(foldRows.Role == "train"))), 3);
            end
        end

        function buildsConditionHeldOutOuterRaceFolds(testCase)
            manifest = testCase.loadManifest();

            folds = buildEvaluationFolds(manifest, "outer race", "condition-held-out stress test");

            testCase.verifyEqual(numel(unique(folds.FoldID)), 3);
            for foldID = unique(folds.FoldID)'
                foldRows = folds(folds.FoldID == foldID, :);
                heldoutCondition = unique(foldRows.ConditionID(foldRows.Role == "heldout"));
                trainingCondition = unique(foldRows.ConditionID(foldRows.Role == "train"));

                testCase.verifyEqual(numel(heldoutCondition), 1);
                testCase.verifyGreaterThanOrEqual(nnz(foldRows.Role == "heldout"), 2);
                testCase.verifyFalse(any(trainingCondition == heldoutCondition));
            end
        end
    end

    methods (Access = private)
        function manifest = loadManifest(testCase)
            testFile = string(which(class(testCase)));
            projectRoot = fileparts(fileparts(testFile));
            manifestPath = fullfile(projectRoot, "docs", "data", "xjtu_sy_lifecycle_manifest.csv");
            manifest = readtable(manifestPath, TextType="string");
        end
    end
end
