%RUN_HEALTHY_BASELINE Validate compact snapshots and export candidate healthy features.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

rawDir = fullfile(projectRoot, "data", "raw", "kaggle-condition1");
files = dir(fullfile(rawDir, "Bearing 1_*.csv"));
if isempty(files)
    error("BearingRUL:CompactMirrorMissing", "No compact mirror CSV files found in %s", rawDir);
end

snapshotFiles = strings(numel(files), 1);
for idx = 1:numel(files)
    snapshotFiles(idx) = fullfile(files(idx).folder, files(idx).name);
end

geometry = readBearingGeometry(fullfile(projectRoot, "docs", "data", "xjtu_sy_bearing_geometry.csv"));
frequencies = calculateBearingFaultFrequencies(geometry, 2100);
baseline = computeHealthyBaseline(snapshotFiles, 25600, frequencies, 32768);

outDir = fullfile(projectRoot, "results", "healthy_baseline");
if ~isfolder(outDir)
    mkdir(outDir);
end
writetable(baseline, fullfile(outDir, "condition1_candidate_healthy_features.csv"));

figure("Visible", "off", "Color", "white", "Position", [100 100 1100 620]);
tiledlayout(2, 1, "TileSpacing", "compact");
nexttile;
bar(categorical(baseline.FileName), baseline.HorizontalRMS, FaceColor=[0.0 0.33 0.62]);
styleAxes();
ylabel("Horizontal RMS");
t = title("Candidate healthy-screen RMS, compact Condition 1 snapshots");
t.Color = "black";
st = subtitle("Compact mirror snapshots only; not full lifecycle RUL evidence");
st.Color = [0.2 0.2 0.2];
nexttile;
bar(categorical(baseline.FileName), baseline.BPFOToBPFIRatio, FaceColor=[0.70 0.22 0.14]);
styleAxes();
ylabel("BPFO / BPFI envelope energy");
xlabel("Snapshot file");

figureDir = fullfile(projectRoot, "results", "figures");
if ~isfolder(figureDir)
    mkdir(figureDir);
end
exportgraphics(gcf, fullfile(figureDir, "condition1_candidate_healthy_baseline.png"), Resolution=150);
close(gcf);

disp(baseline);
fprintf("Wrote %s\n", fullfile(outDir, "condition1_candidate_healthy_features.csv"));
fprintf("Wrote %s\n", fullfile(figureDir, "condition1_candidate_healthy_baseline.png"));

function styleAxes()
    ax = gca;
    ax.Color = "white";
    ax.XColor = "black";
    ax.YColor = "black";
    ax.GridColor = [0.75 0.75 0.75];
    ax.TickLabelInterpreter = "none";
    grid on;
end
