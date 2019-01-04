%% Task 1: Grayscale Image with Interpolation
clear;
clc;

% Load the image
sourceImage = rgb2gray(imread("./images/portrait.jpg"));
targetImage = double(sourceImage);

% Return the binary mask
maskRegion = roipoly(im2double(sourceImage));

% Get the boundary coordinate and region - D.Omega
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

% Now construct the linear function
[omegaPixelCoordX, omegaPixelCoordY] = find(omega);
gridSize = length(omegaPixelCoordX);

% Preallocate A and b
A = sparse(gridSize,gridSize,0);
b = zeros(gridSize,1);

%% Construct A: Laplacian with Built-in Function
omegaPixelCoords = find(omega);
omegaPixelOrder = zeros(size(omega));
for i = 1:size(omegaPixelCoords)
    omegaPixelOrder(omegaPixelCoords(i))=i;
end
disp('Efficiency - delsq()');
tic
A = delsq(omegaPixelOrder);
toc

%% Construct b: Boundary Conditions
for i = 1: gridSize
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
end

%% Solve the equation
x = A\b;

for i = 1:gridSize
    targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i))=x(i);
end

figure;
imshow(targetImage/255);