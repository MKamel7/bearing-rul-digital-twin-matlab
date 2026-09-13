classdef TestHybridHealthRateRulEvaluation < matlab.unittest.TestCase
    methods (Test)
        function evaluatesHeldoutRowsWithPrefixPredictions(testCase)
            features = makeEvaluationRows();
            folds = table( ...
                [1; 1; 1], ...
                repmat("nested leave-one-bearing-out pilot", 3, 1), ...
                ["TrainA"; "TrainB"; "Heldout"], ...
                ["train"; "train"; "heldout"], ...
                VariableNames=["FoldID", "Protocol", "BearingID", "Role"]);

            predictions = evaluateHybridHealthRateRulModel(features, folds, WindowSize=2, ...
                FailureThresholdQuantile=0.5, MinimumSlopeQuantile=0.5, AgeGateQuantile=0.5, ...
                HealthyGateFraction=0.8);

            testCase.verifyEqual(height(predictions), 5);
            testCase.verifyEqual(predictions.BearingID, repmat("Heldout", 5, 1));
            testCase.verifyEqual(predictions.ActualRULMinutes', [4 3 2 1 0]);
            testCase.verifyEqual(predictions.PredictedRULMinutes(1), 4, AbsTol=1e-12);
            testCase.verifyEqual(predictions.PredictedRULMinutes(end), 3.97058823529412, AbsTol=1e-12);
            testCase.verifyEqual(predictions.AbsoluteErrorMinutes(end), 3.97058823529412, AbsTol=1e-12);
            testCase.verifyEqual(predictions.NormalizedAbsoluteError(end), 3.97058823529412 / 5, AbsTol=1e-12);
        end

        function rejectsMissingFoldColumns(testCase)
            features = makeEvaluationRows();
            folds = table(["TrainA"; "Heldout"], ["train"; "heldout"], ...
                VariableNames=["BearingID", "Role"]);

            testCase.verifyError(@() evaluateHybridHealthRateRulModel(features, folds), ...
                "BearingRUL:MissingFoldColumns");
        end
    end
end

function rows = makeEvaluationRows()
trainingBearingID = ["TrainA"; "TrainA"; "TrainA"; "TrainA"; "TrainB"; "TrainB"; "TrainB"; ...
    "TrainB"; "TrainB"; "TrainB"];
trainingSnapshotIndex = [1; 2; 3; 4; 1; 2; 3; 4; 5; 6];
trainingMeanRMS = [1; 1.2; 2; 4; 1; 1; 1.1; 1.5; 2; 5];

heldoutBearingID = repmat("Heldout", 5, 1);
heldoutSnapshotIndex = (1:5)';
heldoutMeanRMS = ones(5, 1);

bearingID = [trainingBearingID; heldoutBearingID];
snapshotIndex = [trainingSnapshotIndex; heldoutSnapshotIndex];
meanRMS = [trainingMeanRMS; heldoutMeanRMS];
conditionID = ones(numel(bearingID), 1);
failureLabel = repmat("outer race", numel(bearingID), 1);
elapsedMinutes = snapshotIndex - 1;

rows = table(bearingID, conditionID, failureLabel, snapshotIndex, elapsedMinutes, meanRMS, meanRMS, ...
    VariableNames=["BearingID", "ConditionID", "FailureLabel", "SnapshotIndex", "ElapsedMinutes", ...
    "HorizontalRMS", "VerticalRMS"]);
end
