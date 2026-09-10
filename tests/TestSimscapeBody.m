classdef TestSimscapeBody < matlab.unittest.TestCase
    methods (Test)
        function generatedBodyModelContainsCoreBlocks(testCase)
            projectRoot = testCase.projectRoot();
            modelPath = buildBearingBodyModel(projectRoot);
            cleaner = onCleanup(@() testCase.closeModelIfLoaded("bearing_body_baseline"));
            testCase.verifyTrue(isfile(modelPath));
            load_system(modelPath);
            blocks = string(find_system("bearing_body_baseline", SearchDepth=1));
            expected = ["bearing_body_baseline/World Frame", "bearing_body_baseline/Mechanism Configuration", "bearing_body_baseline/Solver Configuration", "bearing_body_baseline/Bearing Housing", "bearing_body_baseline/Shaft and Inner Ring", "bearing_body_baseline/Shaft Revolute Joint"];
            testCase.verifyTrue(all(ismember(expected, blocks)));
        end

        function generatedBodyModelUpdates(testCase)
            projectRoot = testCase.projectRoot();
            modelPath = buildBearingBodyModel(projectRoot);
            cleaner = onCleanup(@() testCase.closeModelIfLoaded("bearing_body_baseline"));
            load_system(modelPath);
            testCase.verifyWarningFree(@() set_param("bearing_body_baseline", "SimulationCommand", "update"));
        end
    end

    methods (Access = private)
        function root = projectRoot(testCase)
            testFile = string(which(class(testCase)));
            root = fileparts(fileparts(testFile));
        end

        function closeModelIfLoaded(~, modelName)
            if bdIsLoaded(modelName)
                close_system(modelName, 0);
            end
        end
    end
end
