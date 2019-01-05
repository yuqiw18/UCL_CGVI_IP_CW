%% Importing Gradients with Colored Image Compatibility
function result = ImportingGradients(sourceImageRaw, targetImageRaw, rgbMode)
%% Image Setup
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

% Generate the mask for selected position
targetMaskRegion = TargetMaskGenerator(sourceMaskRegion, sourceMaskRegionCoordX, sourceMaskRegionCoordY, targetPosX, targetPosY);
%targetMaskRegion = roipoly(targetImage,sourceMaskRegionCoordX,sourceMaskRegionCoordY);
%targetMaskRegion = roipoly(targetImage/255,sourceMaskRegionCoordX-min(sourceMaskRegionCoordX)+targetPosX,sourceMaskRegionCoordY-min(sourceMaskRegionCoordY)+targetPosY);

%% Define Boundary and Omega

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
omegaPixelCoords = find(omega);
for i = 1:size(boundaryCoordX)
    omega(boundaryCoordX(i),boundaryCoordY(i))=0;
end

% % Now construct the linear function
[omegaPixelCoordX, omegaPixelCoordY] = find(omega);
result(omegaPixelCoords)=0;

% Mask region excluding the boundary - Omega
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

%% Importing Gradients
% importingGradients = zeros(size(sourceImage));
% for c = 1: channel
%     for i = 1:size(omegaPixelCoordX)
%         sourceMaskCentralPixel = sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),c);
%         sourceMaskNeighbour1 = sourceMaskCentralPixel - sourceImage(sourceOmegaPixelCoordX(i)-1,sourceOmegaPixelCoordY(i),c);
%         sourceMaskNeighbour2 = sourceMaskCentralPixel - sourceImage(sourceOmegaPixelCoordX(i)+1,sourceOmegaPixelCoordY(i),c);
%         sourceMaskNeighbour3 = sourceMaskCentralPixel - sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i)-1,c);
%         sourceMaskNeighbour4 = sourceMaskCentralPixel - sourceImage(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i)+1,c);
%         importingGradients(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),c)=4*sourceMaskCentralPixel-(sourceMaskNeighbour1+sourceMaskNeighbour2+sourceMaskNeighbour3+sourceMaskNeighbour4);
%     end
% end

laplacianFilterD4 = [0 -1 0; -1 4 -1; 0 -1 0];
%laplacianFilterD8 = [-1 -1 -1; -1 8 -1; -1,-1,-1];
importingGradients = imfilter((sourceImage), laplacianFilterD4, 'replicate');

%% Construct Matrix b with Importing Gradients
gridSize = length(omegaPixelCoordX);
for c=1:channel
    b = zeros(gridSize,1);
    singleChannelResult = targetImage(:,:,c);
    for i = 1:gridSize
        if(boundaryRegion(omegaPixelCoordX(i)-1,omegaPixelCoordY(i)) == 1)
            % if up of pi is in boundary
            b(i) = b(i) + targetImage(omegaPixelCoordX(i)-1,omegaPixelCoordY(i),c);
        end
        if(boundaryRegion(omegaPixelCoordX(i),omegaPixelCoordY(i)+1) == 1)
            % if right of pi is in boundary
            b(i) = b(i) + targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i)+1,c);
        end
        if(boundaryRegion(omegaPixelCoordX(i)+1,omegaPixelCoordY(i)) == 1)
            % if down of pi is in boundary
            b(i) = b(i) + targetImage(omegaPixelCoordX(i)+1,omegaPixelCoordY(i),c);
        end
        if(boundaryRegion(omegaPixelCoordX(i),omegaPixelCoordY(i)-1) == 1)
            % if left of pi is in boundary
            b(i) = b(i) + targetImage(omegaPixelCoordX(i),omegaPixelCoordY(i)-1,c);
        end
        b(i) = b(i) + importingGradients(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),c);
    end
    
    x = A\b;

    for i = 1:gridSize
        singleChannelResult(omegaPixelCoordX(i),omegaPixelCoordY(i)) = x(i);
    end

    result(:,:,c) = singleChannelResult;
end

figure();
imshow(result/255);
title("Importing Gradients Result");

end