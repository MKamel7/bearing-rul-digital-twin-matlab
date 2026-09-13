function model = fitHybridHealthRateRulModel(trainingFeatures, options)
%FITHYBRIDHEALTHRATERULMODEL Fit training-only hybrid age/health-rate RUL state.
arguments
    trainingFeatures table
    options.WindowSize (1,1) double {mustBeInteger, mustBePositive} = 10
    options.FailureThresholdQuantile (1,1) double {mustBeGreaterThanOrEqual(options.FailureThresholdQuantile, 0), ...
        mustBeLessThanOrEqual(options.FailureThresholdQuantile, 1)} = 0.6
    options.MinimumSlopeQuantile (1,1) double {mustBeGreaterThanOrEqual(options.MinimumSlopeQuantile, 0), ...
        mustBeLessThanOrEqual(options.MinimumSlopeQuantile, 1)} = 0.2
    options.AgeGateQuantile (1,1) double {mustBeGreaterThanOrEqual(options.AgeGateQuantile, 0), ...
        mustBeLessThanOrEqual(options.AgeGateQuantile, 1)} = 0.75
    options.HealthyGateFraction (1,1) double {mustBeNonnegative} = 0.8
end

requiredColumns = ["BearingID", "SnapshotIndex", "HorizontalRMS", "VerticalRMS"];
missingColumns = setdiff(requiredColumns, string(trainingFeatures.Properties.VariableNames));
if ~isempty(missingColumns)
    error("BearingRUL:MissingHybridTrainingColumns", ...
        "Training feature table is missing required columns: %s", strjoin(missingColumns, ", "));
end

bearingIDs = unique(trainingFeatures.BearingID, "stable");
lifetimeMinutes = zeros(numel(bearingIDs), 1);
initialHealth = zeros(numel(bearingIDs), 1);
failureHealth = zeros(numel(bearingIDs), 1);
healthSlopes = [];

for bearingIdx = 1:numel(bearingIDs)
    rows = sortrows(trainingFeatures(trainingFeatures.BearingID == bearingIDs(bearingIdx), :), "SnapshotIndex");
    health = meanRmsHealth(rows);
    windowSize = min(options.WindowSize, numel(health));
    lifetimeMinutes(bearingIdx) = height(rows);
    initialHealth(bearingIdx) = median(health(1:windowSize), "omitnan");
    failureHealth(bearingIdx) = median(health(end - windowSize + 1:end), "omitnan");
    slope = (failureHealth(bearingIdx) - initialHealth(bearingIdx)) / max(lifetimeMinutes(bearingIdx) - 1, 1);
    if isfinite(slope) && slope > 0
        healthSlopes(end + 1, 1) = slope; %#ok<AGROW>
    end
end

if isempty(healthSlopes)
    healthSlopes = eps;
end

model = struct();
model.WindowSize = options.WindowSize;
model.HealthyGateFraction = options.HealthyGateFraction;
model.BearingIDs = bearingIDs;
model.TrainingLifetimesMinutes = lifetimeMinutes;
model.InitialHealth = initialHealth;
model.FailureHealth = failureHealth;
model.FailureHealthThreshold = quantile(failureHealth, options.FailureThresholdQuantile);
model.MinimumHealthSlope = quantile(healthSlopes, options.MinimumSlopeQuantile);
model.AgeGateMinutes = quantile(lifetimeMinutes, options.AgeGateQuantile);
end

function health = meanRmsHealth(rows)
health = mean([rows.HorizontalRMS, rows.VerticalRMS], 2, "omitnan");
end
