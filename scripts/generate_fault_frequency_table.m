%GENERATE_FAULT_FREQUENCY_TABLE Write XJTU-SY characteristic frequency table.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));
geometry = readBearingGeometry(fullfile(projectRoot, "docs", "data", "xjtu_sy_bearing_geometry.csv"));
conditions = readtable(fullfile(projectRoot, "docs", "data", "xjtu_sy_lifecycle_manifest.csv"), TextType="string");
conditionRows = unique(conditions(:, ["ConditionID", "SpeedRPM", "LoadKN"]), "rows");

rows = table();
for idx = 1:height(conditionRows)
    f = calculateBearingFaultFrequencies(geometry, conditionRows.SpeedRPM(idx));
    row = table(conditionRows.ConditionID(idx), conditionRows.SpeedRPM(idx), conditionRows.LoadKN(idx), f.ShaftHz, f.FTF, f.BPFO, f.BPFI, f.BSF, ...
        VariableNames=["ConditionID", "SpeedRPM", "LoadKN", "ShaftHz", "FTF", "BPFO", "BPFI", "BSF"]);
    rows = [rows; row]; %#ok<AGROW>
end

outPath = fullfile(projectRoot, "docs", "model", "xjtu_sy_fault_frequencies.csv");
writetable(rows, outPath);
fprintf("Wrote %s\n", outPath);
disp(rows);
