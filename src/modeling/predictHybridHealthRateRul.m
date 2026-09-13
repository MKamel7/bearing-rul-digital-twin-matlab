function predictedRUL = predictHybridHealthRateRul(model, liveFeatureRows)
%PREDICTHYBRIDHEALTHRATERUL Predict RUL from chronological measured prefixes.
arguments
    model (1,1) struct
    liveFeatureRows table
end

requiredModelFields = ["WindowSize", "HealthyGateFraction", "TrainingLifetimesMinutes", ...
    "FailureHealthThreshold", "MinimumHealthSlope", "AgeGateMinutes"];
missingModelFields = setdiff(requiredModelFields, string(fieldnames(model)));
if ~isempty(missingModelFields)
    error("BearingRUL:InvalidHybridHealthRateModel", ...
        "Model is missing required fields: %s", strjoin(missingModelFields, ", "));
end

requiredColumns = ["SnapshotIndex", "HorizontalRMS", "VerticalRMS"];
missingColumns = setdiff(requiredColumns, string(liveFeatureRows.Properties.VariableNames));
if ~isempty(missingColumns)
    error("BearingRUL:MissingHybridLiveColumns", ...
        "Live feature table is missing required columns: %s", strjoin(missingColumns, ", "));
end

rows = sortrows(liveFeatureRows, "SnapshotIndex");
health = mean([rows.HorizontalRMS, rows.VerticalRMS], 2, "omitnan");
predictedRUL = zeros(height(rows), 1);

for rowIdx = 1:height(rows)
    prefixHealth = health(1:rowIdx);
    initialWindow = min(model.WindowSize, rowIdx);
    currentWindowStart = max(1, rowIdx - model.WindowSize + 1);
    initialHealth = median(prefixHealth(1:initialWindow), "omitnan");
    currentHealth = median(prefixHealth(currentWindowStart:rowIdx), "omitnan");
    elapsedRows = max(rowIdx - 1, 1);
    healthSlope = max((currentHealth - initialHealth) / elapsedRows, model.MinimumHealthSlope);
    healthRateRUL = max((model.FailureHealthThreshold - currentHealth) / healthSlope, 0);

    snapshotIndex = rows.SnapshotIndex(rowIdx);
    ageOnlyRUL = median(max(model.TrainingLifetimesMinutes - snapshotIndex, 0), "omitnan");
    healthyDenominator = max(model.FailureHealthThreshold - initialHealth, eps);
    healthFraction = (currentHealth - initialHealth) / healthyDenominator;
    useHealthRate = snapshotIndex >= model.AgeGateMinutes && healthFraction < model.HealthyGateFraction;

    if useHealthRate
        predictedRUL(rowIdx) = max(ageOnlyRUL, healthRateRUL);
    else
        predictedRUL(rowIdx) = ageOnlyRUL;
    end
end
end
