function stackedPulse = stackPulses(pulseCell,sumOnly)
%STACKPULSES Summary of this function goes here
%   Detailed explanation goes here

if ~exist("sumOnly")
    sumOnly = 0;
end

numPulses = length(pulseCell);


%trim all to min size
[~,c] = cellfun(@size,pulseCell);
minSize = min(c);

pulseCellTrimmed = cellfun(@(x) x(1:minSize),pulseCell,'UniformOutput',false);
pulseMat = transpose(cell2mat(cellfun(@transpose,pulseCellTrimmed,'UniformOutput',false)));

if ~sumOnly
    stackedPulse = sum(pulseMat,1)/numPulses;
else
    stackedPulse = sum(pulseMat,1);
end

end

