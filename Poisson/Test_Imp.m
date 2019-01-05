clear;
clc;

%% Image Setup
rgbMode = true;

% Load images
sourceImageRaw = imread("./images/falcon.jpg");
targetImageRaw = imread("./images/sky.jpg");

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

% disp(targetPosX);
% disp(targetPosY);
% 
% testX = sourceMaskRegionCoordX-1;
% testY = sourceMaskRegionCoordY-1;
% 
% disp(sourceMaskRegionCoordX);
% disp(testX);
% 
% shiftingTestX = sourceMaskRegionCoordX - min(sourceMaskRegionCoordX);
% disp(shiftingTestX);
% 
% shiftingTestX2 = sourceMaskRegionCoordX - min(sourceMaskRegionCoordX)+targetPosX;
% disp(shiftingTestX2);


% Generate the mask for selected position

targetMaskRegion = TargetMaskGenerator(sourceMaskRegion, sourceMaskRegionCoordX, sourceMaskRegionCoordY, targetPosX, targetPosY);

% targetMaskRegion = roipoly(targetImage/255,sourceMaskRegionCoordX,sourceMaskRegionCoordY);
% 
% testRegion = sourceMaskRegion;
% testRegion(1:min(sourceMaskRegionCoordY)-1,:)=[];
% testRegion(:,1:min(sourceMaskRegionCoordX)-1)=[];
% [wt,ht]= size(testRegion);
% 
% leftRegion = zeros(wt,round(targetPosX));
% newTestRegion = [leftRegion testRegion];
% 
% [wt,ht]= size(newTestRegion);
% 
% topRegion = zeros(round(targetPosY),ht);
% 
% newNewTestRegion = [topRegion;newTestRegion];
% 
% 
% targetMaskRegion = logical(newNewTestRegion);

% subplot(2,2,1);
% imshow(sourceMaskRegion);
% subplot(2,2,2);
% imshow(targetMaskRegion);
% subplot(2,2,3);
% imshow(newNewTestRegion);
% subplot(2,2,4);
% imshow(newTestRegion);

%shiftX=0;
%shiftY=0;
%%
%calculate the divergence using laplace caculator
templt = [0 -1 0; -1 4 -1; 0 -1 0];
Source_Laplace = imfilter((sourceImage), templt, 'replicate');

targetBoundary = bwboundaries(targetMaskRegion,'noholes');
boundaryCoords = cell2mat(targetBoundary);
boundaryCoordX = boundaryCoords(:,1);
boundaryCoordY = boundaryCoords(:,2);
boundaryRegion = zeros(size(targetMaskRegion));
for i = 1 : size(boundaryCoords,1) 
    boundaryRegion(boundaryCoordX(i),boundaryCoordY(i))=1;
end

sourceBoundary = bwboundaries(sourceMaskRegion,'noholes');
sourceBoundaryCoords = cell2mat(sourceBoundary);

% [w1,~]=size(sourceBoundaryCoords);
% [w2,~]=size(boundaryCoords);
% 
% while (w1 ~= w2)
%     disp("Mismatching coord");
%     sourceBoundary = bwboundaries(sourceMaskRegion,'noholes');
%     sourceBoundaryCoords = cell2mat(sourceBoundary);
%     [w1,~]=size(sourceBoundaryCoords);
%     [w2,~]=size(boundaryCoords);
% end

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