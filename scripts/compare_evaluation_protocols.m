%COMPARE_EVALUATION_PROTOCOLS Compare candidate RUL evaluation routes.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

manifestPath = fullfile(projectRoot, "docs", "data", "xjtu_sy_lifecycle_manifest.csv");
manifest = readtable(manifestPath, TextType="string");

comparison = compareEvaluationProtocols(manifest, "outer race");
nestedFolds = buildEvaluationFolds(manifest, "outer race", "nested leave-one-bearing-out pilot");
conditionHeldOutFolds = buildEvaluationFolds(manifest, "outer race", "condition-held-out stress test");

outDir = fullfile(projectRoot, "results", "evaluation_protocol");
if ~isfolder(outDir)
    mkdir(outDir);
end
writetable(comparison, fullfile(outDir, "outer_race_protocol_comparison.csv"));
writetable(nestedFolds, fullfile(outDir, "outer_race_nested_leave_one_bearing_out_folds.csv"));
writetable(conditionHeldOutFolds, fullfile(outDir, "outer_race_condition_held_out_folds.csv"));

disp(comparison);
fprintf("Wrote %s\n", fullfile(outDir, "outer_race_protocol_comparison.csv"));
fprintf("Wrote %s\n", fullfile(outDir, "outer_race_nested_leave_one_bearing_out_folds.csv"));
fprintf("Wrote %s\n", fullfile(outDir, "outer_race_condition_held_out_folds.csv"));
