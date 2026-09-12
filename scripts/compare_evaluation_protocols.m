%COMPARE_EVALUATION_PROTOCOLS Compare candidate RUL evaluation routes.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

manifestPath = fullfile(projectRoot, "docs", "data", "xjtu_sy_lifecycle_manifest.csv");
manifest = readtable(manifestPath, TextType="string");

comparison = compareEvaluationProtocols(manifest, "outer race");

outDir = fullfile(projectRoot, "results", "evaluation_protocol");
if ~isfolder(outDir)
    mkdir(outDir);
end
writetable(comparison, fullfile(outDir, "outer_race_protocol_comparison.csv"));

disp(comparison);
fprintf("Wrote %s\n", fullfile(outDir, "outer_race_protocol_comparison.csv"));
