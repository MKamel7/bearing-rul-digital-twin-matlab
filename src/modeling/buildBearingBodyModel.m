function modelPath = buildBearingBodyModel(projectRoot)
%BUILDBEARINGBODYMODEL Create a reduced Simscape Multibody bearing body model.
arguments
    projectRoot (1,1) string
end

modelName = "bearing_body_baseline";
modelDir = fullfile(projectRoot, "models");
if ~isfolder(modelDir)
    mkdir(modelDir);
end
modelPath = fullfile(modelDir, modelName + ".slx");

if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

load_system("sm_lib");
load_system("nesl_utility");
new_system(modelName);
open_system(modelName);

add_block("sm_lib/Frames and Transforms/World Frame", modelName + "/World Frame", Position=[80 110 150 170]);
add_block("sm_lib/Utilities/Mechanism Configuration", modelName + "/Mechanism Configuration", Position=[80 250 150 310]);
add_block(sprintf("nesl_utility/Solver\nConfiguration"), modelName + "/Solver Configuration", Position=[80 360 150 420]);
add_block("sm_lib/Joints/Revolute Joint", modelName + "/Shaft Revolute Joint", Position=[250 120 330 190]);
add_block("sm_lib/Body Elements/Cylindrical Solid", modelName + "/Shaft and Inner Ring", Position=[440 105 560 195]);
add_block("sm_lib/Body Elements/Cylindrical Solid", modelName + "/Bearing Housing", Position=[440 245 560 335]);

note1 = Simulink.Annotation(modelName, "Reduced XJTU-SY LDK UER204 bearing body: housing support plus rotating shaft/inner ring. Defect excitation and transfer-path identification are intentionally separate later steps.");
note1.Position = [70 20 610 75];
note1.FontSize = 11;
note2 = Simulink.Annotation(modelName, "Shaft speed and fault-frequency forcing will enter here after validation of BPFO/BPFI/BSF/FTF calculations.");
note2.Position = [610 120 880 205];
note2.FontSize = 10;
note3 = Simulink.Annotation(modelName, "Housing response is an identified reduced body, not the complete laboratory rig.");
note3.Position = [610 250 880 320];
note3.FontSize = 10;

world = get_param(modelName + "/World Frame", "PortHandles");
joint = get_param(modelName + "/Shaft Revolute Joint", "PortHandles");
shaft = get_param(modelName + "/Shaft and Inner Ring", "PortHandles");
solver = get_param(modelName + "/Solver Configuration", "PortHandles");
add_line(modelName, world.RConn(1), joint.LConn(1), "autorouting", "on");
add_line(modelName, joint.RConn(1), shaft.RConn(1), "autorouting", "on");
add_line(modelName, solver.RConn(1), world.RConn(1), "autorouting", "on");

set_param(modelName, Solver="ode15s", StopTime="1.28");
save_system(modelName, modelPath);
end
