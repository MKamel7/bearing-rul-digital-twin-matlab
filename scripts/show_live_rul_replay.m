%SHOW_LIVE_RUL_REPLAY Animate a measured-data replay of bearing RUL estimates.
%
% This is a live measured-data replay from official XJTU-SY lifecycle
% snapshots. It is not a live hardware sensor stream. To make it hardware-live,
% replace the table reads below with a DAQ/serial/OPC UA source that supplies
% the same feature columns and timestamps.

projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

bearingID = "Bearing3_1";
modelName = "feature-similarity model";
protocolName = "nested leave-one-bearing-out pilot";
replayDelaySeconds = 0.01;

featurePath = fullfile(projectRoot, "results", "official_lifecycle", "all_bearings_lifecycle_features.csv");
predictionPath = fullfile(projectRoot, "results", "rul_model_comparison", "outer_race_rul_model_predictions.csv");
if ~isfile(featurePath)
    error("BearingRUL:LifecycleFeaturesMissing", ...
        "Missing official feature table: %s. Run scripts/summarize_official_lifecycles.m first.", featurePath);
end
if ~isfile(predictionPath)
    error("BearingRUL:RulPredictionsMissing", ...
        "Missing RUL prediction table: %s. Run scripts/run_feature_similarity_rul_model.m first.", predictionPath);
end

features = readtable(featurePath, TextType="string");
predictions = readtable(predictionPath, TextType="string");

featureRows = features(features.BearingID == bearingID, :);
predictionRows = predictions(predictions.BearingID == bearingID & predictions.Model == modelName & ...
    predictions.Protocol == protocolName, :);
if isempty(featureRows) || isempty(predictionRows)
    error("BearingRUL:LiveReplayRowsMissing", ...
        "Could not find feature/prediction rows for %s, %s, %s.", bearingID, modelName, protocolName);
end

featureRows.MeanRMS = mean([featureRows.HorizontalRMS, featureRows.VerticalRMS], 2);
featureRows = sortrows(featureRows, "ElapsedMinutes");
predictionRows = sortrows(predictionRows, "ElapsedMinutes");
rowCount = min(height(featureRows), height(predictionRows));
featureRows = featureRows(1:rowCount, :);
predictionRows = predictionRows(1:rowCount, :);

figureHandle = figure("Name", "Live measured-data RUL replay", "Color", "w", "NumberTitle", "off");
figureHandle.Position = [120 80 1280 760];
layout = tiledlayout(2, 2, "TileSpacing", "compact", "Padding", "compact");
title(layout, "Official XJTU-SY measured-data replay - Bearing3_1 outer-race RUL", ...
    "FontWeight", "bold");

rmsAxis = nexttile(1);
rmsLine = animatedline(rmsAxis, "Color", [0 0.45 0.74], "LineWidth", 1.5);
hold(rmsAxis, "on");
xlabel(rmsAxis, "Elapsed minutes");
ylabel(rmsAxis, "Mean RMS");
title(rmsAxis, "Live replay input feature");
grid(rmsAxis, "on");
xlim(rmsAxis, [0 max(featureRows.ElapsedMinutes)]);
ylim(rmsAxis, [0 max(featureRows.MeanRMS) * 1.12]);

rulAxis = nexttile(2);
actualLine = animatedline(rulAxis, "Color", [0 0 0], "LineWidth", 1.5, "DisplayName", "Actual RUL");
predictionLine = animatedline(rulAxis, "Color", [0.1 0.62 0.48], "LineWidth", 1.2, "DisplayName", modelName);
hold(rulAxis, "on");
xlabel(rulAxis, "Elapsed minutes");
ylabel(rulAxis, "RUL minutes");
title(rulAxis, "Online RUL estimate during replay");
legend(rulAxis, "Location", "northeast");
grid(rulAxis, "on");
xlim(rulAxis, [0 max(predictionRows.ElapsedMinutes)]);
ylim(rulAxis, [0 max(predictionRows.ActualRULMinutes) * 1.08]);

errorAxis = nexttile(3);
errorLine = animatedline(errorAxis, "Color", [0.85 0.33 0.1], "LineWidth", 1.2);
hold(errorAxis, "on");
xlabel(errorAxis, "Elapsed minutes");
ylabel(errorAxis, "Absolute error minutes");
title(errorAxis, "Live error trace");
grid(errorAxis, "on");
xlim(errorAxis, [0 max(predictionRows.ElapsedMinutes)]);
ylim(errorAxis, [0 max(predictionRows.AbsoluteErrorMinutes) * 1.12]);

statusAxis = nexttile(4);
axis(statusAxis, "off");
statusText = text(statusAxis, 0.02, 0.80, "", "FontName", "Consolas", "FontSize", 13, ...
    "VerticalAlignment", "top");
boundaryText = text(statusAxis, 0.02, 0.16, ...
    "Boundary: real measured XJTU-SY replay, not a live hardware sensor stream.", ...
    "FontSize", 10, "Color", [0.35 0.35 0.35]);
boundaryText.FontWeight = "bold";

for idx = 1:rowCount
    elapsed = predictionRows.ElapsedMinutes(idx);
    addpoints(rmsLine, elapsed, featureRows.MeanRMS(idx));
    addpoints(actualLine, elapsed, predictionRows.ActualRULMinutes(idx));
    addpoints(predictionLine, elapsed, predictionRows.PredictedRULMinutes(idx));
    addpoints(errorLine, elapsed, predictionRows.AbsoluteErrorMinutes(idx));

    statusText.String = sprintf("Bearing: %s\nProtocol: %s\nModel: %s\nSnapshot: %d / %d\n" + ...
        "Elapsed: %.0f min\nMeasured mean RMS: %.3f\nActual RUL: %.0f min\n" + ...
        "Predicted RUL: %.0f min\nAbs error: %.0f min", ...
        char(bearingID), char(protocolName), char(modelName), idx, rowCount, elapsed, featureRows.MeanRMS(idx), ...
        predictionRows.ActualRULMinutes(idx), predictionRows.PredictedRULMinutes(idx), ...
        predictionRows.AbsoluteErrorMinutes(idx));
    drawnow limitrate;
    pause(replayDelaySeconds);
end

drawnow;
fprintf("Live measured-data replay complete for %s using %s (%s).\n", bearingID, modelName, protocolName);
