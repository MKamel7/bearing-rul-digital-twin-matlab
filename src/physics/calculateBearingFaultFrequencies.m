function frequencies = calculateBearingFaultFrequencies(geometry, shaftSpeedRPM)
%CALCULATEBEARINGFAULTFREQUENCIES Compute ideal bearing characteristic frequencies.
arguments
    geometry (1,1) struct
    shaftSpeedRPM (1,1) double {mustBePositive}
end

shaftHz = shaftSpeedRPM / 60;
ballToMeanRatio = geometry.BallDiameterMM / geometry.MeanDiameterMM;
contactCos = cosd(geometry.ContactAngleDeg);
ratioTerm = ballToMeanRatio * contactCos;

frequencies = struct();
frequencies.ShaftHz = shaftHz;
frequencies.FTF = 0.5 * shaftHz * (1 - ratioTerm);
frequencies.BPFO = geometry.NumberOfBalls / 2 * shaftHz * (1 - ratioTerm);
frequencies.BPFI = geometry.NumberOfBalls / 2 * shaftHz * (1 + ratioTerm);
frequencies.BSF = geometry.MeanDiameterMM / (2 * geometry.BallDiameterMM) * shaftHz * (1 - ratioTerm^2);
end
