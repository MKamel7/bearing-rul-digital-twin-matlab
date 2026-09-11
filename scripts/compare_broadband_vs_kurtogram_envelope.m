%COMPARE_BROADBAND_VS_KURTOGRAM_ENVELOPE Compare envelope extraction routes.
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

broadband = extractEnvelopeBandFeatures(data.Horizontal_vibration_signals, sampleRateHz, faultFrequencies, 5, DemodulationMethod="broadband");
kurtogramBand = extractEnvelopeBandFeatures(data.Horizontal_vibration_signals, sampleRateHz, faultFrequencies, 5, DemodulationMethod="kurtogram");

comparison = table(["broadband"; "kurtogram"], ...
    [broadband.DemodulationBandHz(1); kurtogramBand.DemodulationBandHz(1)], ...
    [broadband.DemodulationBandHz(2); kurtogramBand.DemodulationBandHz(2)], ...
    [broadband.BPFOEnergy; kurtogramBand.BPFOEnergy], ...
    [broadband.BPFIEnergy; kurtogramBand.BPFIEnergy], ...
    [broadband.BPFOToBPFIRatio; kurtogramBand.BPFOToBPFIRatio], ...
    VariableNames=["Method", "BandLowHz", "BandHighHz", "BPFOEnergy", "BPFIEnergy", "BPFOToBPFIRatio"]);

outDir = fullfile(projectRoot, "results", "envelope_comparison");
if ~isfolder(outDir)
    mkdir(outDir);
end
writetable(comparison, fullfile(outDir, "bearing1_1_broadband_vs_kurtogram.csv"));

figure("Visible", "off", "Color", "white", "Position", [100 100 1100 680]);
tiledlayout(2, 1, "TileSpacing", "compact");
nexttile;
plot(broadband.FrequencyHz, broadband.EnvelopePower, Color=[0.0 0.33 0.62]);
styleAxes();
title("Broadband Hilbert envelope", Color="black");
subtitle("No resonance-band selection before envelope extraction", Color=[0.2 0.2 0.2]);
ylabel("Envelope power");
xlim([0 300]);
markFaultLines(faultFrequencies);
nexttile;
plot(kurtogramBand.FrequencyHz, kurtogramBand.EnvelopePower, Color=[0.70 0.22 0.14]);
styleAxes();
title("Kurtogram-selected band followed by envelope spectrum", Color="black");
subtitle(sprintf("Selected band: %.1f to %.1f Hz", kurtogramBand.DemodulationBandHz(1), kurtogramBand.DemodulationBandHz(2)), Color=[0.2 0.2 0.2]);
ylabel("Envelope power");
xlabel("Envelope frequency (Hz)");
xlim([0 300]);
markFaultLines(faultFrequencies);

figureDir = fullfile(projectRoot, "results", "figures");
if ~isfolder(figureDir)
    mkdir(figureDir);
end
exportgraphics(gcf, fullfile(figureDir, "bearing1_1_broadband_vs_kurtogram_envelope.png"), Resolution=150);
close(gcf);

disp(comparison);
fprintf("Wrote %s\n", fullfile(outDir, "bearing1_1_broadband_vs_kurtogram.csv"));
fprintf("Wrote %s\n", fullfile(figureDir, "bearing1_1_broadband_vs_kurtogram_envelope.png"));

function markFaultLines(faultFrequencies)
    markers = [faultFrequencies.FTF, faultFrequencies.BPFO, faultFrequencies.BPFI, 2*faultFrequencies.BSF];
    labels = ["FTF", "BPFO", "BPFI", "2xBSF"];
    colors = [0.40 0.40 0.40; 0.75 0.18 0.12; 0.10 0.50 0.20; 0.45 0.25 0.65];
    for idx = 1:numel(markers)
        xline(markers(idx), "--", labels(idx), Color=colors(idx,:), LabelVerticalAlignment="middle", LineWidth=1.2);
    end
end

function styleAxes()
    ax = gca;
    ax.Color = "white";
    ax.XColor = "black";
    ax.YColor = "black";
    ax.GridColor = [0.75 0.75 0.75];
    grid on;
end
