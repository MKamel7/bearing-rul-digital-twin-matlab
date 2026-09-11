function simOut = simulateBearingBodyModel(projectRoot)
%SIMULATEBEARINGBODYMODEL Build and run the reduced Simscape body model.
arguments
    projectRoot (1,1) string
end

modelPath = buildBearingBodyModel(projectRoot);
load_system(modelPath);
simOut = sim("bearing_body_baseline", StopTime="1.28");
end
