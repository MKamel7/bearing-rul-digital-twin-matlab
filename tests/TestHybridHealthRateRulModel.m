classdef TestHybridHealthRateRulModel < matlab.unittest.TestCase
    methods (Test)
        function fitStoresTrainingOnlyHealthRateState(testCase)
            trainingRows = makeTrainingRows();

            model = fitHybridHealthRateRulModel(trainingRows, WindowSize=2, ...
                FailureThresholdQuantile=0.5, MinimumSlopeQuantile=0.5, AgeGateQuantile=0.5);

            testCase.verifyEqual(model.TrainingLifetimesMinutes', [4 6]);
            testCase.verifyEqual(model.FailureHealthThreshold, 3.25, AbsTol=1e-12);
            testCase.verifyEqual(model.MinimumHealthSlope, (0.5 + (3 - 1.1) / 3) / 2, AbsTol=1e-12);
            testCase.verifyEqual(model.AgeGateMinutes, 5, AbsTol=1e-12);
        end

        function predictUsesOnlyRowsAvailableInEachPrefix(testCase)
            trainingRows = makeTrainingRows();
            model = fitHybridHealthRateRulModel(trainingRows, WindowSize=2, ...
                FailureThresholdQuantile=0.5, MinimumSlopeQuantile=0.5, AgeGateQuantile=0.5);

            firstLiveRow = makeLiveRows(1);
            liveRowsWithFutureSpike = makeLiveRows(6);
            liveRowsWithFutureSpike.HorizontalRMS(end) = 20;
            liveRowsWithFutureSpike.VerticalRMS(end) = 20;

            firstPrediction = predictHybridHealthRateRul(model, firstLiveRow);
            predictionsWithFutureSpike = predictHybridHealthRateRul(model, liveRowsWithFutureSpike);

            testCase.verifyEqual(firstPrediction, predictionsWithFutureSpike(1), AbsTol=1e-12);
        end

        function predictSwitchesToHealthRateAfterGate(testCase)
            trainingRows = makeTrainingRows();
            model = fitHybridHealthRateRulModel(trainingRows, WindowSize=2, ...
                FailureThresholdQuantile=0.5, MinimumSlopeQuantile=0.5, AgeGateQuantile=0.5, ...
                HealthyGateFraction=0.8);
            liveRows = makeLiveRows(5);

            predictions = predictHybridHealthRateRul(model, liveRows);

            testCase.verifyEqual(predictions(1), 4, AbsTol=1e-12);
            testCase.verifyGreaterThan(predictions(end), 0.5);
            testCase.verifyEqual(predictions(end), 3.97058823529412, AbsTol=1e-12);
        end

        function fitRejectsMissingMeasuredFeatureColumns(testCase)
            trainingRows = makeTrainingRows();
            trainingRows.HorizontalRMS = [];

            testCase.verifyError(@() fitHybridHealthRateRulModel(trainingRows), ...
                "BearingRUL:MissingHybridTrainingColumns");
        end
    end
end

function rows = makeTrainingRows()
bearingID = ["TrainA"; "TrainA"; "TrainA"; "TrainA"; "TrainB"; "TrainB"; "TrainB"; "TrainB"; "TrainB"; "TrainB"];
snapshotIndex = [1; 2; 3; 4; 1; 2; 3; 4; 5; 6];
elapsedMinutes = snapshotIndex - 1;
conditionID = ones(10, 1);
failureLabel = repmat("outer race", 10, 1);
meanRMS = [1; 1.2; 2; 4; 1; 1; 1.1; 1.5; 2; 5];

rows = table(bearingID, conditionID, failureLabel, snapshotIndex, elapsedMinutes, meanRMS, meanRMS, ...
    VariableNames=["BearingID", "ConditionID", "FailureLabel", "SnapshotIndex", "ElapsedMinutes", ...
    "HorizontalRMS", "VerticalRMS"]);
end

function rows = makeLiveRows(rowCount)
bearingID = repmat("Heldout", rowCount, 1);
conditionID = ones(rowCount, 1);
failureLabel = repmat("outer race", rowCount, 1);
snapshotIndex = (1:rowCount)';
elapsedMinutes = snapshotIndex - 1;
meanRMS = ones(rowCount, 1);

rows = table(bearingID, conditionID, failureLabel, snapshotIndex, elapsedMinutes, meanRMS, meanRMS, ...
    VariableNames=["BearingID", "ConditionID", "FailureLabel", "SnapshotIndex", "ElapsedMinutes", ...
    "HorizontalRMS", "VerticalRMS"]);
end
