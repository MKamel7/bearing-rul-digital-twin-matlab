classdef TestFeatureSimilarityRulModel < matlab.unittest.TestCase
    methods (Test)
        function predictsHeldoutRulFromNearestTrainingSnapshots(testCase)
            features = makeFeatureTable();
            folds = table( ...
                [1; 1; 1], ...
                repmat("nested leave-one-bearing-out pilot", 3, 1), ...
                ["TrainA"; "TrainC"; "HeldB"], ...
                ["train"; "train"; "heldout"], ...
                VariableNames=["FoldID", "Protocol", "BearingID", "Role"]);

            predictions = evaluateFeatureSimilarityRulModel(features, folds, ...
                ["HorizontalRMS", "VerticalRMS"], NeighborCount=1);

            testCase.verifyEqual(height(predictions), 3);
            testCase.verifyEqual(predictions.BearingID, repmat("HeldB", 3, 1));
            testCase.verifyEqual(predictions.ActualRULMinutes', [2 1 0]);
            testCase.verifyEqual(predictions.PredictedRULMinutes', [3 2 0]);
            testCase.verifyEqual(predictions.AbsoluteErrorMinutes', [1 1 0]);
        end

        function usesTrainingFeatureScalingOnly(testCase)
            features = makeFeatureTable();
            features.HorizontalRMS(features.BearingID == "HeldB") = [1000; 1001; 1002];
            features.VerticalRMS(features.BearingID == "HeldB") = [1000; 1001; 1002];
            folds = table( ...
                [1; 1; 1], ...
                repmat("nested leave-one-bearing-out pilot", 3, 1), ...
                ["TrainA"; "TrainC"; "HeldB"], ...
                ["train"; "train"; "heldout"], ...
                VariableNames=["FoldID", "Protocol", "BearingID", "Role"]);

            predictions = evaluateFeatureSimilarityRulModel(features, folds, ...
                ["HorizontalRMS", "VerticalRMS"], NeighborCount=1);

            testCase.verifyEqual(predictions.PredictedRULMinutes', [0 0 0]);
        end

        function rejectsMissingFeatureColumns(testCase)
            features = makeFeatureTable();
            features.VerticalRMS = [];
            folds = table( ...
                [1; 1], ...
                repmat("nested leave-one-bearing-out pilot", 2, 1), ...
                ["TrainA"; "HeldB"], ...
                ["train"; "heldout"], ...
                VariableNames=["FoldID", "Protocol", "BearingID", "Role"]);

            testCase.verifyError(@() evaluateFeatureSimilarityRulModel(features, folds, ...
                ["HorizontalRMS", "VerticalRMS"]), "BearingRUL:MissingFeatureColumns");
        end
    end
end

function features = makeFeatureTable()
bearingID = ["TrainA"; "TrainA"; "TrainA"; "TrainA"; "TrainC"; "TrainC"; "TrainC"; "HeldB"; "HeldB"; "HeldB"];
conditionID = ones(10, 1);
failureLabel = repmat("outer race", 10, 1);
snapshotIndex = [1; 2; 3; 4; 1; 2; 3; 1; 2; 3];
elapsedMinutes = snapshotIndex - 1;
horizontalRMS = [0; 1; 2; 3; 10; 11; 12; 0; 1; 12];
verticalRMS = horizontalRMS;
horizontalCrestFactor = ones(10, 1);
verticalCrestFactor = ones(10, 1);

features = table(bearingID, conditionID, failureLabel, snapshotIndex, elapsedMinutes, ...
    horizontalRMS, verticalRMS, horizontalCrestFactor, verticalCrestFactor, ...
    VariableNames=["BearingID", "ConditionID", "FailureLabel", "SnapshotIndex", "ElapsedMinutes", ...
    "HorizontalRMS", "VerticalRMS", "HorizontalCrestFactor", "VerticalCrestFactor"]);
end
