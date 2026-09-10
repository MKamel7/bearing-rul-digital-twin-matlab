classdef TestDefectExcitation < matlab.unittest.TestCase
    methods (Test)
        function generatesPeriodicImpactTrain(testCase)
            excitation = generateLocalizedDefectExcitation(1000, 1.0, 10, 120, 35);
            testCase.verifyEqual(numel(excitation.TimeSeconds), 1000);
            testCase.verifyEqual(numel(excitation.Signal), 1000);
            testCase.verifyEqual(nnz(excitation.ImpulseTrain), 10);
            impulseTimes = excitation.TimeSeconds(excitation.ImpulseTrain > 0);
            testCase.verifyEqual(impulseTimes(1), 0, AbsTol=1e-12);
            testCase.verifyEqual(median(diff(impulseTimes)), 0.1, AbsTol=1e-12);
            testCase.verifyGreaterThan(max(abs(excitation.Signal)), 0.5);
        end
    end
end
