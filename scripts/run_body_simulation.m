%RUN_BODY_SIMULATION Build, run and export the reduced Simscape bearing body.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

simOut = simulateBearingBodyModel(string(projectRoot));
load_system(fullfile(projectRoot, "models", "bearing_body_baseline.slx"));
open_system("bearing_body_baseline");
open_system("bearing_body_baseline/Localized Defect Excitation");

outDir = fullfile(projectRoot, "results", "figures");
if ~isfolder(outDir)
    mkdir(outDir);
end
print("-sbearing_body_baseline", "-dpng", "-r150", fullfile(outDir, "bearing_body_baseline_model.png"));
print("-sbearing_body_baseline/Localized Defect Excitation", "-dpng", "-r150", fullfile(outDir, "localized_defect_subsystem.png"));

fprintf("Simscape body simulation stop event: %s\n", simOut.SimulationMetadata.ExecutionInfo.StopEvent);
fprintf("Final simulation time: %.2f s\n", simOut.tout(end));
