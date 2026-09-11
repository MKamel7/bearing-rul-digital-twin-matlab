classdef TestXjtuSySnapshotReader < matlab.unittest.TestCase
    methods (Test)
        function acceptsStructurallyValidTwoChannelSnapshot(testCase)
            snapshotPath = testCase.writeSnapshot([1; 2; 3; 4], [-1; -2; -3; -4]);

            snapshot = readXjtuSySnapshot(snapshotPath, 4);

            testCase.verifyEqual(snapshot.SampleCount, 4);
            testCase.verifyEqual(snapshot.Horizontal, [1; 2; 3; 4]);
            testCase.verifyEqual(snapshot.Vertical, [-1; -2; -3; -4]);
            testCase.verifyEqual(snapshot.ValidityStatus, "valid");
        end

        function rejectsSnapshotWithMissingChannelColumn(testCase)
            tmpDir = string(testCase.createTemporaryFolder());
            snapshotPath = fullfile(tmpDir, "missing_channel.csv");
            data = table([1; 2; 3; 4], VariableNames="Horizontal_vibration_signals");
            writetable(data, snapshotPath);

            testCase.verifyError(@() readXjtuSySnapshot(snapshotPath, 4), "BearingRUL:MissingSnapshotColumns");
        end

        function rejectsUnexpectedSampleCount(testCase)
            snapshotPath = testCase.writeSnapshot([1; 2; 3], [-1; -2; -3]);

            testCase.verifyError(@() readXjtuSySnapshot(snapshotPath, 4), "BearingRUL:UnexpectedSampleCount");
        end
    end

    methods (Access = private)
        function snapshotPath = writeSnapshot(testCase, horizontal, vertical)
            tmpDir = string(testCase.createTemporaryFolder());
            snapshotPath = fullfile(tmpDir, "snapshot.csv");
            data = table(horizontal(:), vertical(:), VariableNames=["Horizontal_vibration_signals", "Vertical_vibration_signals"]);
            writetable(data, snapshotPath);
        end
    end
end
