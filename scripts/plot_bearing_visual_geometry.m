%PLOT_BEARING_VISUAL_GEOMETRY Render an approximate bearing body from audited dimensions.
projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(fullfile(projectRoot, "src")));

geometry = readBearingGeometry(fullfile(projectRoot, "docs", "data", "xjtu_sy_bearing_geometry.csv"));
visual = deriveBearingVisualGeometry(geometry);

figure("Visible", "off", "Color", "white", "Position", [100 100 1100 780]);
hold on;

plotAnnularCylinder(visual.InnerVisualRadiusMM, visual.InnerRaceRadiusMM, visual.WidthMM, [0.18 0.34 0.48], 0.95);
plotAnnularCylinder(visual.OuterRaceRadiusMM, visual.OuterVisualRadiusMM, visual.WidthMM, [0.46 0.55 0.60], 0.85);

for idx = 1:visual.NumberOfBalls
    plotBall(visual.BallCentersMM(idx,:), visual.BallRadiusMM, [0.82 0.63 0.32]);
end

theta = linspace(0, 2*pi, 240);
plot3(visual.PitchRadiusMM*cos(theta), visual.PitchRadiusMM*sin(theta), zeros(size(theta)), ...
    "k--", "LineWidth", 1.2);

axis equal;
grid on;
view(42, 28);
xlabel("x (mm)");
ylabel("y (mm)");
zlabel("z (mm)");
title("LDK UER204 bearing visual geometry from XJTU-SY dimensions", Color="black");
subtitle("Raceway-dimension visual approximation only: Simscape model remains reduced, not CAD assembly", Color=[0.2 0.2 0.2]);

annotationText = sprintf("Outer race dia %.2f mm | Inner race dia %.2f mm | Ball dia %.2f mm | Balls %d", ...
    geometry.OuterRaceDiameterMM, geometry.InnerRaceDiameterMM, geometry.BallDiameterMM, geometry.NumberOfBalls);
annotation("textbox", [0.14 0.06 0.76 0.05], String=annotationText, EdgeColor="none", ...
    HorizontalAlignment="center", Color=[0.1 0.1 0.1], FontSize=10);
styleAxes();
camlight("headlight");
lighting gouraud;

outDir = fullfile(projectRoot, "results", "figures");
if ~isfolder(outDir)
    mkdir(outDir);
end
outPath = fullfile(outDir, "bearing_visual_geometry.png");
exportgraphics(gcf, outPath, Resolution=150);
close(gcf);
fprintf("Wrote %s\n", outPath);

function plotAnnularCylinder(innerRadius, outerRadius, width, color, alphaValue)
    theta = linspace(0, 2*pi, 160);
    z = [-width/2, width/2];
    [thetaGrid, zGrid] = meshgrid(theta, z);

    xOuter = outerRadius * cos(thetaGrid);
    yOuter = outerRadius * sin(thetaGrid);
    surf(xOuter, yOuter, zGrid, FaceColor=color, FaceAlpha=alphaValue, EdgeColor="none");

    xInner = innerRadius * cos(thetaGrid);
    yInner = innerRadius * sin(thetaGrid);
    surf(xInner, yInner, zGrid, FaceColor=color*0.75, FaceAlpha=alphaValue, EdgeColor="none");

    r = [innerRadius, outerRadius];
    [thetaCap, rCap] = meshgrid(theta, r);
    for zCap = z
        xCap = rCap .* cos(thetaCap);
        yCap = rCap .* sin(thetaCap);
        zCapGrid = zCap * ones(size(xCap));
        surf(xCap, yCap, zCapGrid, FaceColor=color, FaceAlpha=alphaValue, EdgeColor="none");
    end
end

function plotBall(center, radius, color)
    [x, y, z] = sphere(36);
    surf(radius*x + center(1), radius*y + center(2), radius*z + center(3), ...
        FaceColor=color, FaceAlpha=0.95, EdgeColor="none");
end

function styleAxes()
    ax = gca;
    ax.Color = "white";
    ax.XColor = "black";
    ax.YColor = "black";
    ax.ZColor = "black";
    ax.GridColor = [0.72 0.72 0.72];
    ax.MinorGridColor = [0.85 0.85 0.85];
    ax.TickLabelInterpreter = "none";
end
