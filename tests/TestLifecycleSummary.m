classdef TestLifecycleSummary < matlab.unittest.TestCase
    methods (Test)
        function sortsSnapshotsByNumericFileIndex(testCase)
            lifecycleDir = string(testCase.createTemporaryFolder());
            testCase.writeSnapshot(lifecycleDir, "10.csv", [3; 4; 0; 0], [0; 0; 6; 8]);
            testCase.writeSnapshot(lifecycleDir, "1.csv", [1; 0; 0; 0], [0; 2; 0; 0]);
            testCase.writeSnapshot(lifecycleDir, "2.csv", [0; 2; 0; 0], [0; 0; 4; 0]);

            summary = summarizeXjtuSyLifecycleFolder(lifecycleDir, 4, 4);

            testCase.verifyEqual(summary.SnapshotIndex', [1 2 10]);
            testCase.verifyEqual(summary.ElapsedMinutes', [0 1 9]);
            testCase.verifyEqual(summary.FileName', ["1.csv" "2.csv" "10.csv"]);
            testCase.verifyEqual(summary.HorizontalRMS', [0.5 1.0 2.5], AbsTol=1e-12);
            testCase.verifyEqual(summary.VerticalRMS', [1.0 2.0 5.0], AbsTol=1e-12);
        end
    end

    methods (Access = private)
        function writeSnapshot(~, lifecycleDir, fileName, horizontal, vertical)
            data = table(horizontal(:), vertical(:), VariableNames=["Horizontal_vibration_signals", "Vertical_vibration_signals"]);
            writetable(data, fullfile(lifecycleDir, fileName));
        end
    end
end
