%% Task 1: Grayscale Image with Interpolation
clear;
clc;

% Load the image
sourceImage = double(rgb2gray(imread("./images/portrait.jpg")));
result = sourceImage;

% Return the binary mask
maskRegion = roipoly(sourceImage/255);

% Get the boundary coordinate and region - Diff.Omega
boundary = bwboundaries(maskRegion);
boundaryCoords = cell2mat(boundary);
boundaryCoordX = boundaryCoords(:,1);
boundaryCoordY = boundaryCoords(:,2);
boundaryRegion = zeros(size(maskRegion));
for i = 1 : size(boundaryCoords,1) 
    boundaryRegion(boundaryCoordX(i),boundaryCoordY(i))=1;
end

% Mask region excluding the boundary - Omega
omega = maskRegion;
for i = 1:size(boundaryCoordX)
    omega(boundaryCoordX(i),boundaryCoordY(i))=0;
end
[omegaPixelCoordX, omegaPixelCoordY] = find(omega);
omegaPixelCoords = find(omega);

% Remove the region from the source image
result(omegaPixelCoords)=0;

%% Construct A: Laplacian with Built-in Function
omegaPixelOrder = zeros(size(omega));
for i = 1:size(omegaPixelCoords)
    omegaPixelOrder(omegaPixelCoords(i))=i;
end
disp('Efficiency - delsq()');
tic
A = delsq(omegaPixelOrder);
toc

%% Construct b: Boundary Conditions
gridSize = length(omegaPixelCoordX);
b = zeros(gridSize,1);
for i = 1: gridSize
    % Boundary on left side
    if(boundaryRegion(omegaPixelCoordX(i),omegaPixelCoordY(i)-1) == 1)
        b(i) = b(i) + sourceImage(omegaPixelCoordX(i),omegaPixelCoordY(i)-1);
    end
    % Boundary on right side
    if(boundaryRegion(omegaPixelCoordX(i),omegaPixelCoordY(i)+1) == 1)
        b(i) = b(i) + sourceImage(omegaPixelCoordX(i),omegaPixelCoordY(i)+1);
    end
     % Boundary on top side
    if(boundaryRegion(omegaPixelCoordX(i)-1,omegaPixelCoordY(i)) == 1)
        b(i) = b(i) + sourceImage(omegaPixelCoordX(i)-1,omegaPixelCoordY(i));
    end
    % Boundary on bottom side
    if(boundaryRegion(omegaPixelCoordX(i)+1,omegaPixelCoordY(i)) == 1)
        b(i) = b(i) + sourceImage(omegaPixelCoordX(i)+1,omegaPixelCoordY(i));
    end 
end

%% Solve the equation
x = A\b;

% Fill in the results
for i = 1:gridSize
    result(omegaPixelCoordX(i),omegaPixelCoordY(i))=x(i);
end

figure;
imshow(result/255);
title("Guided Interpolation");