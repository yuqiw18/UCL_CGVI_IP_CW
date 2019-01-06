%% Importing Gradients with Colored Image Compatibility
function result = ImportingGradients(sourceImageRaw, targetImageRaw, rgbMode)
%% Image Setup
if (rgbMode == false)
    sourceImage = im2double(rgb2gray(sourceImageRaw));
    targetImage = im2double(rgb2gray(targetImageRaw));  
else
    sourceImage = im2double(sourceImageRaw);
    targetImage = im2double(targetImageRaw);  
end

result = targetImage;
[~,~,channel] = size(result);

% Select mask region
[sourceMaskRegion, sourceMaskRegionCoordX, sourceMaskRegionCoordY]= roipoly(sourceImage);

% Select position
figure;
imshow(targetImage);
title('Pick a location to paste the selected region.(Pivot: Top-Left)');
[targetPosX, targetPosY] = getpts;

% Generate the mask for selected position
targetMaskRegion = TargetMaskGenerator(sourceMaskRegion, targetImage, sourceMaskRegionCoordX, sourceMaskRegionCoordY, targetPosX, targetPosY);

% Shifting a region to new position produces errors: New regions may have
% more or less pixels which leads to pixel mismatching for later operation.
% Any change to the coordX and coordY has a chance to give such errors,
% 1. Simply shift 10 units to the bottom and right
% targetMaskRegion = roipoly(targetImage/255,sourceMaskRegionCoordX,sourceMaskRegionCoordY);
% 2. ...Or even more complicated shifting
% targetMaskRegion = roipoly(targetImage/255,sourceMaskRegionCoordX-min(sourceMaskRegionCoordX)+targetPosX,sourceMaskRegionCoordY-min(sourceMaskRegionCoordY)+targetPosY);
% 3. ...Or even process the value separatly
% xCenter = (min(sourceMaskRegionCoordX)+max(sourceMaskRegionCoordX))/2;
% yCenter = (min(sourceMaskRegionCoordY)+max(sourceMaskRegionCoordY))/2;
% targetMaskRegionCoordX = sourceMaskRegionCoordX - xCenter + targetPosY;
% targetMaskRegionCoordY = sourceMaskRegionCoordY - yCenter + targetPosX;
% targetMaskRegion = roipoly(targetImage/255,targetMaskRegionCoordX,targetMaskRegionCoordY);

%% Define Boundary and Omega
% Boundary of Target Image Mask - Diff.Omega
targetBoundary = bwboundaries(targetMaskRegion);
boundaryCoords = cell2mat(targetBoundary);
boundaryCoordX = boundaryCoords(:,1);
boundaryCoordY = boundaryCoords(:,2);
boundaryRegion = zeros(size(targetMaskRegion));
for i = 1 : size(boundaryCoords,1) 
    boundaryRegion(boundaryCoordX(i),boundaryCoordY(i))=1;
end

% Boundary of Source Image Mask - Diff.Omega
sourceBoundary = bwboundaries(sourceMaskRegion);
sourceBoundaryCoords = cell2mat(sourceBoundary);
sourceBoundaryCoordX = sourceBoundaryCoords(:,1);
sourceBoundaryCoordY = sourceBoundaryCoords(:,2);
sourceBoundaryRegion = zeros(size(sourceMaskRegion));
for i = 1 : size(sourceBoundaryCoords,1) 
    sourceBoundaryRegion(sourceBoundaryCoordX(i),sourceBoundaryCoordY(i))=1;
end

% Mask region excluding the boundary - Omega
omega = targetMaskRegion;
%omegaPixelCoords = find(omega);
%result(omegaPixelCoords)=0;
for i = 1:size(boundaryCoordX)
    omega(boundaryCoordX(i),boundaryCoordY(i))=0;
end
[omegaPixelCoordX, omegaPixelCoordY] = find(omega);

% Mask region excluding the boundary - Omega
sourceOmega = sourceMaskRegion;
for i = 1:size(sourceBoundaryCoordX)
    sourceOmega(sourceBoundaryCoordX(i),sourceBoundaryCoordY(i))=0;
end
[sourceOmegaPixelCoordX,sourceOmegaPixelCoordY] = find(sourceOmega);

%% Construct Matrix A: Laplacian with Built-in Discrete Laplacian Function
omegaPixelCoords = find(omega);
result(omegaPixelCoords)=0;
omegaPixelSequence = zeros(size(omega));
for i = 1:size(omegaPixelCoords)
    omegaPixelSequence(omegaPixelCoords(i))=i;
end
A = delsq(omegaPixelSequence);

%% Importing Gradients
importingGradients = zeros(size(sourceImage));
for c = 1: channel
    for i = 1:size(omegaPixelCoordX)
        sourceMaskCentralValue = sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),c);
        sourceMaskNeighbour1Value = sourceImage(sourceOmegaPixelCoordX(i)-1,sourceOmegaPixelCoordY(i),c);
        sourceMaskNeighbour2Value = sourceImage(sourceOmegaPixelCoordX(i)+1,sourceOmegaPixelCoordY(i),c);
        sourceMaskNeighbour3Value = sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i)-1,c);
        sourceMaskNeighbour4Value = sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i)+1,c);
        importingGradients(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),c)=4*sourceMaskCentralValue-(sourceMaskNeighbour1Value+sourceMaskNeighbour2Value+sourceMaskNeighbour3Value+sourceMaskNeighbour4Value);
    end
end

%% Construct Matrix b with Importing Gradients
gridSize = length(omegaPixelCoordX);
for c=1:channel
    b = zeros(gridSize,1);
    singleChannelResult = targetImage(:,:,c);
    for i = 1:gridSize
         % Boundary on left side
        if(boundaryRegion(omegaPixelCoordX(i),omegaPixelCoordY(i)-1) == 1)
            b(i) = b(i) + targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i)-1,c);
        end
        % Boundary on right side
        if(boundaryRegion(omegaPixelCoordX(i),omegaPixelCoordY(i)+1) == 1)
            b(i) = b(i) + targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i)+1,c);
        end
         % Boundary on top side
        if(boundaryRegion(omegaPixelCoordX(i)-1,omegaPixelCoordY(i)) == 1)
            b(i) = b(i) + targetImage(omegaPixelCoordX(i)-1,omegaPixelCoordY(i),c);
        end
        % Boundary on bottom side
        if(boundaryRegion(omegaPixelCoordX(i)+1,omegaPixelCoordY(i)) == 1)
            b(i) = b(i) + targetImage(omegaPixelCoordX(i)+1,omegaPixelCoordY(i),c);
        end 
        b(i) = b(i) + importingGradients(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),c);
    end   
    x = A\b;
    for i = 1:gridSize
        singleChannelResult(omegaPixelCoordX(i),omegaPixelCoordY(i)) = x(i);
    end
    result(:,:,c) = singleChannelResult;
end

%% Output
figure();
imshow(result);
title("Importing Gradients Result");
end