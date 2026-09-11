function bands = buildBearingFaultBandTable(faultFrequencies)
%BUILDBEARINGFAULTBANDTABLE Define envelope bands for manifest fault elements.
arguments
    faultFrequencies (1,1) struct
end

bandName = strings(0, 1);
faultElement = strings(0, 1);
centerHz = zeros(0, 1);
description = strings(0, 1);

    function addBand(name, element, center, note)
        if isfinite(center) && center > 0
            bandName(end+1, 1) = name;
            faultElement(end+1, 1) = element;
            centerHz(end+1, 1) = center;
            description(end+1, 1) = note;
        end
    end

if isfield(faultFrequencies, "FTF")
    addBand("FTF", "cage", faultFrequencies.FTF, "Fundamental train frequency for cage defects");
end
if isfield(faultFrequencies, "BPFO")
    addBand("BPFO", "outer race", faultFrequencies.BPFO, "Outer-race ball pass frequency");
    addBand("BPFO2", "outer race", 2*faultFrequencies.BPFO, "Second BPFO harmonic");
    addBand("BPFO3", "outer race", 3*faultFrequencies.BPFO, "Third BPFO harmonic");
end
if isfield(faultFrequencies, "BPFI")
    addBand("BPFI", "inner race", faultFrequencies.BPFI, "Inner-race ball pass frequency");
    if isfield(faultFrequencies, "ShaftHz")
        addBand("BPFI_ShaftLower", "inner race", faultFrequencies.BPFI - faultFrequencies.ShaftHz, "BPFI lower shaft sideband");
        addBand("BPFI_ShaftUpper", "inner race", faultFrequencies.BPFI + faultFrequencies.ShaftHz, "BPFI upper shaft sideband");
    end
end
if isfield(faultFrequencies, "BSF")
    addBand("Ball2BSF", "ball", 2*faultFrequencies.BSF, "Dominant ball-defect line at 2 x BSF");
end

bands = table(bandName, faultElement, centerHz, description, ...
    VariableNames=["BandName", "FaultElement", "CenterHz", "Description"]);
end
