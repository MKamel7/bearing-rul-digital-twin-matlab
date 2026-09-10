function geometry = readBearingGeometry(geometryPath)
%READBEARINGGEOMETRY Read the audited XJTU-SY LDK UER204 geometry table.
arguments
    geometryPath (1,1) string
end

if ~isfile(geometryPath)
    error("BearingRUL:GeometryNotFound", "Geometry file not found: %s", geometryPath);
end

source = readtable(geometryPath, TextType="string");
required = ["Parameter", "Value", "Unit", "Source", "Status"];
missing = setdiff(required, string(source.Properties.VariableNames));
if ~isempty(missing)
    error("BearingRUL:MissingGeometryColumns", "Geometry file is missing columns: %s", strjoin(missing, ", "));
end

lookup = containers.Map(lower(source.Parameter), num2cell(source.Value));
geometry = struct();
geometry.OuterRaceDiameterMM = lookup("outer race diameter");
geometry.InnerRaceDiameterMM = lookup("inner race diameter");
geometry.MeanDiameterMM = lookup("bearing mean diameter");
geometry.BallDiameterMM = lookup("ball diameter");
geometry.NumberOfBalls = lookup("number of balls");
geometry.ContactAngleDeg = lookup("contact angle");
geometry.StaticLoadRatingKN = lookup("load rating static");
geometry.DynamicLoadRatingKN = lookup("load rating dynamic");
end
