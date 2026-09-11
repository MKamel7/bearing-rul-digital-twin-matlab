function visual = deriveBearingVisualGeometry(geometry)
%DERIVEBEARINGVISUALGEOMETRY Convert audited bearing dimensions into plot geometry.
arguments
    geometry (1,1) struct
end

outerRaceRadiusMM = geometry.OuterRaceDiameterMM / 2;
innerRaceRadiusMM = geometry.InnerRaceDiameterMM / 2;
pitchRadiusMM = geometry.MeanDiameterMM / 2;
ballRadiusMM = geometry.BallDiameterMM / 2;
numberOfBalls = geometry.NumberOfBalls;

if pitchRadiusMM <= innerRaceRadiusMM || pitchRadiusMM >= outerRaceRadiusMM
    error("BearingRUL:InconsistentBearingGeometry", "Mean diameter must lie between inner and outer race reference diameters.");
end

anglesRad = (0:numberOfBalls-1)' * 2*pi / numberOfBalls;
ballCentersMM = [pitchRadiusMM*cos(anglesRad), pitchRadiusMM*sin(anglesRad), zeros(numberOfBalls, 1)];

visual = struct();
visual.OuterRaceRadiusMM = outerRaceRadiusMM;
visual.InnerRaceRadiusMM = innerRaceRadiusMM;
visual.PitchRadiusMM = pitchRadiusMM;
visual.BallRadiusMM = ballRadiusMM;
visual.NumberOfBalls = numberOfBalls;
visual.BallAnglesRad = anglesRad;
visual.BallCentersMM = ballCentersMM;
visual.WidthMM = geometry.BallDiameterMM;
visual.InnerVisualRadiusMM = innerRaceRadiusMM - 0.35 * ballRadiusMM;
visual.OuterVisualRadiusMM = outerRaceRadiusMM + 0.35 * ballRadiusMM;
visual.SourceAssumption = "visual approximation from published XJTU-SY raceway dimensions, not full CAD envelope dimensions";
end
