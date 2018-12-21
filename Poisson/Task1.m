%% Task 1: Grayscale Image
clear;
clc;

% Load the image
sourceImage = rgb2gray(imread("./images/portrait.jpg"));
targetImage = zeros(size(sourceImage));

% Return the binary mask
maskRegion = roipoly(im2double(sourceImage));
%targetMaskRegion = zeros(size(maskRegion));
regionPixelCount = find(maskRegion);
maskRegionValue = maskRegion .* double(sourceImage);

% Get the boundary coordinate
boundary = bwboundaries(maskRegion);
boundaryCoord = cell2mat(boundary);

% Mask region excluding the boundary
exBoundaryMaskRegion = maskRegion;
for i = 1:size(boundaryCoord,1)
    % Crop the boundary from original mask
    exBoundaryMaskRegion(boundaryCoord(i,1),boundaryCoord(i,2))=0;
end
exBoundaryMaskRegionValue = exBoundaryMaskRegion .* double(sourceImage);
exBoundaryMaskRegionPixelCount = find(exBoundaryMaskRegionValue);

exBoundaryMaskOrder = zeros(size(exBoundaryMaskRegionValue));
for i = 1:size(exBoundaryMaskRegionPixelCount)
    exBoundaryMaskOrder(exBoundaryMaskRegionPixelCount(i))=i;
end

A = delsq(exBoundaryMaskOrder);
B = delsq(exBoundaryMaskRegionValue);

% Blur the bounday
targetImageMaskRegionBoundaryCoord = boundaryCoord;
targetUnageMaskRegionBoundaryValue = zeros(size(maskRegionValue));
for i = 1 : size(boundaryCoord,1)
    targetUnageMaskRegionBoundaryValue(boundaryCoord(i,1),boundaryCoord(i,2))=sourceImage(boundaryCoord(i,1),boundaryCoord(i,2));
end

[maskXCoord, maskYCoord] = find(maskRegion);
for i =1:size(maskXCoord)
    neighbour1 = targetUnageMaskRegionBoundaryValue(maskXCoord(i)-1, maskYCoord(i));
    neighbour2 = targetUnageMaskRegionBoundaryValue(maskXCoord(i)+1, maskYCoord(i));
    neighbour3 = targetUnageMaskRegionBoundaryValue(maskXCoord(i), maskYCoord(i)-1);
    neighbour4 = targetUnageMaskRegionBoundaryValue(maskXCoord(i), maskYCoord(i)+1);
    targetImage(maskXCoord(i), maskYCoord(i)) = neighbour1 + neighbour2 + neighbour3 + neighbour4 - 4* targetUnageMaskRegionBoundaryValue(maskXCoord(i), maskYCoord(i));
end

% for i = 1 : size (boundaryCoord, 1)
%     targetImage(boundaryCoord(i,1),boundaryCoord(i,2))=2;
% end

fq = targetImage(exBoundaryMaskRegionPixelCount);
f = A\fq;
[xX, yY] = find(exBoundaryMaskRegion);
result = double(sourceImage);

for i = 1:size(xX)
    result(xX(i),yY(i))=f(i);
end

figure;
imshow(result/255);

%% Test
%
% figure;
% imshow(maskRegion);
% title("Mask Region");
%
% figure;
% maskRegionValue = maskRegion .* double(sourceImage);
% imshow(uint8(maskRegionValue));
% title("Selected Region");
% 
% figure;
% maskArea2 = exBoundaryMaskRegion .* double(sourceImage);
% imshow(uint8(maskArea2));
% title("Selected Region without boundary");
