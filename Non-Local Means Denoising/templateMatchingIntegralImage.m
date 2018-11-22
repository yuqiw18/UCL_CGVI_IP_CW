function [offsetsRows, offsetsCols, distances] = templateMatchingIntegralImage(targetImage,row,col,patchSize, searchWindowSize)
tic
% This function should for each possible offset in the search window
% centred at the current row and col, save a value for the offsets and
% patch distances, e.g. for the offset (-1,-1)
% offsetsX(1) = -1;
% offsetsY(1) = -1;
% distances(1) = 0.125;

% The distance is simply the SSD over patches of size patchSize between the
% 'template' patch centred at row and col and a patch shifted by the
% current offset

% This time, use the integral image method!
% NOTE: Use the 'computeIntegralImage' function developed earlier to
% calculate your integral images
% NOTE: Use the 'evaluateIntegralImage' function to calculate patch sums

%% Template Matching (Integral Image)
% Preallocate
windowRegionSize = searchWindowSize.^2;
offsetsRows = zeros(windowRegionSize,1);
offsetsCols = zeros(windowRegionSize,1);
distances = randn(windowRegionSize, 1);

% Convert to double-type grayscale with normalisation
% targetImage = im2double(rgb2gray(targetImage));

% Get row and col from original image 
[imageRow, imageCol] = size(targetImage);

% Determine the patch boundary with respect to the center point
patchLimit = (patchSize-1)/2;

% Determine the window boundary with respect to the center point
windowLimit = (searchWindowSize-1)/2;

% windowStartRow = max(row - windowLimit, 1+patchLimit);
% windowEndRow = min(row + windowLimit, imageRow-patchLimit);
% windowStartCol = max(col - windowLimit, 1+patchLimit);
% windowEndCol = min(col + windowLimit, imageCol-patchLimit);

% Calculate the offset
i=1;
for r = -windowLimit:windowLimit
    for c = -windowLimit:windowLimit
    offsetsRows(i) = r-row;
    offsetsCols(i) = c-col;
    i=i+1;
    end    
end

% targetImageWindowStartRow = 1+patchLimit;
% targetImageWindowEndRow = imageRow-patchLimit;
% targetImageWindowStartCol = 1+patchLimit;
% targetImageWindowEndCol = imageCol-patchLimit;

% For each offset in offsets
for offset = 1:i-1
    differenceImage = zeros(imageRow,imageCol);     
    for r = 1:imageRow
        for c = 1:imageCol
            if (r+offsetsRows(offset)<1 || r+offsetsRows(offset)>imageRow || c+offsetsCols(offset)<1 || c+offsetsCols(offset)>imageCol)
                differenceImage(r,c) = targetImage(r,c);      
            else
                differenceImage(r,c) = targetImage(r,c) - targetImage(r+offsetsRows(offset),c+offsetsCols(offset));
            end  
        end
    end 
    differenceImageIntegral = computeIntegralImage(differenceImage.^2);
    distances(offset) = evaluateIntegralImage(differenceImageIntegral, row, col, patchSize);
end
end