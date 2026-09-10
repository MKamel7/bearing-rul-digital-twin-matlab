%PLOT_DEFECT_EXCITATION_DEMO Plot prototype localized-defect excitation signal.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));
geometry = readBearingGeometry(fullfile(projectRoot, "docs", "data", "xjtu_sy_bearing_geometry.csv"));
faultFrequencies = calculateBearingFaultFrequencies(geometry, 2100);
excitation = generateLocalizedDefectExcitation(25600, 0.12, faultFrequencies.BPFO, 3000, 850);

figure("Visible", "off", "Color", "white", "Position", [100 100 1050 620]);
tiledlayout(2, 1, "TileSpacing", "compact");
nexttile;
stem(excitation.TimeSeconds, excitation.ImpulseTrain, Marker="none", Color=[0.15 0.15 0.15]);
xlim([0 0.12]);
ylabel("Impact train");
styleAxes();
mainTitle = title("Prototype localized outer-race defect excitation");
mainTitle.Color = "black";
subTitle = subtitle("Periodic BPFO impact timing before transfer-path identification");
subTitle.Color = [0.2 0.2 0.2];
nexttile;
plot(excitation.TimeSeconds, excitation.Signal, Color=[0.75 0.18 0.12]);
xlim([0 0.12]);
xlabel("Time (s)");
ylabel("Damped resonance");
styleAxes();

outDir = fullfile(projectRoot, "results", "figures");
if ~isfolder(outDir)
    mkdir(outDir);
end
outPath = fullfile(outDir, "localized_defect_excitation_demo.png");
exportgraphics(gcf, outPath, "Resolution", 150);
close(gcf);
fprintf("Wrote %s\n", outPath);
fprintf("BPFO used: %.4f Hz, resonance: %.1f Hz\n", excitation.FaultFrequencyHz, excitation.ResonanceHz);

function styleAxes()
    ax = gca;
    ax.Color = "white";
    ax.XColor = "black";
    ax.YColor = "black";
    ax.GridColor = [0.75 0.75 0.75];
    grid on;
end
