%% Selection Editing: Texture Flattening
function SelectionEditing(sourceImageRaw, rgbMode, editingMode)
%% Image Setup
if (rgbMode == false)
    sourceImage = im2double(rgb2gray(sourceImageRaw));
else
    sourceImage = im2double(sourceImageRaw);
end

targetImage = sourceImage;

result = targetImage;
[~,~,channel] = size(result);

% Select mask region
[~, sourceMaskRegionCoordX, sourceMaskRegionCoordY]= roipoly(sourceImage);
targetMaskRegion = roipoly(targetImage,sourceMaskRegionCoordX,sourceMaskRegionCoordY);

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

% Mask region excluding the boundary - Omega
omega = targetMaskRegion;
%omegaPixelCoords = find(omega);
%result(omegaPixelCoords)=0;
for i = 1:size(boundaryCoordX)
    omega(boundaryCoordX(i),boundaryCoordY(i))=0;
end
[omegaPixelCoordX, omegaPixelCoordY] = find(omega);
gridSize = length(omegaPixelCoordX);

%% Construct Matrix A
omegaPixelCoords = find(omega);
result(omegaPixelCoords)=0;
omegaPixelOrder = zeros(size(omega));
for i = 1:size(omegaPixelCoords)
    omegaPixelOrder(omegaPixelCoords(i))=i;
end
A = delsq(omegaPixelOrder);

%% Texture Flattening
if (editingMode == "TF")
    V = zeros(size(sourceImage));
    edgeThreshold = 0.04;
    for c = 1: channel
        for i = 1:size(omegaPixelCoordX)     
            targetMaskCentralValue = targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i),c); 
            targetMaskNeighbour1 = targetMaskCentralValue - targetImage(omegaPixelCoordX(i)-1, omegaPixelCoordY(i),c);
            targetMaskNeighbour2 = targetMaskCentralValue - targetImage(omegaPixelCoordX(i)+1, omegaPixelCoordY(i),c);
            targetMaskNeighbour3 = targetMaskCentralValue - targetImage(omegaPixelCoordX(i), omegaPixelCoordY(i)-1,c);
            targetMaskNeighbour4 = targetMaskCentralValue - targetImage(omegaPixelCoordX(i), omegaPixelCoordY(i)+1,c);

            neighbour1 = 0;
            neighbour2 = 0;
            neighbour3 = 0;
            neighbour4 = 0;

            if abs(targetMaskNeighbour1) > edgeThreshold
                neighbour1 = targetMaskNeighbour1;
            end

            if abs(targetMaskNeighbour2) > edgeThreshold
                neighbour2 = targetMaskNeighbour2;
            end

            if abs(targetMaskNeighbour3) > edgeThreshold
                neighbour3 = targetMaskNeighbour3;
            end

            if abs(targetMaskNeighbour4) > edgeThreshold
                neighbour4 = targetMaskNeighbour4;
            end  

            V(omegaPixelCoordX(i),omegaPixelCoordY(i),c) = neighbour1 + neighbour2 + neighbour3 + neighbour4; 
        end
    end
end

%% Local Illumination Changes
if (editingMode == "LIC")
    V = zeros(size(sourceImage));
    alpha = 0.2;
    beta = 0.2;
    for c = 1: channel
        for i = 1:size(omegaPixelCoordX)     
            targetMaskCentralValue = targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i),c); 
            targetMaskNeighbour1 = targetMaskCentralValue - targetImage(omegaPixelCoordX(i)-1, omegaPixelCoordY(i),c);
            targetMaskNeighbour2 = targetMaskCentralValue - targetImage(omegaPixelCoordX(i)+1, omegaPixelCoordY(i),c);
            targetMaskNeighbour3 = targetMaskCentralValue - targetImage(omegaPixelCoordX(i), omegaPixelCoordY(i)-1,c);
            targetMaskNeighbour4 = targetMaskCentralValue - targetImage(omegaPixelCoordX(i), omegaPixelCoordY(i)+1,c);

            neighbour1 = (alpha^beta)*(abs(targetMaskNeighbour1))^(-beta)* targetMaskNeighbour1;
            neighbour2 = (alpha^beta)*(abs(targetMaskNeighbour2))^(-beta)* targetMaskNeighbour2;
            neighbour3 = (alpha^beta)*(abs(targetMaskNeighbour3))^(-beta)* targetMaskNeighbour3;
            neighbour4 = (alpha^beta)*(abs(targetMaskNeighbour4))^(-beta)* targetMaskNeighbour4;
            
            V(omegaPixelCoordX(i),omegaPixelCoordY(i),c) = neighbour1 + neighbour2 + neighbour3 + neighbour4; 
        end
    end
end

%% Construct Matrix b
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
        b(i) = b(i) + V(omegaPixelCoordX(i),omegaPixelCoordY(i),c);
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
title("Selection Editing Result");
end