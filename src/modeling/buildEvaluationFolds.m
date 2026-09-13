function folds = buildEvaluationFolds(manifest, targetFailureLabel, protocol)
%BUILDEVALUATIONFOLDS Build manifest-level RUL evaluation fold assignments.
arguments
    manifest table
    targetFailureLabel (1,1) string = "outer race"
    protocol (1,1) string {mustBeMember(protocol, ["nested leave-one-bearing-out pilot", "condition-held-out stress test"])} = "nested leave-one-bearing-out pilot"
end

requiredColumns = ["BearingID", "ConditionID", "FailureLabel", "LifetimeMinutes"];
missingColumns = setdiff(requiredColumns, string(manifest.Properties.VariableNames));
if ~isempty(missingColumns)
    error("BearingRUL:MissingEvaluationColumns", ...
        "Manifest is missing required evaluation columns: %s", strjoin(missingColumns, ", "));
end

targetRows = manifest(strcmpi(strtrim(manifest.FailureLabel), targetFailureLabel), :);
targetRows = sortrows(targetRows, ["ConditionID", "BearingID"]);
if isempty(targetRows)
    error("BearingRUL:NoTargetBearings", "No bearings found for failure label: %s", targetFailureLabel);
end

switch protocol
    case "nested leave-one-bearing-out pilot"
        folds = buildLeaveOneBearingOutFolds(targetRows, targetFailureLabel, protocol);
    case "condition-held-out stress test"
        folds = buildConditionHeldOutFolds(targetRows, targetFailureLabel, protocol);
end
end

function folds = buildLeaveOneBearingOutFolds(targetRows, targetFailureLabel, protocol)
folds = table();
for heldoutIdx = 1:height(targetRows)
    foldRows = targetRows;
    role = repmat("train", height(foldRows), 1);
    role(heldoutIdx) = "heldout";
    folds = [folds; makeFoldTable(heldoutIdx, foldRows, role, targetFailureLabel, protocol)]; %#ok<AGROW>
end
end

function folds = buildConditionHeldOutFolds(targetRows, targetFailureLabel, protocol)
folds = table();
conditionIds = unique(targetRows.ConditionID);
for foldIdx = 1:numel(conditionIds)
    foldRows = targetRows;
    role = repmat("train", height(foldRows), 1);
    role(foldRows.ConditionID == conditionIds(foldIdx)) = "heldout";
    folds = [folds; makeFoldTable(foldIdx, foldRows, role, targetFailureLabel, protocol)]; %#ok<AGROW>
end
end

function foldTable = makeFoldTable(foldID, foldRows, role, targetFailureLabel, protocol)
foldIDColumn = repmat(foldID, height(foldRows), 1);
protocolColumn = repmat(protocol, height(foldRows), 1);
targetFailureLabelColumn = repmat(targetFailureLabel, height(foldRows), 1);

foldTable = table(foldIDColumn, protocolColumn, targetFailureLabelColumn, ...
    foldRows.BearingID, foldRows.ConditionID, foldRows.LifetimeMinutes, role, ...
    VariableNames=["FoldID", "Protocol", "TargetFailureLabel", "BearingID", "ConditionID", ...
    "LifetimeMinutes", "Role"]);
end
