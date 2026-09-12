function comparison = compareEvaluationProtocols(manifest, targetFailureLabel)
%COMPAREEVALUATIONPROTOCOLS Compare feasible RUL evaluation routes.
arguments
    manifest table
    targetFailureLabel (1,1) string = "outer race"
end

requiredColumns = ["BearingID", "ConditionID", "FailureLabel", "Split", "LifetimeMinutes"];
missingColumns = setdiff(requiredColumns, string(manifest.Properties.VariableNames));
if ~isempty(missingColumns)
    error("BearingRUL:MissingEvaluationColumns", ...
        "Manifest is missing required evaluation columns: %s", strjoin(missingColumns, ", "));
end

targetRows = manifest(strcmpi(strtrim(manifest.FailureLabel), targetFailureLabel), :);
if isempty(targetRows)
    error("BearingRUL:NoTargetBearings", "No bearings found for failure label: %s", targetFailureLabel);
end

conditionIds = unique(targetRows.ConditionID);
conditionCounts = groupcounts(targetRows, "ConditionID");
heldOutCounts = conditionCounts.GroupCount;
currentRoleCounts = groupcounts(targetRows, "Split");

allTrainingConditionCounts = zeros(height(targetRows), 1);
for idx = 1:height(targetRows)
    trainingRows = targetRows;
    trainingRows(idx, :) = [];
    allTrainingConditionCounts(idx) = numel(unique(trainingRows.ConditionID));
end

pooledLifetimeRatio = max(targetRows.LifetimeMinutes) / min(targetRows.LifetimeMinutes);

comparison = table();
comparison.Protocol = [
    "nested leave-one-bearing-out pilot"
    "condition-held-out stress test"
    ];
comparison.TargetFailureLabel = repmat(targetFailureLabel, 2, 1);
comparison.IndependentTargetBearings = repmat(height(targetRows), 2, 1);
comparison.DevelopmentFolds = [height(targetRows); numel(conditionIds)];
comparison.MinimumHeldOutBearings = [1; min(heldOutCounts)];
comparison.TrainingConditionCoverage = [
    sprintf("%d of %d conditions retained in every outer fold", min(allTrainingConditionCounts), numel(conditionIds))
    sprintf("%d held-out operating conditions", numel(conditionIds))
    ];
comparison.TestsRegimeTransfer = [false; true];
comparison.CurrentManifestFinalTestBearings = repmat(sum(currentRoleCounts.GroupCount(strcmpi(currentRoleCounts.Split, "test"))), 2, 1);
comparison.LifetimeRangeRatio = repmat(pooledLifetimeRatio, 2, 1);
comparison.PrimaryRisk = [
    "small n; pilot evidence only"
    "condition, load, speed and lifetime are confounded"
    ];
comparison.BestFitRank = [1; 2];
comparison.Recommendation = [
    "best first fit for development; tune only inside each outer fold"
    "secondary transfer stress test after the pilot is frozen"
    ];
end
