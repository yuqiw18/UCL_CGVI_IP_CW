%% Manual Mask Generation for Correcting ROI Shifting Errors: Pixel Mismatching
% For details please refer to ImporingGradients.m Image Setup last step
function targetMaskRegion = TargetMaskGenerator(sourceMaskRegion, sourceMaskRegionCoordX, sourceMaskRegionCoordY, targetPosX, targetPosY)
warning('off','all')

% Shift mask to origin (top-left)
sourceMaskRegion(1:min(sourceMaskRegionCoordY)-1,:)=[];
sourceMaskRegion(:,1:min(sourceMaskRegionCoordX)-1)=[];

% Shift mask towards right by adding empty columns
[width,~]= size(sourceMaskRegion);
leftRegion = zeros(width,round(targetPosX));
sourceMaskRegion = [leftRegion sourceMaskRegion];

% Shift mask towards bottom by adding empty rows
[~,height]= size(sourceMaskRegion);
topRegion = zeros(round(targetPosY),height);
sourceMaskRegion = [topRegion;sourceMaskRegion];

% There is no need to make the size of mask exactly same as the target image
% What is required here is to make sure that the target mask region has correct coverage of
% pixels

% Convert to logical for boundary operations
targetMaskRegion = logical(sourceMaskRegion);

end