classdef TestXjtuSyAudit < matlab.unittest.TestCase
    methods (Test)
        function manifestContainsFailureAuditFields(testCase)
            projectRoot = testCase.projectRoot();
            manifest = readtable(fullfile(projectRoot, "docs", "data", "xjtu_sy_lifecycle_manifest.csv"), TextType="string");
            required = ["FileCount", "LifetimeMinutes", "FaultElement"];
            testCase.verifyTrue(all(ismember(required, string(manifest.Properties.VariableNames))));

            row = manifest(manifest.BearingID == "Bearing1_1", :);
            testCase.verifyEqual(row.FileCount, 123);
            testCase.verifyEqual(row.LifetimeMinutes, 123);
            testCase.verifyEqual(row.FaultElement, "outer race");
        end

        function geometryTableContainsPublishedUer204Values(testCase)
            projectRoot = testCase.projectRoot();
            geometry = readtable(fullfile(projectRoot, "docs", "data", "xjtu_sy_bearing_geometry.csv"), TextType="string");
            testCase.verifyEqual(testCase.valueFor(geometry, "outer race diameter"), 39.80, AbsTol=0.01);
            testCase.verifyEqual(testCase.valueFor(geometry, "inner race diameter"), 29.30, AbsTol=0.01);
            testCase.verifyEqual(testCase.valueFor(geometry, "bearing mean diameter"), 34.55, AbsTol=0.01);
            testCase.verifyEqual(testCase.valueFor(geometry, "ball diameter"), 7.92, AbsTol=0.01);
            testCase.verifyEqual(testCase.valueFor(geometry, "number of balls"), 8);
            testCase.verifyEqual(testCase.valueFor(geometry, "contact angle"), 0);
            testCase.verifyEqual(testCase.valueFor(geometry, "load rating static"), 6.65, AbsTol=0.01);
            testCase.verifyEqual(testCase.valueFor(geometry, "load rating dynamic"), 12.82, AbsTol=0.01);
        end
    end

    methods (Access = private)
        function root = projectRoot(testCase)
            testFile = string(which(class(testCase)));
            root = fileparts(fileparts(testFile));
        end

        function value = valueFor(~, tableData, parameter)
            row = tableData(lower(tableData.Parameter) == parameter, :);
            value = row.Value(1);
        end
    end
end
