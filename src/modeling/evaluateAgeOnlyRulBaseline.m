function predictions = evaluateAgeOnlyRulBaseline(features, folds)
%EVALUATEAGEONLYRULBASELINE Evaluate an age-only RUL baseline on fold rows.
arguments
    features table
    folds table
end

requiredFeatureColumns = ["BearingID", "ConditionID", "FailureLabel", "SnapshotIndex", "ElapsedMinutes"];
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
    trainLifetimes = bearingLifetimes.LifetimeMinutes(ismember(bearingLifetimes.BearingID, trainBearings));

    for heldoutIdx = 1:numel(heldoutBearings)
        heldoutRows = features(features.BearingID == heldoutBearings(heldoutIdx), :);
        heldoutLifetime = bearingLifetimes.LifetimeMinutes(bearingLifetimes.BearingID == heldoutBearings(heldoutIdx));
        predictedRUL = arrayfun(@(snapshotIndex) median(max(trainLifetimes - snapshotIndex, 0)), heldoutRows.SnapshotIndex);
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
