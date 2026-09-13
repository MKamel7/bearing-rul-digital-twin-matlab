%RUN_FEATURE_SIMILARITY_RUL_MODEL Compare age-only and feature-similarity RUL models.
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
featureNames = ["HorizontalRMS", "VerticalRMS", "HorizontalCrestFactor", "VerticalCrestFactor"];

nestedFolds = buildEvaluationFolds(outerRaceManifest, "outer race", "nested leave-one-bearing-out pilot");
conditionFolds = buildEvaluationFolds(outerRaceManifest, "outer race", "condition-held-out stress test");

nestedAgePredictions = addModelLabel(evaluateAgeOnlyRulBaseline(outerRaceFeatures, nestedFolds), "age-only baseline");
nestedFeaturePredictions = addModelLabel(evaluateFeatureSimilarityRulModel(outerRaceFeatures, nestedFolds, featureNames), ...
    "feature-similarity model");
conditionAgePredictions = addModelLabel(evaluateAgeOnlyRulBaseline(outerRaceFeatures, conditionFolds), "age-only baseline");
conditionFeaturePredictions = addModelLabel(evaluateFeatureSimilarityRulModel(outerRaceFeatures, conditionFolds, featureNames), ...
    "feature-similarity model");

predictions = [nestedAgePredictions; nestedFeaturePredictions; conditionAgePredictions; conditionFeaturePredictions];
perBearingMetrics = summarizePredictionErrors(predictions);
summaryMetrics = summarizeProtocolMetrics(perBearingMetrics, predictions);

outDir = fullfile(projectRoot, "results", "rul_model_comparison");
if ~isfolder(outDir)
    mkdir(outDir);
end

writetable(predictions, fullfile(outDir, "outer_race_rul_model_predictions.csv"));
writetable(perBearingMetrics, fullfile(outDir, "outer_race_rul_model_per_bearing_metrics.csv"));
writetable(summaryMetrics, fullfile(outDir, "outer_race_rul_model_summary_metrics.csv"));
plotRepresentativeBearing(predictions, outDir);

disp(summaryMetrics);
fprintf("Wrote %s\n", fullfile(outDir, "outer_race_rul_model_predictions.csv"));
fprintf("Wrote %s\n", fullfile(outDir, "outer_race_rul_model_per_bearing_metrics.csv"));
fprintf("Wrote %s\n", fullfile(outDir, "outer_race_rul_model_summary_metrics.csv"));
fprintf("Wrote %s\n", fullfile(outDir, "nested_bearing3_1_rul_comparison.png"));

function predictions = addModelLabel(predictions, modelName)
predictions.Model = repmat(modelName, height(predictions), 1);
predictions = movevars(predictions, "Model", Before="FoldID");
end

function metrics = summarizePredictionErrors(predictions)
models = unique(predictions.Model);
metrics = table();
for modelIdx = 1:numel(models)
    modelRows = predictions(predictions.Model == models(modelIdx), :);
    protocols = unique(modelRows.Protocol);
    for protocolIdx = 1:numel(protocols)
        protocolRows = modelRows(modelRows.Protocol == protocols(protocolIdx), :);
        bearings = unique(protocolRows.BearingID);
        for bearingIdx = 1:numel(bearings)
            rows = protocolRows(protocolRows.BearingID == bearings(bearingIdx), :);
            metricRow = table(models(modelIdx), protocols(protocolIdx), bearings(bearingIdx), rows.ConditionID(1), ...
                height(rows), mean(rows.AbsoluteErrorMinutes, "omitnan"), ...
                median(rows.AbsoluteErrorMinutes, "omitnan"), mean(rows.NormalizedAbsoluteError, "omitnan"), ...
                mean(max(rows.SignedErrorMinutes, 0), "omitnan"), ...
                VariableNames=["Model", "Protocol", "BearingID", "ConditionID", "PredictionRows", ...
                "MAEMinutes", "MedianAbsoluteErrorMinutes", "MeanNormalizedAbsoluteError", ...
                "MeanLateOverpredictionMinutes"]);
            metrics = [metrics; metricRow]; %#ok<AGROW>
        end
    end
end
end

function summary = summarizeProtocolMetrics(perBearingMetrics, predictions)
summary = table();
models = unique(perBearingMetrics.Model);
for modelIdx = 1:numel(models)
    modelRows = perBearingMetrics(perBearingMetrics.Model == models(modelIdx), :);
    protocols = unique(modelRows.Protocol);
    for protocolIdx = 1:numel(protocols)
        rows = modelRows(modelRows.Protocol == protocols(protocolIdx), :);
        predictionRows = predictions(predictions.Model == models(modelIdx) & predictions.Protocol == protocols(protocolIdx), :);
        [worstMAE, worstIdx] = max(rows.MAEMinutes);
        summaryRow = table(models(modelIdx), protocols(protocolIdx), height(rows), height(predictionRows), ...
            mean(predictionRows.AbsoluteErrorMinutes, "omitnan"), ...
            mean(predictionRows.NormalizedAbsoluteError, "omitnan"), ...
            mean(rows.MAEMinutes, "omitnan"), rows.BearingID(worstIdx), worstMAE, ...
            VariableNames=["Model", "Protocol", "BearingCount", "PredictionRows", "WeightedMAEMinutes", ...
            "WeightedNormalizedMAE", "MeanPerBearingMAEMinutes", "WorstBearingID", "WorstBearingMAEMinutes"]);
        summary = [summary; summaryRow]; %#ok<AGROW>
    end
end
end

function plotRepresentativeBearing(predictions, outDir)
rows = predictions(predictions.Protocol == "nested leave-one-bearing-out pilot" & predictions.BearingID == "Bearing3_1", :);
if isempty(rows)
    return;
end

figureHandle = figure("Visible", "off", "Color", "w");
hold on;
actualRows = rows(rows.Model == rows.Model(1), :);
plot(actualRows.ElapsedMinutes, actualRows.ActualRULMinutes, "k-", "LineWidth", 1.5, "DisplayName", "Actual RUL");
models = unique(rows.Model);
for modelIdx = 1:numel(models)
    modelRows = rows(rows.Model == models(modelIdx), :);
    plot(modelRows.ElapsedMinutes, modelRows.PredictedRULMinutes, "LineWidth", 1.0, "DisplayName", models(modelIdx));
end
hold off;
grid on;
xlabel("Elapsed minutes");
ylabel("RUL minutes");
title("Nested held-out Bearing3_1 RUL comparison");
legend("Location", "best");
exportgraphics(figureHandle, fullfile(outDir, "nested_bearing3_1_rul_comparison.png"), Resolution=160);
close(figureHandle);
end
