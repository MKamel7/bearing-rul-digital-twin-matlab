projectRoot = fileparts(fileparts(mfilename("fullpath")));
cd(projectRoot);
addpath(genpath(fullfile(projectRoot, "src")));

testFiles = [
    "tests/TestBearingManifest.m"
    "tests/TestBearingFrequencies.m"
    "tests/TestBearingVisualGeometry.m"
    "tests/TestSnapshotFeatures.m"
    "tests/TestDefectExcitation.m"
    "tests/TestAgeOnlyRulBaseline.m"
    "tests/TestFeatureSimilarityRulModel.m"
    "tests/TestFeatureSimilarityFitPredict.m"
    "tests/TestHybridHealthRateRulModel.m"
];

suites = cell(numel(testFiles), 1);
for idx = 1:numel(testFiles)
    suites{idx} = matlab.unittest.TestSuite.fromFile(fullfile(projectRoot, testFiles(idx)));
end

suite = [suites{:}];
results = run(suite);
assertSuccess(results);
