%EXPORT_WEB_DEMO_ASSETS Export portfolio-ready video, poster and metrics.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

featurePath = fullfile(projectRoot, "results", "official_lifecycle", "all_bearings_lifecycle_features.csv");
predictionPath = fullfile(projectRoot, "results", "hybrid_health_rate_rul", ...
    "outer_race_hybrid_health_rate_predictions.csv");
summaryPath = fullfile(projectRoot, "results", "hybrid_health_rate_rul", ...
    "outer_race_hybrid_health_rate_summary_metrics.csv");
if ~isfile(featurePath)
    error("BearingRUL:LifecycleFeaturesMissing", ...
        "Missing lifecycle feature table: %s. Run scripts/summarize_official_lifecycles.m first.", featurePath);
end
if ~isfile(predictionPath) || ~isfile(summaryPath)
    run(fullfile(projectRoot, "scripts", "run_hybrid_health_rate_rul_model.m"));
end

outDir = fullfile(projectRoot, "results", "web_demo");
if ~isfolder(outDir)
    mkdir(outDir);
end

bearingID = "Bearing3_1";
protocolName = "nested leave-one-bearing-out pilot";
modelName = "hybrid health-rate model";
videoPath = fullfile(outDir, "bearing_rul_hybrid_live_replay.mp4");
posterPath = fullfile(outDir, "bearing_rul_hybrid_live_replay_poster.png");
metricsPath = fullfile(outDir, "bearing_rul_hybrid_metrics.json");

features = readtable(featurePath, TextType="string");
predictions = readtable(predictionPath, TextType="string");
summaryMetrics = readtable(summaryPath, TextType="string");

featureRows = sortrows(features(features.BearingID == bearingID, :), "ElapsedMinutes");
predictionRows = sortrows(predictions(predictions.BearingID == bearingID & predictions.Model == modelName & ...
    predictions.Protocol == protocolName, :), "ElapsedMinutes");
if isempty(featureRows) || isempty(predictionRows)
    error("BearingRUL:WebDemoRowsMissing", "Missing rows for %s, %s, %s.", bearingID, modelName, protocolName);
end

rowCount = min(height(featureRows), height(predictionRows));
featureRows = featureRows(1:rowCount, :);
predictionRows = predictionRows(1:rowCount, :);
featureRows.MeanRMS = mean([featureRows.HorizontalRMS, featureRows.VerticalRMS], 2);

writeMetricsJson(summaryMetrics, metricsPath, modelName, protocolName);
renderReplayVideo(featureRows, predictionRows, videoPath, posterPath, modelName);

fprintf("Wrote %s\n", videoPath);
fprintf("Wrote %s\n", posterPath);
fprintf("Wrote %s\n", metricsPath);

function writeMetricsJson(summaryMetrics, metricsPath, modelName, protocolName)
hybridRow = summaryMetrics(summaryMetrics.Model == modelName & summaryMetrics.Protocol == protocolName, :);
baselineRow = summaryMetrics(summaryMetrics.Model == "age-only baseline" & summaryMetrics.Protocol == protocolName, :);
if isempty(hybridRow) || isempty(baselineRow)
    error("BearingRUL:WebDemoMetricsMissing", "Missing hybrid or baseline summary metric rows.");
end

metrics = struct();
metrics.model = char(modelName);
metrics.protocol = char(protocolName);
metrics.weightedMAEMinutes = hybridRow.WeightedMAEMinutes(1);
metrics.baselineWeightedMAEMinutes = baselineRow.WeightedMAEMinutes(1);
metrics.weightedNormalizedMAE = hybridRow.WeightedNormalizedMAE(1);
metrics.meanPerBearingMAEMinutes = hybridRow.MeanPerBearingMAEMinutes(1);
metrics.baselineMeanPerBearingMAEMinutes = baselineRow.MeanPerBearingMAEMinutes(1);
metrics.boundary = "Recorded XJTU-SY measured-data replay, not live hardware acquisition.";

fid = fopen(metricsPath, "w");
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, "%s", jsonencode(metrics, PrettyPrint=true));
end

function renderReplayVideo(featureRows, predictionRows, videoPath, posterPath, modelName)
frameCount = 96;
slowdownFactor = 5;   % 96 distinct frames x 5 = 480 frames at 24 fps = 20 s
frameIdx = unique(round(linspace(1, height(predictionRows), frameCount)));
figureHandle = figure("Visible", "off", "Color", "w", "Position", [100 100 960 540]);
plotHandles = initializeReplayFigure(figureHandle, featureRows, predictionRows, modelName);
videoWriter = VideoWriter(videoPath, "MPEG-4");
videoWriter.FrameRate = 24;
videoWriter.Quality = 35;
open(videoWriter);
videoCleanup = onCleanup(@() close(videoWriter));

for idx = frameIdx
    updateReplayFigure(plotHandles, featureRows, predictionRows, idx, modelName);
    if idx == frameIdx(round(numel(frameIdx) * 0.62))
        exportgraphics(figureHandle, posterPath, Resolution=160);
    end
    frame = getframe(figureHandle);
    for repeatIdx = 1:slowdownFactor
        writeVideo(videoWriter, frame);
    end
end

if ~isfile(posterPath)
    exportgraphics(figureHandle, posterPath, Resolution=160);
end
close(figureHandle);
end

