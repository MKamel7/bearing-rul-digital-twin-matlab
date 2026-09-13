function predictions = evaluateHybridHealthRateRulModel(features, folds, options)
%EVALUATEHYBRIDHEALTHRATERULMODEL Evaluate hybrid health-rate RUL on folds.
arguments
    features table
    folds table
    options.WindowSize (1,1) double {mustBeInteger, mustBePositive} = 10
    options.FailureThresholdQuantile (1,1) double {mustBeGreaterThanOrEqual(options.FailureThresholdQuantile, 0), ...
        mustBeLessThanOrEqual(options.FailureThresholdQuantile, 1)} = 0.6
    options.MinimumSlopeQuantile (1,1) double {mustBeGreaterThanOrEqual(options.MinimumSlopeQuantile, 0), ...
        mustBeLessThanOrEqual(options.MinimumSlopeQuantile, 1)} = 0.2
    options.AgeGateQuantile (1,1) double {mustBeGreaterThanOrEqual(options.AgeGateQuantile, 0), ...
        mustBeLessThanOrEqual(options.AgeGateQuantile, 1)} = 0.75
    options.HealthyGateFraction (1,1) double {mustBeNonnegative} = 0.8
end

requiredFeatureColumns = ["BearingID", "ConditionID", "FailureLabel", "SnapshotIndex", "ElapsedMinutes", ...
    "HorizontalRMS", "VerticalRMS"];
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

    model = fitHybridHealthRateRulModel(trainRows, WindowSize=options.WindowSize, ...
        FailureThresholdQuantile=options.FailureThresholdQuantile, ...
        MinimumSlopeQuantile=options.MinimumSlopeQuantile, AgeGateQuantile=options.AgeGateQuantile, ...
        HealthyGateFraction=options.HealthyGateFraction);

    for heldoutIdx = 1:numel(heldoutBearings)
        heldoutRows = sortrows(features(features.BearingID == heldoutBearings(heldoutIdx), :), "SnapshotIndex");
        heldoutLifetime = lookupBearingLifetime(bearingLifetimes, heldoutRows.BearingID(1));
        predictedRUL = predictHybridHealthRateRul(model, heldoutRows);
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

function lifetimes = lookupBearingLifetime(bearingLifetimes, bearingIDs)
[found, idx] = ismember(bearingIDs, bearingLifetimes.BearingID);
if ~all(found)
    missingIDs = unique(bearingIDs(~found));
    error("BearingRUL:MissingBearingLifetime", ...
        "Could not find lifetimes for bearings: %s", strjoin(missingIDs, ", "));
end
lifetimes = bearingLifetimes.LifetimeMinutes(idx);
end
