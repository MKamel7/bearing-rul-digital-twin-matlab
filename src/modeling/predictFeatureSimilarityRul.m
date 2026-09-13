function predictedRUL = predictFeatureSimilarityRul(model, liveFeatures)
%PREDICTFEATURESIMILARITYRUL Predict RUL for incoming feature rows.
arguments
    model (1,1) struct
    liveFeatures table
end

requiredModelFields = ["FeatureNames", "FeatureCenter", "FeatureScale", "TrainingFeatures", ...
    "TrainingActualRUL", "NeighborCount"];
missingModelFields = setdiff(requiredModelFields, string(fieldnames(model)));
if ~isempty(missingModelFields)
    error("BearingRUL:InvalidFeatureSimilarityModel", ...
        "Model is missing required fields: %s", strjoin(missingModelFields, ", "));
end

missingFeatureColumns = setdiff(model.FeatureNames, string(liveFeatures.Properties.VariableNames));
if ~isempty(missingFeatureColumns)
    error("BearingRUL:MissingLiveFeatureColumns", ...
        "Live feature table is missing required columns: %s", strjoin(missingFeatureColumns, ", "));
end

liveValues = table2array(liveFeatures(:, model.FeatureNames));
scaledLiveFeatures = (liveValues - model.FeatureCenter) ./ model.FeatureScale;
predictedRUL = zeros(size(scaledLiveFeatures, 1), 1);
actualNeighborCount = min(model.NeighborCount, numel(model.TrainingActualRUL));

for rowIdx = 1:size(scaledLiveFeatures, 1)
    distances = sum((model.TrainingFeatures - scaledLiveFeatures(rowIdx, :)).^2, 2);
    [~, nearestIdx] = mink(distances, actualNeighborCount);
    predictedRUL(rowIdx) = max(median(model.TrainingActualRUL(nearestIdx), "omitnan"), 0);
end
end
