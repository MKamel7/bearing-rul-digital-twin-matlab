function predictions = evaluateFeatureSimilarityRulModel(features, folds, featureNames, options)
%EVALUATEFEATURESIMILARITYRULMODEL Predict held-out RUL from training feature similarity.
arguments
    features table
    folds table
    featureNames (1,:) string = ["HorizontalRMS", "VerticalRMS", "HorizontalCrestFactor", "VerticalCrestFactor"]
    options.NeighborCount (1,1) double {mustBeInteger, mustBePositive} = 25
end

requiredFeatureColumns = ["BearingID", "ConditionID", "FailureLabel", "SnapshotIndex", "ElapsedMinutes", featureNames];
missingFeatureColumns = setdiff(requiredFeatureColumns, string(features.Properties.VariableNames));
if ~isempty(missingFeatureColumns)
    error("BearingRUL:MissingFeatureColumns", ...
        "Feature table is missing required columns: %s", strjoin(missingFeatureColumns, ", "));
end

requiredFoldColumns = ["FoldID", "Protocol", "BearingID", "Role"];
missingFoldColumns = setdiff(requiredFoldColumns, string(folds.Properties.VariableNames));
if ~isempty(missingFoldColumns)
    error("BearingRUL:MissingFoldColumns", ...
        "Fold table is missing required columns: %s", strjoin(missingFoldColumns, ", "));
end

bearingLifetimes = groupcounts(features, "BearingID");
bearingLifetimes.Properties.VariableNames("GroupCount") = "LifetimeMinutes";

predictions = table();
foldIDs = unique(folds.FoldID);
for foldIdx = 1:numel(foldIDs)
    foldID = foldIDs(foldIdx);
    foldRows = folds(folds.FoldID == foldID, :);
    protocol = foldRows.Protocol(1);
    trainBearings = foldRows.BearingID(foldRows.Role == "train");
    heldoutBearings = foldRows.BearingID(foldRows.Role == "heldout");

    trainRows = features(ismember(features.BearingID, trainBearings), :);
    if isempty(trainRows)
        error("BearingRUL:EmptyTrainingFold", "Fold %d has no training feature rows.", foldID);
    end

    trainLifetime = lookupBearingLifetime(bearingLifetimes, trainRows.BearingID);
    trainActualRUL = trainLifetime - trainRows.SnapshotIndex;
    [scaledTrainFeatures, featureCenter, featureScale] = scaleTrainingFeatures(trainRows, featureNames);

    for heldoutIdx = 1:numel(heldoutBearings)
        heldoutRows = features(features.BearingID == heldoutBearings(heldoutIdx), :);
        heldoutLifetime = lookupBearingLifetime(bearingLifetimes, heldoutRows.BearingID(1));
        scaledHeldoutFeatures = (table2array(heldoutRows(:, featureNames)) - featureCenter) ./ featureScale;

        predictedRUL = predictFromNearestTrainingSnapshots(scaledTrainFeatures, trainActualRUL, ...
            scaledHeldoutFeatures, options.NeighborCount);
        actualRUL = heldoutLifetime - heldoutRows.SnapshotIndex;
        signedError = predictedRUL - actualRUL;
        absoluteError = abs(signedError);
        normalizedAbsoluteError = absoluteError ./ heldoutLifetime;

        foldIDColumn = repmat(foldID, height(heldoutRows), 1);
        protocolColumn = repmat(protocol, height(heldoutRows), 1);
        heldoutLifetimeColumn = repmat(heldoutLifetime, height(heldoutRows), 1);

        predictionRows = table(foldIDColumn, protocolColumn, heldoutRows.BearingID, heldoutRows.ConditionID, ...
            heldoutRows.FailureLabel, heldoutRows.SnapshotIndex, heldoutRows.ElapsedMinutes, heldoutLifetimeColumn, ...
            actualRUL, predictedRUL, signedError, absoluteError, normalizedAbsoluteError, ...
            VariableNames=["FoldID", "Protocol", "BearingID", "ConditionID", "FailureLabel", "SnapshotIndex", ...
            "ElapsedMinutes", "LifetimeMinutes", "ActualRULMinutes", "PredictedRULMinutes", "SignedErrorMinutes", ...
            "AbsoluteErrorMinutes", "NormalizedAbsoluteError"]);
        predictions = [predictions; predictionRows]; %#ok<AGROW>
    end
end
end

function [scaledFeatures, featureCenter, featureScale] = scaleTrainingFeatures(rows, featureNames)
featureValues = table2array(rows(:, featureNames));
featureCenter = mean(featureValues, 1, "omitnan");
featureScale = std(featureValues, 0, 1, "omitnan");
featureScale(~isfinite(featureScale) | featureScale == 0) = 1;
scaledFeatures = (featureValues - featureCenter) ./ featureScale;
end

function predictedRUL = predictFromNearestTrainingSnapshots(trainFeatures, trainActualRUL, heldoutFeatures, neighborCount)
predictedRUL = zeros(size(heldoutFeatures, 1), 1);
actualNeighborCount = min(neighborCount, numel(trainActualRUL));
for rowIdx = 1:size(heldoutFeatures, 1)
    distances = sum((trainFeatures - heldoutFeatures(rowIdx, :)).^2, 2);
    [~, nearestIdx] = mink(distances, actualNeighborCount);
    predictedRUL(rowIdx) = max(median(trainActualRUL(nearestIdx), "omitnan"), 0);
end
end

function lifetimes = lookupBearingLifetime(bearingLifetimes, bearingIDs)
[found, idx] = ismember(bearingIDs, bearingLifetimes.BearingID);
if ~all(found)
    missingIDs = unique(bearingIDs(~found));
    error("BearingRUL:MissingBearingLifetime", ...
        "Could not find lifetimes for bearings: %s", strjoin(missingIDs, ", "));
end
lifetimes = bearingLifetimes.LifetimeMinutes(idx);
end
