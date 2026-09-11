function screened = screenHealthyBaselineCandidates(features, bpfoRatioRobustZLimit)
%SCREENHEALTHYBASELINECANDIDATES Flag suspect compact-mirror baseline rows.
arguments
    features table
    bpfoRatioRobustZLimit (1,1) double {mustBePositive} = 3.5
end

required = ["BPFOToBPFIRatio"];
if ~all(ismember(required, string(features.Properties.VariableNames)))
    error("BearingRUL:MissingScreeningColumns", "Healthy-baseline screening requires BPFOToBPFIRatio.");
end

ratio = features.BPFOToBPFIRatio;
center = median(ratio, "omitnan");
rawMad = median(abs(ratio - center), "omitnan");
robustScale = 1.4826 * rawMad;
if robustScale <= eps
    robustScale = eps;
end

robustZ = abs(ratio - center) ./ robustScale;
accepted = robustZ <= bpfoRatioRobustZLimit;
status = repmat("accepted candidate healthy screen", height(features), 1);
status(~accepted) = "suspect BPFO/BPFI envelope ratio";

screened = features;
screened.BPFOToBPFIRobustZ = robustZ;
screened.BaselineAccepted = accepted;
screened.ScreeningStatus = status;
end