function plotHandles = initializeReplayFigure(figureHandle, featureRows, predictionRows, modelName)
layout = tiledlayout(figureHandle, 2, 2, "TileSpacing", "compact", "Padding", "compact");
title(layout, "Bearing RUL Digital Twin - measured XJTU-SY replay", "FontWeight", "bold", ...
    "FontSize", 18, "Color", [0.02 0.02 0.02]);

rmsAxis = nexttile(layout, 1);
plotHandles.rmsLine = plot(rmsAxis, nan, nan, "Color", [0 0.45 0.74], ...
    "LineWidth", 2.0);
hold(rmsAxis, "on");
plotHandles.rmsMarker = scatter(rmsAxis, nan, nan, 58, [0.85 0.33 0.1], "filled");
hold(rmsAxis, "off");
grid(rmsAxis, "on");
xlim(rmsAxis, [0 max(featureRows.ElapsedMinutes)]);
ylim(rmsAxis, [0 max(featureRows.MeanRMS) * 1.12]);
xlabel(rmsAxis, "Elapsed minutes");
ylabel(rmsAxis, "Mean RMS");
title(rmsAxis, "Measured vibration health input");
styleReplayAxis(rmsAxis);

rulAxis = nexttile(layout, 2);
plotHandles.actualLine = plot(rulAxis, nan, nan, "k-", ...
    "LineWidth", 2.0, "DisplayName", "Actual RUL");
hold(rulAxis, "on");
plotHandles.predictionLine = plot(rulAxis, nan, nan, ...
    "Color", [0.02 0.48 0.35], "LineWidth", 2.0, "DisplayName", modelName);
hold(rulAxis, "off");
grid(rulAxis, "on");
xlim(rulAxis, [0 max(predictionRows.ElapsedMinutes)]);
ylim(rulAxis, [0 max(predictionRows.ActualRULMinutes) * 1.08]);
xlabel(rulAxis, "Elapsed minutes");
ylabel(rulAxis, "RUL minutes");
title(rulAxis, "Online RUL estimate");
legendHandle = legend(rulAxis, "Location", "northeast");
legendHandle.TextColor = [0.02 0.02 0.02];
legendHandle.Color = [1 1 1];
legendHandle.FontSize = 10;
styleReplayAxis(rulAxis);

errorAxis = nexttile(layout, 3);
plotHandles.errorLine = plot(errorAxis, nan, nan, ...
    "Color", [0.78 0.22 0.04], "LineWidth", 2.0);
grid(errorAxis, "on");
xlim(errorAxis, [0 max(predictionRows.ElapsedMinutes)]);
ylim(errorAxis, [0 max(predictionRows.AbsoluteErrorMinutes) * 1.08]);
xlabel(errorAxis, "Elapsed minutes");
ylabel(errorAxis, "Absolute error minutes");
title(errorAxis, "Replay error");
styleReplayAxis(errorAxis);

statusAxis = nexttile(layout, 4);
axis(statusAxis, "off");
plotHandles.statusText = text(statusAxis, 0.03, 0.95, "", "FontName", "Consolas", "FontSize", 13, ...
    "FontWeight", "bold", "Color", [0.02 0.02 0.02], "VerticalAlignment", "top");
end

function updateReplayFigure(plotHandles, featureRows, predictionRows, idx, modelName)
elapsed = predictionRows.ElapsedMinutes(idx);
actualRUL = predictionRows.ActualRULMinutes(idx);
predictedRUL = predictionRows.PredictedRULMinutes(idx);
absoluteError = predictionRows.AbsoluteErrorMinutes(idx);

set(plotHandles.rmsLine, "XData", featureRows.ElapsedMinutes(1:idx), "YData", featureRows.MeanRMS(1:idx));
set(plotHandles.rmsMarker, "XData", elapsed, "YData", featureRows.MeanRMS(idx));
set(plotHandles.actualLine, "XData", predictionRows.ElapsedMinutes(1:idx), ...
    "YData", predictionRows.ActualRULMinutes(1:idx));
set(plotHandles.predictionLine, "XData", predictionRows.ElapsedMinutes(1:idx), ...
    "YData", predictionRows.PredictedRULMinutes(1:idx));
set(plotHandles.errorLine, "XData", predictionRows.ElapsedMinutes(1:idx), ...
    "YData", predictionRows.AbsoluteErrorMinutes(1:idx));

statusText = sprintf("Bearing: Bearing3_1\nModel: %s\nSnapshot: %d / %d\nElapsed: %.0f min\n" + ...
    "Predicted RUL: %.0f min\nActual RUL: %.0f min\nAbs error: %.0f min\n" + ...
    "Boundary: recorded data, not hardware-live.", ...
    modelName, idx, height(predictionRows), elapsed, predictedRUL, actualRUL, absoluteError);
set(plotHandles.statusText, "String", statusText);
drawnow limitrate;
end

function styleReplayAxis(axisHandle)
axisHandle.Color = [1 1 1];
axisHandle.XColor = [0.02 0.02 0.02];
axisHandle.YColor = [0.02 0.02 0.02];
axisHandle.GridColor = [0.55 0.55 0.55];
axisHandle.GridAlpha = 0.25;
axisHandle.FontSize = 11;
axisHandle.FontWeight = "bold";
axisHandle.Title.Color = [0.02 0.02 0.02];
axisHandle.Title.FontWeight = "bold";
axisHandle.XLabel.Color = [0.02 0.02 0.02];
axisHandle.YLabel.Color = [0.02 0.02 0.02];
end
