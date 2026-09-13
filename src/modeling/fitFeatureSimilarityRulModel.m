function model = fitFeatureSimilarityRulModel(trainingFeatures, featureNames, options)
%FITFEATURESIMILARITYRULMODEL Fit training-only feature-similarity RUL state.
arguments
    trainingFeatures table
    featureNames (1,:) string = ["HorizontalRMS", "VerticalRMS", "HorizontalCrestFactor", "VerticalCrestFactor"]
    options.NeighborCount (1,1) double {mustBeInteger, mustBePositive} = 25
end

requiredColumns = ["BearingID", "SnapshotIndex", featureNames];
missingColumns = setdiff(requiredColumns, string(trainingFeatures.Properties.VariableNames));
if ~isempty(missingColumns)
    error("BearingRUL:MissingTrainingFeatureColumns", ...
        "Training feature table is missing required columns: %s", strjoin(missingColumns, ", "));
end

bearingLifetimes = groupcounts(trainingFeatures, "BearingID");
bearingLifetimes.Properties.VariableNames("GroupCount") = "LifetimeMinutes";
trainLifetime = lookupBearingLifetime(bearingLifetimes, trainingFeatures.BearingID);
featureValues = table2array(trainingFeatures(:, featureNames));

featureCenter = mean(featureValues, 1, "omitnan");
featureScale = std(featureValues, 0, 1, "omitnan");
featureScale(~isfinite(featureScale) | featureScale == 0) = 1;

model = struct();
model.FeatureNames = featureNames;
model.FeatureCenter = featureCenter;
model.FeatureScale = featureScale;
model.TrainingFeatures = (featureValues - featureCenter) ./ featureScale;
model.TrainingActualRUL = trainLifetime - trainingFeatures.SnapshotIndex;
model.NeighborCount = options.NeighborCount;
end

function lifetimes = lookupBearingLifetime(bearingLifetimes, bearingIDs)
[found, idx] = ismember(bearingIDs, bearingLifetimes.BearingID);
if ~all(found)
    missingIDs = unique(bearingIDs(~found));
    error("BearingRUL:MissingBearingLifetime", ...
        "Could not find lifetimes for bearings: %s", strjoin(missingIDs, ", "));
end
lifetimes = bearingLifetimes.LifetimeMinutes(idx);
end
