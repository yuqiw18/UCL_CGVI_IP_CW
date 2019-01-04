clear;
clc;

%% 
% Load images
sourceImage = double(rgb2gray(imread("./images/portrait.jpg")));
targetImage = double(rgb2gray(imread("./images/wood.jpg")));
result = targetImage;

% Select mask region
[sourceMaskRegion, sourceMaskRegionCoordX, sourceMaskRegionCoordY]= roipoly(sourceImage/255);

% Select position
figure;
imshow(targetImage/255);
title('Pick a location to paste the selected region.(Pivot: Top-Left)');
[targetPosX, targetPosY] = ginput(1);

% Generate the mask for selected position
targetMaskRegion = roipoly(targetImage/255,sourceMaskRegionCoordX-min(sourceMaskRegionCoordX)+targetPosX,sourceMaskRegionCoordY-min(sourceMaskRegionCoordY)+targetPosY);

%%
targetBoundary = bwboundaries(targetMaskRegion);
boundaryCoords = cell2mat(targetBoundary);
boundaryCoordX = boundaryCoords(:,1);
boundaryCoordY = boundaryCoords(:,2);
boundaryRegion = zeros(size(targetMaskRegion));
for i = 1 : size(boundaryCoords,1) 
    boundaryRegion(boundaryCoordX(i),boundaryCoordY(i))=1;
end

% Mask region excluding the boundary - Omega
omega = targetMaskRegion;
for i = 1:size(boundaryCoordX)
    omega(boundaryCoordX(i),boundaryCoordY(i))=0;
end

[omegaPixelCoordX, omegaPixelCoordY] = find(omega);

sourceBoundary = bwboundaries(sourceMaskRegion);
sourceBoundaryCoords = cell2mat(sourceBoundary);
sourceBoundaryCoordX = sourceBoundaryCoords(:,1);
sourceBoundaryCoordY = sourceBoundaryCoords(:,2);
sourceBoundaryRegion = zeros(size(sourceMaskRegion));
for i = 1 : size(sourceBoundaryCoords,1) 
    sourceBoundaryRegion(sourceBoundaryCoordX(i),sourceBoundaryCoordY(i))=1;
end

% Mask region excluding the boundary - Omega
sourceOmega = sourceMaskRegion;
for i = 1:size(sourceBoundaryCoordX)
    sourceOmega(sourceBoundaryCoordX(i),sourceBoundaryCoordY(i))=0;
end

[sourceOmegaPixelCoordX,sourceOmegaPixelCoordY] = find(sourceOmega);

%% Mixing Gradients
mixingGradients = zeros(size(sourceImage));
for i = 1:size(sourceOmegaPixelCoordX)
    targetMaskCentralPixel = targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i)); 
    targetMaskNeighbour1 = targetMaskCentralPixel - targetImage(omegaPixelCoordX(i)-1, omegaPixelCoordY(i));
    targetMaskNeighbour2 = targetMaskCentralPixel - targetImage(omegaPixelCoordX(i)+1, omegaPixelCoordY(i));
    targetMaskNeighbour3 = targetMaskCentralPixel - targetImage(omegaPixelCoordX(i), omegaPixelCoordY(i)-1);
    targetMaskNeighbour4 = targetMaskCentralPixel - targetImage(omegaPixelCoordX(i), omegaPixelCoordY(i)+1);
    
    sourceMaskCentralPixel = sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i));
    sourceMaskNeighbour1 = sourceMaskCentralPixel - sourceImage(sourceOmegaPixelCoordX(i)-1,sourceOmegaPixelCoordY(i));
    sourceMaskNeighbour2 = sourceMaskCentralPixel - sourceImage(sourceOmegaPixelCoordX(i)+1,sourceOmegaPixelCoordY(i));
    sourceMaskNeighbour3 = sourceMaskCentralPixel - sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i)-1);
    sourceMaskNeighbour4 = sourceMaskCentralPixel - sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i)+1);
   
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
    mixingGradients(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i)) = neighbour1+neighbour2+neighbour3+neighbour4; 
end

%% Construct Lindear Equation
gridSize = length(omegaPixelCoordX);
b = zeros(gridSize,1);

% A
omegaPixelCoords = find(omega);
omegaPixelOrder = zeros(size(omega));
for i = 1:size(omegaPixelCoords)
    omegaPixelOrder(omegaPixelCoords(i))=i;
end
A = delsq(omegaPixelOrder);

% b
for i = 1:gridSize
     % Boundary on left side
    if(boundaryRegion(omegaPixelCoordX(i),omegaPixelCoordY(i)-1) == 1)
        b(i) = b(i) + targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i)-1);
    end
    % Boundary on right side
    if(boundaryRegion(omegaPixelCoordX(i),omegaPixelCoordY(i)+1) == 1)
        b(i) = b(i) + targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i)+1);
    end
     % Boundary on top side
    if(boundaryRegion(omegaPixelCoordX(i)-1,omegaPixelCoordY(i)) == 1)
        b(i) = b(i) + targetImage(omegaPixelCoordX(i)-1,omegaPixelCoordY(i));
    end
    % Boundary on bottom side
    if(boundaryRegion(omegaPixelCoordX(i)+1,omegaPixelCoordY(i)) == 1)
        b(i) = b(i) + targetImage(omegaPixelCoordX(i)+1,omegaPixelCoordY(i));
    end 
    b(i) = b(i) + mixingGradients(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),1);
end

x = A\b;

for i = 1:gridSize
    result(omegaPixelCoordX(i),omegaPixelCoordY(i),1) = x(i);
end

figure();
imshow(result/255);


