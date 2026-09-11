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
load_system("simulink");
new_system(modelName);
open_system(modelName);

add_block("sm_lib/Frames and Transforms/World Frame", modelName + "/World Frame", Position=[80 110 150 170]);
add_block("sm_lib/Utilities/Mechanism Configuration", modelName + "/Mechanism Configuration", Position=[80 250 150 310]);
add_block(sprintf("nesl_utility/Solver\nConfiguration"), modelName + "/Solver Configuration", Position=[80 360 150 420]);
add_block("sm_lib/Joints/Revolute Joint", modelName + "/Shaft Revolute Joint", Position=[250 120 330 190]);
add_block("sm_lib/Body Elements/Cylindrical Solid", modelName + "/Shaft and Inner Ring", Position=[440 105 560 195]);
add_block("sm_lib/Body Elements/Cylindrical Solid", modelName + "/Bearing Housing", Position=[440 245 560 335]);
add_block("simulink/Ports & Subsystems/Subsystem", modelName + "/Localized Defect Excitation", Position=[735 95 965 215]);
configureDefectSubsystem(modelName + "/Localized Defect Excitation");
set_param(modelName + "/Shaft Revolute Joint", VelocityTargetSpecify="on", VelocityTargetValue="12600", VelocityTargetValueUnits="deg/s");

note1 = Simulink.Annotation(modelName, "Reduced XJTU-SY LDK UER204 bearing body: housing support plus rotating shaft/inner ring. Defect excitation and transfer-path identification are intentionally separate later steps.");
note1.Position = [70 20 610 75];
note1.FontSize = 11;
noteSpeed = Simulink.Annotation(modelName, "Shaft speed target: 2100 rpm = 12600 deg/s for XJTU-SY Condition 1.");
noteSpeed.Position = [250 205 590 245];
noteSpeed.FontSize = 10;
note2 = Simulink.Annotation(modelName, "Localized defect excitation currently generates periodic impact timing plus damped-resonance shaping. It is not yet an identified force applied to the body.");
note2.Position = [735 230 1120 305];
note2.FontSize = 10;
note3 = Simulink.Annotation(modelName, "Housing response is an identified reduced body, not the complete laboratory rig.");
note3.Position = [610 330 1010 400];
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

function configureDefectSubsystem(subsystemPath)
    try
        delete_line(subsystemPath, "In1/1", "Out1/1");
    catch
    end
    for blockName = ["In1", "Out1"]
        blockPath = subsystemPath + "/" + blockName;
        if getSimulinkBlockHandle(blockPath) > 0
            delete_block(blockPath);
        end
    end

    add_block("simulink/Sources/Pulse Generator", subsystemPath + "/Impact Timing BPFO", Position=[70 65 165 105]);
    add_block("simulink/Continuous/Transfer Fcn", subsystemPath + "/Damped Housing Resonance", Position=[235 60 365 110]);
    add_block("simulink/Math Operations/Gain", subsystemPath + "/Impact Amplitude", Position=[430 67 500 103]);
    add_block("simulink/Sinks/Terminator", subsystemPath + "/Force Injection Later", Position=[565 73 590 97]);

    set_param(subsystemPath + "/Impact Timing BPFO", Amplitude="1", Period="1/107.9074", PulseWidth="4", PhaseDelay="0");
    set_param(subsystemPath + "/Damped Housing Resonance", Numerator="[0 1]", Denominator="[1 70 4*pi^2*3000^2]");
    set_param(subsystemPath + "/Impact Amplitude", Gain="1");
    add_line(subsystemPath, "Impact Timing BPFO/1", "Damped Housing Resonance/1", "autorouting", "on");
    add_line(subsystemPath, "Damped Housing Resonance/1", "Impact Amplitude/1", "autorouting", "on");
    add_line(subsystemPath, "Impact Amplitude/1", "Force Injection Later/1", "autorouting", "on");

    note = Simulink.Annotation(subsystemPath, "Prototype signal chain: BPFO impact timing -> damped resonance -> force-injection placeholder. Parameters must be identified from training bearings before physical claims.");
    note.Position = [45 10 610 45];
    note.FontSize = 9;
end
