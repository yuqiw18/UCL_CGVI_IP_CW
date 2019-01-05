clear;
clc;

%% Image Setup
rgbMode = true;

% Load images
sourceImageRaw = imread("./images/cows.jpg");
targetImageRaw = imread("./images/cows.jpg");

if (rgbMode == false)
    sourceImage = double(rgb2gray(sourceImageRaw));
    targetImage = double(rgb2gray(targetImageRaw));  
else
    sourceImage = double(sourceImageRaw);
    targetImage = double(targetImageRaw);  
end

result = targetImage;
[~,~,channel] = size(result);

% Select mask region
[sourceMaskRegion, sourceMaskRegionCoordX, sourceMaskRegionCoordY]= roipoly(sourceImage/255);

% Select position
figure;
imshow(targetImage/255);
title('Pick a location to paste the selected region.(Pivot: Top-Left)');
[targetPosX, targetPosY] = getpts;

shiftX=-min(sourceMaskRegionCoordX)+1+targetPosX;
shiftY=-min(sourceMaskRegionCoordY)+1+targetPosY;
%shiftX=0;
%shiftY=0;

% Generate the mask for selected position
targetMaskRegion = roipoly(targetImage/255,sourceMaskRegionCoordX+shiftX,sourceMaskRegionCoordY+shiftY);

%% Define Boundary and Omega
% Boundary of Target Image Mask
targetBoundary = bwboundaries(targetMaskRegion);
boundaryCoords = cell2mat(targetBoundary);
boundaryCoordX = boundaryCoords(:,1);
boundaryCoordY = boundaryCoords(:,2);
boundaryRegion = zeros(size(targetMaskRegion));
for i = 1 : size(boundaryCoords,1) 
    boundaryRegion(boundaryCoordX(i),boundaryCoordY(i))=1;
end

% Boundary of Source Image Mask
sourceBoundary = bwboundaries(sourceMaskRegion);
sourceBoundaryCoords = cell2mat(sourceBoundary);
sourceBoundaryCoordX = sourceBoundaryCoords(:,1);
sourceBoundaryCoordY = sourceBoundaryCoords(:,2);
sourceBoundaryRegion = zeros(size(sourceMaskRegion));
for i = 1 : size(sourceBoundaryCoords,1) 
    sourceBoundaryRegion(sourceBoundaryCoordX(i),sourceBoundaryCoordY(i))=1;
end

% Mask region excluding the boundary - Omega(Target)
omega = targetMaskRegion;
for i = 1:size(boundaryCoordX)
    omega(boundaryCoordX(i),boundaryCoordY(i))=0;
end
[omegaPixelCoordX, omegaPixelCoordY] = find(omega);

% Mask region excluding the boundary - Omega(Source)
sourceOmega = sourceMaskRegion;
for i = 1:size(sourceBoundaryCoordX)
    sourceOmega(sourceBoundaryCoordX(i),sourceBoundaryCoordY(i))=0;
end
[sourceOmegaPixelCoordX,sourceOmegaPixelCoordY] = find(sourceOmega);

%% Construct Matrix A
omegaPixelCoords = find(omega);
omegaPixelOrder = zeros(size(omega));
for i = 1:size(omegaPixelCoords)
    omegaPixelOrder(omegaPixelCoords(i))=i;
end
A = delsq(omegaPixelOrder);

%% Mixing Gradients
mixingGradients = zeros(size(sourceImage));
for c = 1: channel
    for i = 1:size(omegaPixelCoordX)
        targetMaskCentralPixel = targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i),c); 
        targetMaskNeighbour1 = targetMaskCentralPixel - targetImage(omegaPixelCoordX(i)-1, omegaPixelCoordY(i),c);
        targetMaskNeighbour2 = targetMaskCentralPixel - targetImage(omegaPixelCoordX(i)+1, omegaPixelCoordY(i),c);
        targetMaskNeighbour3 = targetMaskCentralPixel - targetImage(omegaPixelCoordX(i), omegaPixelCoordY(i)-1,c);
        targetMaskNeighbour4 = targetMaskCentralPixel - targetImage(omegaPixelCoordX(i), omegaPixelCoordY(i)+1,c);

        sourceMaskCentralPixel = sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),c);
        sourceMaskNeighbour1 = sourceMaskCentralPixel - sourceImage(sourceOmegaPixelCoordX(i)-1,sourceOmegaPixelCoordY(i),c);
        sourceMaskNeighbour2 = sourceMaskCentralPixel - sourceImage(sourceOmegaPixelCoordX(i)+1,sourceOmegaPixelCoordY(i),c);
        sourceMaskNeighbour3 = sourceMaskCentralPixel - sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i)-1,c);
        sourceMaskNeighbour4 = sourceMaskCentralPixel - sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i)+1,c);

        if abs(targetMaskNeighbour1) < abs(sourceMaskNeighbour1)
            neighbour1 = sourceMaskNeighbour1;
        else
            neighbour1 = targetMaskNeighbour1;
        end

        if abs(targetMaskNeighbour2) < abs(sourceMaskNeighbour2)
            neighbour2 = sourceMaskNeighbour2;
        else
            neighbour2 = targetMaskNeighbour2;
        end

        if abs(targetMaskNeighbour3) < abs(sourceMaskNeighbour3)
            neighbour3 = sourceMaskNeighbour3;
        else
            neighbour3 = targetMaskNeighbour3;
        end

        if abs(targetMaskNeighbour4) < abs(sourceMaskNeighbour4)
            neighbour4 = sourceMaskNeighbour4;
        else
            neighbour4 = targetMaskNeighbour4;
        end   
        mixingGradients(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),c) = neighbour1+neighbour2+neighbour3+neighbour4; 
    end
end

%% Construct Matrix b with Mixing Gradients
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
        %b(i) = b(i) + targetImage(omegaPixelCoordX(i)+1,omegaPixelCoordY(i),c) + targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i)-1,c)+ targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i)+1,c)+ targetImage(omegaPixelCoordX(i)-1,omegaPixelCoordY(i),c);
        b(i) = b(i) + mixingGradients(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),c);
    end

    x = A\b;

    for i = 1:gridSize
        singleChannelResult(omegaPixelCoordX(i),omegaPixelCoordY(i)) = x(i);
    end

    result(:,:,c) = singleChannelResult;
end

%% Output
figure();
imshow(result/255);