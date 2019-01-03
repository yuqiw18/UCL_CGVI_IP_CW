%% Task 1: Grayscale Image with Interpolation
clear;
clc;

% Load the image
sourceImage = rgb2gray(imread("./images/portrait.jpg"));
targetImage = zeros(size(sourceImage));
result = double(sourceImage);

% Return the binary mask
maskRegion = roipoly(im2double(sourceImage));

% Get the boundary coordinate - ??
boundary = bwboundaries(maskRegion);
boundaryCoords = cell2mat(boundary);
boundaryCoordX = boundaryCoords(:,1);
boundaryCoordY = boundaryCoords(:,2);

% Mask region excluding the boundary - ?
omega = maskRegion;
for i = 1:size(boundaryCoordX)
    omega(boundaryCoordX(i),boundaryCoordY(i))=0;
end

% Boundary condition: f = f*, f(target) is unknown, f*(source) is known
targetImageMaskRegionBoundaryCoord = boundaryCoords;
targetImageMaskRegionBoundaryValue = zeros(size(maskRegion));
for i = 1 : size(boundaryCoords,1)
    targetImageMaskRegionBoundaryValue(boundaryCoordX(i),boundaryCoordY(i))=sourceImage(boundaryCoordX(i),boundaryCoordY(i));
end

% Now construct the linear function
omegaPixelCoords = find(omega);
exBoundaryMaskOrder = zeros(size(omega));
for i = 1:size(omegaPixelCoords)
    exBoundaryMaskOrder(omegaPixelCoords(i))=i;
end

A = delsq(exBoundaryMaskOrder);
B = del2(exBoundaryMaskOrder);

[maskXCoord, maskYCoord] = find(maskRegion);
for i =1:size(maskXCoord)
    neighbour1 = targetImageMaskRegionBoundaryValue(maskXCoord(i)-1, maskYCoord(i));
    neighbour2 = targetImageMaskRegionBoundaryValue(maskXCoord(i)+1, maskYCoord(i));
    neighbour3 = targetImageMaskRegionBoundaryValue(maskXCoord(i), maskYCoord(i)-1);
    neighbour4 = targetImageMaskRegionBoundaryValue(maskXCoord(i), maskYCoord(i)+1);
    targetImage(maskXCoord(i), maskYCoord(i)) = neighbour1 + neighbour2 + neighbour3 + neighbour4;
end

b = targetImage(omegaPixelCoords);

% Solve the equation
x = A\b;

% Find the coordinate for each pixel in the mask
[row, col] = find(omega);

for i = 1:size(row)
    result(row(i),col(i))=x(i);
end

figure;
imshow(result/255);