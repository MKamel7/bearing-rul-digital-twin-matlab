classdef TestHybridHealthRateArtifacts < matlab.unittest.TestCase
    methods (Test)
        function comparisonScriptExists(testCase)
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
            scriptPath = fullfile(projectRoot, "scripts", "run_hybrid_health_rate_rul_model.m");

            testCase.verifyTrue(isfile(scriptPath), "Hybrid health-rate RUL comparison script is missing.");
        end

        function finalReportDocumentsHybridBoundary(testCase)
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
            reportPath = fullfile(projectRoot, "docs", "reports", "hybrid_health_rate_rul_2026-09-13.md");

            testCase.verifyTrue(isfile(reportPath), "Hybrid health-rate RUL report is missing.");
        end
    end
end
