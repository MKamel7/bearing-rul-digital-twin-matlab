%RUN_AGE_ONLY_RUL_BASELINE Evaluate a leakage-safe age-only RUL baseline.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

featurePath = fullfile(projectRoot, "results", "official_lifecycle", "all_bearings_lifecycle_features.csv");
manifestPath = fullfile(projectRoot, "docs", "data", "xjtu_sy_lifecycle_manifest.csv");
if ~isfile(featurePath)
    error("BearingRUL:LifecycleFeaturesMissing", ...
        "Lifecycle feature table not found: %s. Run scripts/summarize_official_lifecycles.m first.", featurePath);
end

features = readtable(featurePath, TextType="string");
manifest = readtable(manifestPath, TextType="string");
outerRaceManifest = manifest(manifest.FailureLabel == "outer race", :);
outerRaceFeatures = features(features.FailureLabel == "outer race", :);

nestedFolds = buildEvaluationFolds(outerRaceManifest, "outer race", "nested leave-one-bearing-out pilot");
conditionFolds = buildEvaluationFolds(outerRaceManifest, "outer race", "condition-held-out stress test");

nestedPredictions = evaluateAgeOnlyRulBaseline(outerRaceFeatures, nestedFolds);
conditionPredictions = evaluateAgeOnlyRulBaseline(outerRaceFeatures, conditionFolds);

outDir = fullfile(projectRoot, "results", "rul_baseline");
if ~isfolder(outDir)
    mkdir(outDir);
end

writetable(nestedPredictions, fullfile(outDir, "outer_race_age_only_nested_predictions.csv"));
writetable(conditionPredictions, fullfile(outDir, "outer_race_age_only_condition_held_out_predictions.csv"));

nestedMetrics = summarizePredictionErrors(nestedPredictions, "nested leave-one-bearing-out pilot");
conditionMetrics = summarizePredictionErrors(conditionPredictions, "condition-held-out stress test");
metrics = [nestedMetrics; conditionMetrics];
writetable(metrics, fullfile(outDir, "outer_race_age_only_metrics.csv"));

disp(metrics);
fprintf("Wrote %s\n", fullfile(outDir, "outer_race_age_only_nested_predictions.csv"));
fprintf("Wrote %s\n", fullfile(outDir, "outer_race_age_only_condition_held_out_predictions.csv"));
fprintf("Wrote %s\n", fullfile(outDir, "outer_race_age_only_metrics.csv"));

function metrics = summarizePredictionErrors(predictions, protocol)
bearings = unique(predictions.BearingID);
maeMinutes = zeros(numel(bearings), 1);
medianAbsoluteErrorMinutes = zeros(numel(bearings), 1);
meanNormalizedAbsoluteError = zeros(numel(bearings), 1);
lateOverpredictionMinutes = zeros(numel(bearings), 1);
rowCount = zeros(numel(bearings), 1);
conditionID = zeros(numel(bearings), 1);

for idx = 1:numel(bearings)
    rows = predictions(predictions.BearingID == bearings(idx), :);
    rowCount(idx) = height(rows);
    conditionID(idx) = rows.ConditionID(1);
    maeMinutes(idx) = mean(rows.AbsoluteErrorMinutes, "omitnan");
    medianAbsoluteErrorMinutes(idx) = median(rows.AbsoluteErrorMinutes, "omitnan");
    meanNormalizedAbsoluteError(idx) = mean(rows.NormalizedAbsoluteError, "omitnan");
    lateOverpredictionMinutes(idx) = mean(max(rows.SignedErrorMinutes, 0), "omitnan");
end

metrics = table(repmat(protocol, numel(bearings), 1), bearings, conditionID, rowCount, ...
    maeMinutes, medianAbsoluteErrorMinutes, meanNormalizedAbsoluteError, lateOverpredictionMinutes, ...
    VariableNames=["Protocol", "BearingID", "ConditionID", "PredictionRows", "MAEMinutes", ...
    "MedianAbsoluteErrorMinutes", "MeanNormalizedAbsoluteError", "MeanLateOverpredictionMinutes"]);
end
