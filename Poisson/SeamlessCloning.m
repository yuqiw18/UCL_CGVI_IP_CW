%function SeamlessCloning(sourceImage, targetImage , rgbMode)

clear;
clc;

rgbMode = true;
sourceImage = double(imread("./images/jet.jpg"));
targetImage = double(imread("./images/sky.jpg"));

if(rgbMode == false)
    sourceImage = sourceImage(:,:,1);
    targetImage = targetImage(:,:,1);
end

[sourceMaskRegion, sourceMaskRegionCoordX, sourceMaskRegionCoordY ]= roipoly(sourceImage/255);

figure;
imshow(targetImage/255);
title('Pick a location to paste the selected region.(Pivot: Top-Left)');
[targetPosX, targetPosY] = ginput(1);

%% cropping mask from image in terms of the input 
offset = [abs(sourceMaskRegionCoordX(1)-targetPosX), abs(sourceMaskRegionCoordY(1) -targetPosY)];
sourceMaskRegionCoordX = int16(sourceMaskRegionCoordX); 
sourceMaskRegionCoordY = int16(sourceMaskRegionCoordY); 
source_col = (sourceMaskRegionCoordX)+int16(offset(1));
source_row = (sourceMaskRegionCoordY)+int16(offset(2));

importingGradients = targetImage;
mixingGradients = targetImage;
[~,~,channel]=size(targetImage);

%% 
for c = 1:channel
imgSingleChannel_target = sourceImage(:,:,c);
imgSingleChannel_source = targetImage(:,:,c);

sourceMaskRegion = roipoly(imgSingleChannel_target/255,sourceMaskRegionCoordX,sourceMaskRegionCoordY);
mask_source = roipoly(imgSingleChannel_source/255,source_col,source_row);

maskSource_value = imgSingleChannel_source .* mask_source;
maskTarget_value = imgSingleChannel_target .* sourceMaskRegion;

indexOfBorder_target = cell2mat(bwboundaries(maskTarget_value));
% crop the border from mask to get a smaller mask
small_targetMask = sourceMaskRegion;
for n =1:size(indexOfBorder_target,1)
    small_targetMask(indexOfBorder_target(n,1), indexOfBorder_target(n,2)) = 0;
end
smallTargetMask_value = imgSingleChannel_target .* small_targetMask;
indexOfSmallTargetMask = find(smallTargetMask_value);
% order all the non-zero pixel in the smaller mask
smallTargetMask_order = zeros(size(smallTargetMask_value));
for n =1:size(indexOfSmallTargetMask);
    smallTargetMask_order(indexOfSmallTargetMask(n)) = n;
end
% create a laplacian operator A based on the smaller mask
A = delsq(smallTargetMask_order);


%% caculate destination function f* defines over (image - cropped_part)
fDestinationBorder_index = zeros(size(indexOfBorder_target));
fDestinationBorder_index(:,1) = int16(indexOfBorder_target(:,1))+ (offset(2));
fDestinationBorder_index(:,2) = int16(indexOfBorder_target(:,2))+ (offset(1));

fDestinationBorder_value = zeros(size(maskTarget_value));
for n =1:size(fDestinationBorder_index,1);
    fDestinationBorder_value(indexOfBorder_target(n,1),indexOfBorder_target(n,2)) =...
        imgSingleChannel_source(fDestinationBorder_index(n,1),fDestinationBorder_index(n,2));
end
[maskTarget_row, maskTarget_col] = find(sourceMaskRegion);
f_destination = zeros(size(imgSingleChannel_target));
for n =1:size(maskTarget_row)
    neighbour1 = fDestinationBorder_value(maskTarget_row(n)-1, maskTarget_col(n));
    neighbour2 = fDestinationBorder_value(maskTarget_row(n)+1, maskTarget_col(n));
    neighbour3 = fDestinationBorder_value(maskTarget_row(n), maskTarget_col(n)-1);
    neighbour4 = fDestinationBorder_value(maskTarget_row(n), maskTarget_col(n)+1);
    f_destination(maskTarget_row(n), maskTarget_col(n)) = neighbour1 + neighbour2 + neighbour3 + neighbour4;
end
for n =1:size(indexOfBorder_target,1);
    f_destination(indexOfBorder_target(n,1), indexOfBorder_target(n,2)) = 0;
end

%% direct cloning from target image to source image
[smallTargetMask_row,smallTargetMask_col] = find(small_targetMask);
result_directCloning = imgSingleChannel_source;

