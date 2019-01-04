clear;
clc;

%% 
% Load images
sourceImage = double(rgb2gray(imread("./images/portrait.jpg")))/255;
targetImage = double(rgb2gray(imread("./images/sky.jpg")))/255;
result = targetImage;

% Select mask region
[sourceMaskRegion, sourceMaskRegionCoordX, sourceMaskRegionCoordY]= roipoly(sourceImage);

% Select position
figure;
imshow(targetImage);
title('Pick a location to paste the selected region.(Pivot: Top-Left)');
[targetPosX, targetPosY] = getpts;

% Generate the mask for selected position
targetMaskRegion = roipoly(targetImage,sourceMaskRegionCoordX,sourceMaskRegionCoordY);

figure;
imshow(sourceMaskRegion);

figure;
imshow(targetMaskRegion);

%%
%calculate the divergence using laplace caculator
templt = [0 -1 0; -1 4 -1; 0 -1 0];
Source_Laplace = imfilter((sourceImage), templt, 'replicate');

targetBoundary = bwboundaries(targetMaskRegion);
boundaryCoords = cell2mat(targetBoundary);
boundaryCoordX = boundaryCoords(:,1);
boundaryCoordY = boundaryCoords(:,2);
boundaryRegion = zeros(size(targetMaskRegion));
for i = 1 : size(boundaryCoords,1) 
    boundaryRegion(boundaryCoordX(i),boundaryCoordY(i))=1;
end

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
for i = 1:size(boundaryCoordX)
    omega(boundaryCoordX(i),boundaryCoordY(i))=0;
end

% % Now construct the linear function
[omegaPixelCoordX, omegaPixelCoordY] = find(omega);

gridSize = length(omegaPixelCoordX);

% Mask region excluding the boundary - Omega
sourceOmega = sourceMaskRegion;
for i = 1:size(sourceBoundaryCoordX)
    sourceOmega(sourceBoundaryCoordX(i),sourceBoundaryCoordY(i))=0;
end

[sourceOmegaPixelCoordX,sourceOmegaPixelCoordY] = find(sourceOmega);

%Generate A matrix
A = sparse(gridSize,gridSize,0);
%Generate B matrix
b = zeros(gridSize,1);
for i = 1:gridSize
    for j = 1:gridSize  %Deal with edge later!
        % Fill in the A matrix
        if(i == j)
            A(i,j) = 4;%length(find(connected_4 == 1));
        else
            % if p_j in N_pi
            if(omegaPixelCoordX(j) == omegaPixelCoordX(i)-1 && omegaPixelCoordY(j) == omegaPixelCoordY(i))
                % if pj is up of pi
                A(i,j) = -1;
            end
            if(omegaPixelCoordX(j) == omegaPixelCoordX(i) && omegaPixelCoordY(j) == omegaPixelCoordY(i)+1)
                % if pj is right of pi
                A(i,j) = -1;
            end
            if(omegaPixelCoordX(j) == omegaPixelCoordX(i)+1 && omegaPixelCoordY(j) == omegaPixelCoordY(i))
                % if pj is down of pi
                A(i,j) = -1;
            end
            if(omegaPixelCoordX(j) == omegaPixelCoordX(i) && omegaPixelCoordY(j) == omegaPixelCoordY(i)-1)
                % if pj is left of pi
                A(i,j) = -1;
            end
        end
    end 
end

for i = 1:gridSize
   %Now fill in the B matrix
    sum = 0;
    if(boundaryRegion(omegaPixelCoordX(i)-1,omegaPixelCoordY(i)) == 1)
        % if up of pi is in boundary
        sum = sum + targetImage(omegaPixelCoordX(i)-1,omegaPixelCoordY(i),1);
    end
    if(boundaryRegion(omegaPixelCoordX(i),omegaPixelCoordY(i)+1) == 1)
        % if right of pi is in boundary
        sum = sum + targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i)+1,1);
    end
    if(boundaryRegion(omegaPixelCoordX(i)+1,omegaPixelCoordY(i)) == 1)
        % if down of pi is in boundary
        sum = sum + targetImage(omegaPixelCoordX(i)+1,omegaPixelCoordY(i),1);
    end
    if(boundaryRegion(omegaPixelCoordX(i),omegaPixelCoordY(i)-1) == 1)
        % if left of pi is in boundary
        sum = sum + targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i)-1,1);
    end
    sum = sum + Source_Laplace(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),1);
    b(i) = sum;
end

x = A\b;

for i = 1:gridSize
    result(omegaPixelCoordX(i),omegaPixelCoordY(i),1) = x(i);
end

figure();
imshow(result);


