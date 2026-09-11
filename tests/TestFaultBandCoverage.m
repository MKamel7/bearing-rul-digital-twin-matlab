classdef TestFaultBandCoverage < matlab.unittest.TestCase
    methods (Test)
        function bandsCoverManifestFaultElements(testCase)
            projectRoot = testCase.projectRoot();
            manifest = readtable(fullfile(projectRoot, "docs", "data", "xjtu_sy_lifecycle_manifest.csv"), TextType="string");
            geometry = readBearingGeometry(fullfile(projectRoot, "docs", "data", "xjtu_sy_bearing_geometry.csv"));
            frequencies = calculateBearingFaultFrequencies(geometry, 2100);

            bands = buildBearingFaultBandTable(frequencies);

            manifestElements = testCase.normalizeFaultElements(manifest.FaultElement);
            representedElements = unique(bands.FaultElement);
            testCase.verifyTrue(all(ismember(manifestElements, representedElements)));
        end

        function ballBandUsesSecondBsfHarmonic(testCase)
            frequencies = struct("ShaftHz", 35, "FTF", 13.4884, "BPFO", 107.9074, "BPFI", 172.0926, "BSF", 72.3300);

            bands = buildBearingFaultBandTable(frequencies);
            ballBand = bands(bands.BandName == "Ball2BSF", :);

            testCase.verifyEqual(height(ballBand), 1);
            testCase.verifyEqual(ballBand.CenterHz, 2 * frequencies.BSF, AbsTol=1e-12);
        end
    end

    methods (Access = private)
        function root = projectRoot(testCase)
            testFile = string(which(class(testCase)));
            root = fileparts(fileparts(testFile));
        end

        function elements = normalizeFaultElements(~, faultElement)
            elements = strings(0, 1);
            for idx = 1:numel(faultElement)
                tokens = split(lower(faultElement(idx)), [",", " and "]);
                tokens = strtrim(tokens);
                tokens(tokens == "") = [];
                elements = [elements; tokens]; %#ok<AGROW>
            end
            elements = unique(elements);
        end
    end
end
