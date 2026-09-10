classdef TestBearingFrequencies < matlab.unittest.TestCase
    methods (Test)
        function calculatesConditionOneCharacteristicFrequencies(testCase)
            projectRoot = testCase.projectRoot();
            geometryPath = fullfile(projectRoot, "docs", "data", "xjtu_sy_bearing_geometry.csv");
            geometry = readBearingGeometry(geometryPath);
            frequencies = calculateBearingFaultFrequencies(geometry, 2100);
            testCase.verifyEqual(frequencies.ShaftHz, 35.0, AbsTol=1e-12);
            testCase.verifyEqual(frequencies.FTF, 13.4884, AbsTol=1e-3);
            testCase.verifyEqual(frequencies.BPFO, 107.9074, AbsTol=1e-3);
            testCase.verifyEqual(frequencies.BPFI, 172.0926, AbsTol=1e-3);
            testCase.verifyEqual(frequencies.BSF, 72.3300, AbsTol=1e-3);
        end
    end

    methods (Access = private)
        function root = projectRoot(testCase)
            testFile = string(which(class(testCase)));
            root = fileparts(fileparts(testFile));
        end
    end
end

