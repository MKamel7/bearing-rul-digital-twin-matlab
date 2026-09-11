classdef TestSimscapeBody < matlab.unittest.TestCase
    methods (Test)
        function generatedBodyModelContainsCoreBlocks(testCase)
            projectRoot = testCase.projectRoot();
            modelPath = buildBearingBodyModel(projectRoot);
            cleaner = onCleanup(@() testCase.closeModelIfLoaded("bearing_body_baseline"));
            testCase.verifyTrue(isfile(modelPath));
            load_system(modelPath);
            blocks = string(find_system("bearing_body_baseline", SearchDepth=1));
            expected = ["bearing_body_baseline/World Frame", "bearing_body_baseline/Mechanism Configuration", "bearing_body_baseline/Solver Configuration", "bearing_body_baseline/Bearing Housing", "bearing_body_baseline/Shaft and Inner Ring", "bearing_body_baseline/Shaft Revolute Joint", "bearing_body_baseline/Localized Defect Excitation"];
            testCase.verifyTrue(all(ismember(expected, blocks)));
        end

        function shaftJointTargetsConditionOneSpeed(testCase)
            projectRoot = testCase.projectRoot();
            modelPath = buildBearingBodyModel(projectRoot);
            cleaner = onCleanup(@() testCase.closeModelIfLoaded("bearing_body_baseline"));
            load_system(modelPath);

            jointPath = "bearing_body_baseline/Shaft Revolute Joint";
            testCase.verifyEqual(string(get_param(jointPath, "VelocityTargetSpecify")), "on");
            testCase.verifyEqual(str2double(get_param(jointPath, "VelocityTargetValue")), 12600, AbsTol=1e-9);
            testCase.verifyEqual(string(get_param(jointPath, "VelocityTargetValueUnits")), "deg/s");
        end

        function generatedBodyModelUpdates(testCase)
            projectRoot = testCase.projectRoot();
            modelPath = buildBearingBodyModel(projectRoot);
            cleaner = onCleanup(@() testCase.closeModelIfLoaded("bearing_body_baseline"));
            load_system(modelPath);
            testCase.verifyWarningFree(@() set_param("bearing_body_baseline", "SimulationCommand", "update"));
        end

        function generatedBodyModelSimulatesToFinalTime(testCase)
            projectRoot = testCase.projectRoot();
            simOut = simulateBearingBodyModel(projectRoot);
            cleaner = onCleanup(@() testCase.closeModelIfLoaded("bearing_body_baseline"));

            testCase.verifyEqual(string(simOut.SimulationMetadata.ExecutionInfo.StopEvent), "ReachedStopTime");
            testCase.verifyEqual(simOut.tout(end), 1.28, AbsTol=1e-9);
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

