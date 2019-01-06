%% Manual Mask Generation for 
% 1. Correcting ROI Shifting Errors: Pixel Mismatching
%For details please refer to ImporingGradients.m Image Setup last step
% 2. Relocating Mask Center
% 3. Checking Boundaries
function targetMaskRegion = TargetMaskGenerator(sourceMaskRegion, targetImage, sourceMaskRegionCoordX, sourceMaskRegionCoordY, targetPosX, targetPosY)
warning('off','all')

centerOffsetX = floor((max(sourceMaskRegionCoordX) - min(sourceMaskRegionCoordX))/2);
centerOffsetY = floor((max(sourceMaskRegionCoordY) - min(sourceMaskRegionCoordY))/2);

% Original mask position
% figure;
% imshow(sourceMaskRegion);
% title("Original Pos");

% Shift mask to origin (top-left)
[width,height]= size(sourceMaskRegion);

shiftLeftOffset = min(sourceMaskRegionCoordY)-1;
shiftLeftOffset2 = width - max(sourceMaskRegionCoordY)-1;
shiftTopOffset = min(sourceMaskRegionCoordX)-1;
shiftTopOffset2 = height - max(sourceMaskRegionCoordX)-1;

sourceMaskRegion(1:shiftLeftOffset,:)=[];
sourceMaskRegion(:,1:shiftTopOffset)=[];

[width,height]= size(sourceMaskRegion);

sourceMaskRegion(width-shiftLeftOffset2: width,:)=[];
sourceMaskRegion(:,height-shiftTopOffset2: height)=[];

% Original mask position
% figure;
% imshow(sourceMaskRegion);
% title("Shifted to Origin Pos");

% Shift mask towards right by adding empty columns
[width,~]= size(sourceMaskRegion);
leftRegion = zeros(width,round(targetPosX)-centerOffsetX);
sourceMaskRegion = [leftRegion sourceMaskRegion];

% Shift mask towards bottom by adding empty rows
[~,height]= size(sourceMaskRegion);
topRegion = zeros(round(targetPosY)-centerOffsetY,height);
sourceMaskRegion = [topRegion;sourceMaskRegion];

% Shifted mask position
% figure;
% imshow(sourceMaskRegion);
% title("Shifted Pos");

% Check if the mask region is outside the target image
[targetW, targetH, ~] = size(targetImage);
[maskW, maskH,~] = size(sourceMaskRegion);

if (targetW < maskW)
   sourceMaskRegion(1:maskW-targetW,:)=[];   
end

if (targetH < maskH)
   sourceMaskRegion(:,1:maskH-targetH)=[]; 
end

% Adjusted mask position
% figure;
% imshow(sourceMaskRegion);
% title("Adjusted Pos");

% Convert to logical for boundary operations
targetMaskRegion = logical(sourceMaskRegion);

end