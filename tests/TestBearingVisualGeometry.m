classdef TestBearingVisualGeometry < matlab.unittest.TestCase
    methods (Test)
        function derivesRadiiAndBallCentersFromAuditedGeometry(testCase)
            projectRoot = testCase.projectRoot();
            geometry = readBearingGeometry(fullfile(projectRoot, "docs", "data", "xjtu_sy_bearing_geometry.csv"));

            visual = deriveBearingVisualGeometry(geometry);

            testCase.verifyEqual(visual.OuterRaceRadiusMM, 19.90, AbsTol=1e-12);
            testCase.verifyEqual(visual.InnerRaceRadiusMM, 14.65, AbsTol=1e-12);
            testCase.verifyEqual(visual.PitchRadiusMM, 17.275, AbsTol=1e-12);
            testCase.verifyEqual(visual.BallRadiusMM, 3.96, AbsTol=1e-12);
            testCase.verifySize(visual.BallCentersMM, [8 3]);
            radialDistance = hypot(visual.BallCentersMM(:,1), visual.BallCentersMM(:,2));
            testCase.verifyEqual(radialDistance, repmat(17.275, 8, 1), AbsTol=1e-10);
            testCase.verifyTrue(all(visual.BallCentersMM(:,3) == 0));
        end

        function rejectsMeanDiameterOutsideRacewayBounds(testCase)
            geometry = struct("OuterRaceDiameterMM", 39.80, "InnerRaceDiameterMM", 29.30, ...
                "MeanDiameterMM", 60.0, "BallDiameterMM", 7.92, "NumberOfBalls", 8, "ContactAngleDeg", 0);

            testCase.verifyError(@() deriveBearingVisualGeometry(geometry), "BearingRUL:InconsistentBearingGeometry");
        end
    end

    methods (Access = private)
        function root = projectRoot(testCase)
            testFile = string(which(class(testCase)));
            root = fileparts(fileparts(testFile));
        end
    end
end
