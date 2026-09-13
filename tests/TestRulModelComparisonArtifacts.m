classdef TestRulModelComparisonArtifacts < matlab.unittest.TestCase
    methods (Test)
        function comparisonScriptExists(testCase)
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
            scriptPath = fullfile(projectRoot, "scripts", "run_feature_similarity_rul_model.m");
            testCase.verifyTrue(isfile(scriptPath), "Feature-similarity RUL comparison script is missing.");
        end

        function comparisonReportDocumentsProtocolsAndClaimBoundary(testCase)
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
            reportPath = fullfile(projectRoot, "docs", "reports", "rul_model_comparison_2026-09-13.md");
            testCase.assertTrue(isfile(reportPath), "RUL model comparison report is missing.");

            reportText = string(fileread(reportPath));
            testCase.verifyTrue(contains(reportText, "nested leave-one-bearing-out pilot"));
            testCase.verifyTrue(contains(reportText, "condition-held-out stress test"));
            testCase.verifyTrue(contains(reportText, "accelerated-test minutes"));
            testCase.verifyTrue(contains(reportText, "training-only"));
        end
    end
end
