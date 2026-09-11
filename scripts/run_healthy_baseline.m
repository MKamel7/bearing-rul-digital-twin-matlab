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
acceptedBaseline = baseline(baseline.BaselineAccepted, :);

outDir = fullfile(projectRoot, "results", "healthy_baseline");
if ~isfolder(outDir)
    mkdir(outDir);
end
writetable(baseline, fullfile(outDir, "condition1_candidate_healthy_features.csv"));
writetable(acceptedBaseline, fullfile(outDir, "condition1_accepted_candidate_healthy_features.csv"));

figure("Visible", "off", "Color", "white", "Position", [100 100 1100 620]);
tiledlayout(2, 1, "TileSpacing", "compact");
nexttile;
b = bar(categorical(baseline.FileName), baseline.HorizontalRMS);
colorBarsByScreening(b, baseline.BaselineAccepted);
styleAxes();
ylabel("Horizontal RMS");
t = title("Screened candidate healthy baseline, compact Condition 1 snapshots");
t.Color = "black";
st = subtitle("Blue rows are accepted candidates; red rows are suspect and excluded from baseline statistics");
st.Color = [0.2 0.2 0.2];
nexttile;
b = bar(categorical(baseline.FileName), baseline.BPFOToBPFIRatio);
colorBarsByScreening(b, baseline.BaselineAccepted);
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
fprintf("Wrote %s\n", fullfile(outDir, "condition1_accepted_candidate_healthy_features.csv"));
fprintf("Wrote %s\n", fullfile(figureDir, "condition1_candidate_healthy_baseline.png"));
fprintf("Accepted baseline candidates: %d of %d\n", height(acceptedBaseline), height(baseline));

function colorBarsByScreening(barHandle, accepted)
    colors = repmat([0.70 0.22 0.14], numel(accepted), 1);
    colors(accepted, :) = repmat([0.0 0.33 0.62], nnz(accepted), 1);
    barHandle.FaceColor = "flat";
    barHandle.CData = colors;
end

function styleAxes()
    ax = gca;
    ax.Color = "white";
    ax.XColor = "black";
    ax.YColor = "black";
    ax.GridColor = [0.75 0.75 0.75];
    ax.TickLabelInterpreter = "none";
    grid on;
end
