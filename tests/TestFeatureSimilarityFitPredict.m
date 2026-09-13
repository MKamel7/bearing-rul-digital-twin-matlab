classdef TestFeatureSimilarityFitPredict < matlab.unittest.TestCase
    methods (Test)
        function fitPredictUsesTrainingRowsWithoutActualRulInLiveFrame(testCase)
            trainingRows = makeTrainingFeatureTable();
            model = fitFeatureSimilarityRulModel(trainingRows, ["HorizontalRMS", "VerticalRMS"], NeighborCount=1);

            liveFrame = table("LiveBearing", 1, "outer race", 2, 1, 1.1, 1.1, ...
                VariableNames=["BearingID", "ConditionID", "FailureLabel", "SnapshotIndex", "ElapsedMinutes", ...
                "HorizontalRMS", "VerticalRMS"]);
            predictedRUL = predictFeatureSimilarityRul(model, liveFrame);

            testCase.verifyEqual(predictedRUL, 1);
        end

        function fitStoresTrainingOnlyScaling(testCase)
            trainingRows = makeTrainingFeatureTable();
            model = fitFeatureSimilarityRulModel(trainingRows, ["HorizontalRMS", "VerticalRMS"], NeighborCount=1);

            expectedScale = std([0 0; 1 1; 2 2; 8 8; 9 9; 10 10], 0, 1);
            testCase.verifyEqual(model.FeatureCenter, [5 5], AbsTol=1e-12);
            testCase.verifyEqual(model.FeatureScale, expectedScale, AbsTol=1e-12);
        end

        function predictRejectsMissingLiveFeature(testCase)
            trainingRows = makeTrainingFeatureTable();
            model = fitFeatureSimilarityRulModel(trainingRows, ["HorizontalRMS", "VerticalRMS"], NeighborCount=1);
            liveFrame = table("LiveBearing", 1.1, VariableNames=["BearingID", "HorizontalRMS"]);

            testCase.verifyError(@() predictFeatureSimilarityRul(model, liveFrame), ...
                "BearingRUL:MissingLiveFeatureColumns");
        end
    end
end

function rows = makeTrainingFeatureTable()
bearingID = ["TrainA"; "TrainA"; "TrainA"; "TrainB"; "TrainB"; "TrainB"];
conditionID = ones(6, 1);
failureLabel = repmat("outer race", 6, 1);
snapshotIndex = [1; 2; 3; 1; 2; 3];
elapsedMinutes = snapshotIndex - 1;
horizontalRMS = [0; 1; 2; 8; 9; 10];
verticalRMS = horizontalRMS;

rows = table(bearingID, conditionID, failureLabel, snapshotIndex, elapsedMinutes, horizontalRMS, verticalRMS, ...
    VariableNames=["BearingID", "ConditionID", "FailureLabel", "SnapshotIndex", "ElapsedMinutes", ...
    "HorizontalRMS", "VerticalRMS"]);
end
