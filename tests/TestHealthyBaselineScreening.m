classdef TestHealthyBaselineScreening < matlab.unittest.TestCase
    methods (Test)
        function flagsRobustEnvelopeRatioOutlier(testCase)
            features = table(["a"; "b"; "c"; "d"], [1.0; 1.1; 1.2; 15.0], ...
                VariableNames=["FileName", "BPFOToBPFIRatio"]);

            screened = screenHealthyBaselineCandidates(features, 3.5);

            testCase.verifyTrue(all(screened.BaselineAccepted(1:3)));
            testCase.verifyFalse(screened.BaselineAccepted(4));
            testCase.verifyEqual(screened.ScreeningStatus(4), "suspect BPFO/BPFI envelope ratio");
            testCase.verifyGreaterThan(screened.BPFOToBPFIRobustZ(4), 3.5);
        end

        function keepsStableRowsAccepted(testCase)
            features = table(["a"; "b"; "c"; "d"], [0.9; 1.0; 1.1; 1.2], ...
                VariableNames=["FileName", "BPFOToBPFIRatio"]);

            screened = screenHealthyBaselineCandidates(features, 3.5);

            testCase.verifyTrue(all(screened.BaselineAccepted));
            testCase.verifyTrue(all(screened.ScreeningStatus == "accepted candidate healthy screen"));
        end
    end
end
