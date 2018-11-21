function [offsetsRows, offsetsCols, distances] = templateMatchingIntegralImage(targetImage,row,col,patchSize, searchWindowSize)
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

% Calculate the offset and SSD from difference image
for i=1:25
for r = 1:imageRow
    for c = 1:imageCol
    offsetsRows(i) = r-row;
    offsetsCols(i) = c-col;  
    differenceImage = zeros(size(targetImage));
        if (r+offsetsRows(i)<1 || r+offsetsRows(i)>imageRow || c+offsetsCols(i)<1 || c+offsetsCols(i)>imageCol)
            differenceImage(r,c) = targetImage(r,c);
        else
            differenceImage(r,c) = targetImage(r,c) - targetImage(r+offsetsRows(i),c+offsetsCols(i));
        end
    end
end
    metricSSD = (differenceImage).^2;
    [integralDiffImage, ~] = computeIntegralImage(metricSSD);
    distances(i) = evaluateIntegralImage(integralDiffImage, row, col, patchSize);
end
end