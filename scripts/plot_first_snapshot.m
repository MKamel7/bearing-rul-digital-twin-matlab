%PLOT_FIRST_SNAPSHOT Plot the first downloaded XJTU-SY vibration snapshot.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

snapshotPath = fullfile(projectRoot, "data", "raw", "kaggle-condition1", "Bearing 1_1 .csv");
if ~isfile(snapshotPath)
    error("BearingRUL:SnapshotNotFound", "Snapshot file not found: %s", snapshotPath);
end

sampleRateHz = 25600;
data = readtable(snapshotPath, TextType="string");
horizontal = data.Horizontal_vibration_signals;
vertical = data.Vertical_vibration_signals;
features = summarizeVibrationSnapshot(horizontal, vertical, sampleRateHz);
timeSeconds = (0:features.SampleCount-1)' / sampleRateHz;

figure("Visible", "off", "Color", "white", "Position", [100 100 1100 650]);
tiledlayout(2, 1, "TileSpacing", "compact");
nexttile;
plot(timeSeconds, horizontal, "Color", [0.0 0.33 0.62]);
styleAxes();
ylabel("Horizontal accel.");
mainTitle = title("XJTU-SY Bearing1_1 vibration snapshot, Condition 1");
mainTitle.Color = "black";
subTitle = subtitle("Compact mirror file: one 1.28 s snapshot, not a full lifecycle");
subTitle.Color = [0.2 0.2 0.2];
nexttile;
plot(timeSeconds, vertical, "Color", [0.70 0.22 0.14]);
styleAxes();
xlabel("Time (s)");
ylabel("Vertical accel.");

outDir = fullfile(projectRoot, "results", "figures");
if ~isfolder(outDir)
    mkdir(outDir);
end
outPath = fullfile(outDir, "bearing1_1_first_snapshot.png");
exportgraphics(gcf, outPath, "Resolution", 150);
close(gcf);

fprintf("Wrote %s\n", outPath);
fprintf("Samples: %d, duration: %.2f s, horizontal RMS: %.4f, vertical RMS: %.4f\n", features.SampleCount, features.DurationSeconds, features.HorizontalRMS, features.VerticalRMS);

function styleAxes()
    ax = gca;
    ax.Color = "white";
    ax.XColor = "black";
    ax.YColor = "black";
    ax.GridColor = [0.75 0.75 0.75];
    grid on;
end

