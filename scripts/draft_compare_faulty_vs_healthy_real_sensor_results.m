%DRAFT_COMPARE_FAULTY_VS_HEALTHY_REAL_SENSOR_RESULTS
% Review-only draft. Do not run until Mo reviews and approves.
%
% Purpose:
%   Compare accepted candidate healthy-screen features with fault-indicated
%   compact sensor rows generated from real XJTU-SY vibration CSV files.
%
% Required prior approved script:
%   scripts/draft_prepare_faulty_real_sensor_features.m
%
% Guardrails:
%   - Uses real sensor-derived feature tables only.
%   - Does not fit RUL.
%   - Does not treat failure labels as available online observations.

projectRoot = fileparts(fileparts(mfilename("fullpath")));
healthyPath = fullfile(projectRoot, "results", "healthy_baseline", "condition1_accepted_candidate_healthy_features.csv");
faultPath = fullfile(projectRoot, "results", "faulty_review", "condition1_fault_indicated_real_sensor_features.csv");

if ~isfile(healthyPath)
    error("BearingRUL:HealthyBaselineMissing", "Accepted healthy-screen feature file not found: %s", healthyPath);
end
if ~isfile(faultPath)
    error("BearingRUL:FaultFeatureFileMissing", "Fault-indicated feature file not found: %s", faultPath);
end

healthy = readtable(healthyPath, TextType="string");
faultRows = readtable(faultPath, TextType="string");
faultRows = faultRows(~faultRows.BaselineAccepted, :);

comparison = table();
comparison.Group = ["accepted candidate baseline"; "fault-indicated rejected rows"];
comparison.RowCount = [height(healthy); height(faultRows)];
comparison.HorizontalRMSMedian = [median(healthy.HorizontalRMS, "omitnan"); median(faultRows.HorizontalRMS, "omitnan")];
comparison.BPFOEnergyMedian = [median(healthy.BPFOEnergy, "omitnan"); median(faultRows.BPFOEnergy, "omitnan")];
comparison.BPFOToBPFIRatioMedian = [median(healthy.BPFOToBPFIRatio, "omitnan"); median(faultRows.BPFOToBPFIRatio, "omitnan")];

outDir = fullfile(projectRoot, "results", "faulty_review");
if ~isfolder(outDir)
    mkdir(outDir);
end
writetable(comparison, fullfile(outDir, "faulty_vs_healthy_real_sensor_comparison.csv"));

figure("Visible", "off", "Color", "white", "Position", [100 100 1000 640]);
tiledlayout(2, 1, "TileSpacing", "compact");
nexttile;
bar(categorical(comparison.Group), comparison.HorizontalRMSMedian, FaceColor=[0.0 0.33 0.62]);
styleAxes();
ylabel("Median horizontal RMS");
title("Accepted baseline versus fault-indicated compact sensor rows", Color="black");
subtitle("Real sensor features only; compact mirror is not lifecycle RUL evidence", Color=[0.2 0.2 0.2]);
nexttile;
bar(categorical(comparison.Group), comparison.BPFOToBPFIRatioMedian, FaceColor=[0.70 0.22 0.14]);
styleAxes();
ylabel("Median BPFO/BPFI ratio");
xlabel("Group");

figureDir = fullfile(projectRoot, "results", "figures");
if ~isfolder(figureDir)
    mkdir(figureDir);
end
exportgraphics(gcf, fullfile(figureDir, "faulty_vs_healthy_real_sensor_comparison.png"), Resolution=150);
close(gcf);

disp(comparison);
fprintf("Wrote %s\n", fullfile(outDir, "faulty_vs_healthy_real_sensor_comparison.csv"));
fprintf("Wrote %s\n", fullfile(figureDir, "faulty_vs_healthy_real_sensor_comparison.png"));

function styleAxes()
    ax = gca;
    ax.Color = "white";
    ax.XColor = "black";
    ax.YColor = "black";
    ax.GridColor = [0.75 0.75 0.75];
    ax.TickLabelInterpreter = "none";
    grid on;
end
