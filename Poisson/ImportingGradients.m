function ImportingGradients(sourceImageRaw, targetImageRaw, rgbMode)
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
targetMaskRegion = roipoly(targetImage,sourceMaskRegionCoordX,sourceMaskRegionCoordY);

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

% Mask region excluding the boundary - Omega
sourceOmega = sourceMaskRegion;
for i = 1:size(sourceBoundaryCoordX)
    sourceOmega(sourceBoundaryCoordX(i),sourceBoundaryCoordY(i))=0;
end

[sourceOmegaPixelCoordX,sourceOmegaPixelCoordY] = find(sourceOmega);

omegaPixelCoords = find(omega);
omegaPixelOrder = zeros(size(omega));
for i = 1:size(omegaPixelCoords)
    omegaPixelOrder(omegaPixelCoords(i))=i;
end
A = delsq(omegaPixelOrder);

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
        b(i) = b(i) + Source_Laplace(sourceOmegaPixelCoordX(i),sourceOmegaPixelCoordY(i),c);
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