%PLOT_OFFICIAL_LIFECYCLE_TREND Plot one official XJTU-SY lifecycle trend.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

bearingID = "Bearing1_1";
conditionFolder = "35Hz12kN";
sampleRateHz = 25600;
expectedSampleCount = 32768;

officialRoot = fullfile(projectRoot, "data", "raw", "xjtu-sy-official", "XJTU-SY_Bearing_Datasets");
lifecycleDir = fullfile(officialRoot, conditionFolder, bearingID);
if ~isfolder(lifecycleDir)
    error("BearingRUL:OfficialLifecycleMissing", "Official lifecycle folder not found: %s", lifecycleDir);
end

summary = summarizeXjtuSyLifecycleFolder(lifecycleDir, sampleRateHz, expectedSampleCount);

outDir = fullfile(projectRoot, "results", "official_lifecycle");
if ~isfolder(outDir)
    mkdir(outDir);
end
writetable(summary, fullfile(outDir, bearingID + "_lifecycle_summary.csv"));

figure("Visible", "off", "Color", "white", "Position", [100 100 1100 720]);
tiledlayout(2, 1, "TileSpacing", "compact");
nexttile;
plot(summary.ElapsedMinutes, summary.HorizontalRMS, "Color", [0.0 0.33 0.62], "LineWidth", 1.2);
hold on;
plot(summary.ElapsedMinutes, summary.VerticalRMS, "Color", [0.70 0.22 0.14], "LineWidth", 1.2);
styleAxes();
ylabel("RMS acceleration");
legend(["Horizontal", "Vertical"], Location="northwest");
title("Official XJTU-SY lifecycle RMS trend, Bearing1_1", Color="black");
subtitle("One 1.28 s vibration snapshot per minute; no continuous concatenation", Color=[0.2 0.2 0.2]);

nexttile;
plot(summary.ElapsedMinutes, summary.HorizontalCrestFactor, "Color", [0.0 0.33 0.62], "LineWidth", 1.2);
hold on;
plot(summary.ElapsedMinutes, summary.VerticalCrestFactor, "Color", [0.70 0.22 0.14], "LineWidth", 1.2);
styleAxes();
xlabel("Elapsed time (min)");
ylabel("Crest factor");
legend(["Horizontal", "Vertical"], Location="northwest");

figureDir = fullfile(projectRoot, "results", "figures");
if ~isfolder(figureDir)
    mkdir(figureDir);
end
figurePath = fullfile(figureDir, bearingID + "_official_lifecycle_trend.png");
exportgraphics(gcf, figurePath, Resolution=150);
close(gcf);

fprintf("Wrote %s\n", fullfile(outDir, bearingID + "_lifecycle_summary.csv"));
fprintf("Wrote %s\n", figurePath);
fprintf("%s snapshots: %d, elapsed minutes: %.0f to %.0f\n", bearingID, height(summary), min(summary.ElapsedMinutes), max(summary.ElapsedMinutes));

function styleAxes()
    ax = gca;
    ax.Color = "white";
    ax.XColor = "black";
    ax.YColor = "black";
    ax.GridColor = [0.75 0.75 0.75];
    grid on;
end
