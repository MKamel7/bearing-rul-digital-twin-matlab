classdef TestLiveRulReplayArtifacts < matlab.unittest.TestCase
    methods (Test)
        function liveReplayScriptExists(testCase)
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
            scriptPath = fullfile(projectRoot, "scripts", "show_live_rul_replay.m");
            testCase.verifyTrue(isfile(scriptPath), "Live measured-data RUL replay script is missing.");
        end

        function liveReplayScriptStatesMeasuredReplayBoundary(testCase)
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
            scriptPath = fullfile(projectRoot, "scripts", "show_live_rul_replay.m");
            testCase.assertTrue(isfile(scriptPath), "Live measured-data RUL replay script is missing.");

            scriptText = string(fileread(scriptPath));
            testCase.verifyTrue(contains(scriptText, "measured-data replay"));
            testCase.verifyTrue(contains(scriptText, "not a live hardware sensor stream"));
        end

        function liveReplayComputesPredictionsOnline(testCase)
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
            scriptPath = fullfile(projectRoot, "scripts", "show_live_rul_replay.m");
            testCase.assertTrue(isfile(scriptPath), "Live measured-data RUL replay script is missing.");

            scriptText = string(fileread(scriptPath));
            testCase.verifyTrue(contains(scriptText, "fitFeatureSimilarityRulModel"));
            testCase.verifyTrue(contains(scriptText, "predictFeatureSimilarityRul"));
            testCase.verifyFalse(contains(scriptText, "outer_race_rul_model_predictions.csv"));
        end
    end
end
