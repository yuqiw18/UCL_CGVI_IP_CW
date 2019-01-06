%% Mixing Gradients with Colored Image Compatibility
function result = MixingGradients(sourceImageRaw, targetImageRaw, rgbMode)
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
%omegaPixelCoords = find(omega);
%result(omegaPixelCoords)=0;
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

%% Construct Matrix A: Laplacian with Built-in Discrete Laplacian Function
omegaPixelCoords = find(omega);
result(omegaPixelCoords)=0;
omegaPixelSequence = zeros(size(omega));
for i = 1:size(omegaPixelCoords)
    omegaPixelSequence(omegaPixelCoords(i))=i;
end
A = delsq(omegaPixelSequence);

%% Mixing Gradients
mixingGradients = zeros(size(sourceImage));
for c = 1: channel
    for i = 1:size(omegaPixelCoordX)
        targetMaskCentralValue = targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i),c); 
        targetMaskNeighbour1 = targetMaskCentralValue - targetImage(omegaPixelCoordX(i)-1, omegaPixelCoordY(i),c);
        targetMaskNeighbour2 = targetMaskCentralValue - targetImage(omegaPixelCoordX(i)+1, omegaPixelCoordY(i),c);
        targetMaskNeighbour3 = targetMaskCentralValue - targetImage(omegaPixelCoordX(i), omegaPixelCoordY(i)-1,c);
        targetMaskNeighbour4 = targetMaskCentralValue - targetImage(omegaPixelCoordX(i), omegaPixelCoordY(i)+1,c);

        sourceMaskCentralValue = sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),c);
        sourceMaskNeighbour1 = sourceMaskCentralValue - sourceImage(sourceOmegaPixelCoordX(i)-1,sourceOmegaPixelCoordY(i),c);
        sourceMaskNeighbour2 = sourceMaskCentralValue - sourceImage(sourceOmegaPixelCoordX(i)+1,sourceOmegaPixelCoordY(i),c);
        sourceMaskNeighbour3 = sourceMaskCentralValue - sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i)-1,c);
        sourceMaskNeighbour4 = sourceMaskCentralValue - sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i)+1,c);

        if abs(targetMaskNeighbour1) < abs(sourceMaskNeighbour1)
            v1 = sourceMaskNeighbour1;
        else
            v1 = targetMaskNeighbour1;
        end
        if abs(targetMaskNeighbour2) < abs(sourceMaskNeighbour2)
            v2 = sourceMaskNeighbour2;
        else
            v2 = targetMaskNeighbour2;
        end
        if abs(targetMaskNeighbour3) < abs(sourceMaskNeighbour3)
            v3 = sourceMaskNeighbour3;
        else
            v3 = targetMaskNeighbour3;
        end
        if abs(targetMaskNeighbour4) < abs(sourceMaskNeighbour4)
            v4 = sourceMaskNeighbour4;
        else
            v4 = targetMaskNeighbour4;
        end   
        mixingGradients(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),c) = v1 + v2 + v3 + v4; 
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
imshow(result);
title("Mixing Gradients Result");
end