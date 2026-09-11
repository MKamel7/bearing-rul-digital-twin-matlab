%PLOT_ENVELOPE_FEATURES Plot envelope spectrum around XJTU-SY fault frequencies.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

snapshotPath = fullfile(projectRoot, "data", "raw", "kaggle-condition1", "Bearing 1_1 .csv");
if ~isfile(snapshotPath)
    error("BearingRUL:SnapshotNotFound", "Snapshot file not found: %s", snapshotPath);
end

sampleRateHz = 25600;
data = readtable(snapshotPath, TextType="string");
geometry = readBearingGeometry(fullfile(projectRoot, "docs", "data", "xjtu_sy_bearing_geometry.csv"));
faultFrequencies = calculateBearingFaultFrequencies(geometry, 2100);
features = extractEnvelopeBandFeatures(data.Horizontal_vibration_signals, sampleRateHz, faultFrequencies, 5);

figure("Visible", "off", "Color", "white", "Position", [100 100 1100 650]);
plot(features.FrequencyHz, features.EnvelopePower, "Color", [0.0 0.33 0.62]);
hold on;
markers = [faultFrequencies.FTF 2*faultFrequencies.BSF faultFrequencies.BPFO faultFrequencies.BPFI];
labels = ["FTF" "2xBSF" "BPFO" "BPFI"];
colors = [0.40 0.40 0.40; 0.45 0.25 0.65; 0.75 0.18 0.12; 0.10 0.50 0.20];
for idx = 1:numel(markers)
    xline(markers(idx), "--", labels(idx), Color=colors(idx,:), LabelVerticalAlignment="middle", LineWidth=1.3);
end
xlim([0 250]);
grid on;
ax = gca;
ax.Color = "white";
ax.XColor = "black";
ax.YColor = "black";
ax.GridColor = [0.75 0.75 0.75];
xlabel("Envelope frequency (Hz)");
ylabel("Envelope power");
mainTitle = title("Bearing1_1 horizontal snapshot envelope spectrum");
mainTitle.Color = "black";
subTitle = subtitle("Markers from transcribed LDK UER204 geometry, Condition 1 at 2100 rpm/12 kN");
subTitle.Color = [0.2 0.2 0.2];

outDir = fullfile(projectRoot, "results", "figures");
if ~isfolder(outDir)
    mkdir(outDir);
end
outPath = fullfile(outDir, "bearing1_1_envelope_spectrum.png");
exportgraphics(gcf, outPath, "Resolution", 150);
close(gcf);

fprintf("Wrote %s\n", outPath);
fprintf("BPFO energy: %.6g, BPFI energy: %.6g, ratio: %.3f\n", features.BPFOEnergy, features.BPFIEnergy, features.BPFOToBPFIRatio);