for n =1:size(smallTargetMask_row)
    result_directCloning(int16(smallTargetMask_row(n)+offset(2)),int16(smallTargetMask_col(n)+offset(1))) =...
        imgSingleChannel_target(int16(smallTargetMask_row(n)),int16(smallTargetMask_col(n)));
end
%% Importing Gradients
Vpq_importing  = zeros(size(imgSingleChannel_target));
[maskTarget_row, maskTarget_col] = find(sourceMaskRegion);
for n =1:size(maskTarget_row)
    certain = maskTarget_value(maskTarget_row(n),maskTarget_col(n));
    neighbour1 = maskTarget_value(maskTarget_row(n)-1,maskTarget_col(n));
    neighbour2 = maskTarget_value(maskTarget_row(n)+1,maskTarget_col(n));
    neighbour3 = maskTarget_value(maskTarget_row(n),maskTarget_col(n)-1);
    neighbour4 = maskTarget_value(maskTarget_row(n),maskTarget_col(n)+1);
    Vpq_importing(maskTarget_row(n),maskTarget_col(n)) = 4*certain - neighbour1-neighbour2-neighbour3-neighbour4;
end
for n =1:size(indexOfBorder_target,1)
    Vpq_importing(indexOfBorder_target(n,1),indexOfBorder_target(n,2))=0;
end
fq = f_destination + Vpq_importing;
f_importing = A \ fq(indexOfSmallTargetMask);
% imshow(Vpq_importing);
result_importingGradient = imgSingleChannel_source;
for n =1:size(smallTargetMask_row);
    result_importingGradient(int16(smallTargetMask_row(n)+offset(2)),int16(smallTargetMask_col(n)+ offset(1))) = f_importing(n);
end
importingGradients(:,:,c) = result_importingGradient;

%% Mixing Gradients
Vpq_mixing = zeros(size(imgSingleChannel_target));
[maskSource_row, maskSource_col] = find(mask_source);
for n =1:size(maskTarget_row)
    certain_target =  maskTarget_value(maskTarget_row(n), maskTarget_col(n));
    neighbour1_target = certain_target - maskTarget_value(maskTarget_row(n)-1, maskTarget_col(n));
    neighbour2_target = certain_target - maskTarget_value(maskTarget_row(n)+1, maskTarget_col(n));
    neighbour3_target = certain_target - maskTarget_value(maskTarget_row(n), maskTarget_col(n)-1);
    neighbour4_target = certain_target - maskTarget_value(maskTarget_row(n), maskTarget_col(n)+1);
    
    certain_source = maskSource_value(maskSource_row(n),maskSource_col(n));
    neighbour1_source = certain_source - maskSource_value(maskSource_row(n)-1,maskSource_col(n));
    neighbour2_source = certain_source - maskSource_value(maskSource_row(n)+1,maskSource_col(n));
    neighbour3_source = certain_source - maskSource_value(maskSource_row(n),maskSource_col(n)-1);
    neighbour4_source = certain_source - maskSource_value(maskSource_row(n),maskSource_col(n)+1);
    
    if abs(neighbour1_target) < abs(neighbour1_source)
        neighbour1 = neighbour1_source;
    else
        neighbour1 = neighbour1_target;
    end
    if abs(neighbour2_target) < abs(neighbour2_source)
        neighbour2 = neighbour2_source;
    else
        neighbour2 = neighbour2_target;
    end
    if abs(neighbour3_target) < abs(neighbour3_source)
        neighbour3 = neighbour3_source;
    else
        neighbour3 = neighbour3_target;
    end
    if abs(neighbour4_target) < abs(neighbour4_source)
        neighbour4 = neighbour4_source;
    else
        neighbour4 = neighbour4_target;
    end
        
    Vpq_mixing(maskTarget_row(n),maskTarget_col(n)) = neighbour1+neighbour2+neighbour3+neighbour4;
end

for n =1:size(indexOfBorder_target,1)
    Vpq_mixing(indexOfBorder_target(n,1),indexOfBorder_target(n,2)) =0;
end

fq = f_destination + Vpq_mixing;
f_mixing = A \ fq(indexOfSmallTargetMask);
result_mixingGradient = imgSingleChannel_source;
for n =1:size(smallTargetMask_row);
    result_mixingGradient(int16(smallTargetMask_row(n)+offset(2)),int16(smallTargetMask_col(n)+offset(1))) = f_mixing(n);
end

mixingGradients(:,:,c) = result_mixingGradient;
end

subplot(1,2,1);
imshow(importingGradients/255);
title('Importing Gradients');

subplot(1,2,2);
imshow(mixingGradients/255);
title('Mixing Gradients');
%end