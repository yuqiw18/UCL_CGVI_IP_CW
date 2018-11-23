function [offsetsRows, offsetsCols, distances] = templateMatchingIntegralImage(targetImage ,row, col, patchSize, searchWindowSize)
% This function should for each possible offset in the search window
% centred at the current row and col, save a value for the offsets and
% patch distances, e.g. for the offset (-1,-1)
% offsetsX(1) = -1;
% offsetsY(1) = -1;
% distances(1) = 0.125;
% 
% The distance is simply the SSD over patches of size patchSize between the
% 'template' patch centred at row and col and a patch shifted by the
% current offset
% 
% This time, use the integral image method!
% NOTE: Use the 'computeIntegralImage' function developed earlier to
% calculate your integral images
% NOTE: Use the 'evaluateIntegralImage' function to calculate patch sums

%% Template Matching (Integral Image)
% Preallocate
windowRegionSize = searchWindowSize.^2;
offsetsRows = zeros(windowRegionSize,1);
offsetsCols = zeros(windowRegionSize,1);
distances = zeros(windowRegionSize, 1);
differenceImageSet = cell(searchWindowSize, searchWindowSize);

% Get row and col from original image 
[imageRow, imageCol] = size(targetImage);

% Determine the patch boundary with respect to the center point
patchLimit = (patchSize-1)/2;

% Determine the window boundary with respect to the center point
windowLimit = (searchWindowSize-1)/2;

% Generate the window area using provided parameters
% Boundary check: ignore out of boundary area and shift the row col by
% patch limit

windowStartRow = max(row - windowLimit, 1+patchLimit);
windowEndRow = min(row + windowLimit, imageRow-patchLimit);
windowStartCol = max(col - windowLimit, 1+patchLimit);
windowEndCol = min(col + windowLimit, imageCol-patchLimit);

% Calculate the offset
offsetCounter=1;

for offsetRow = -windowLimit:windowLimit
    for offsetCol = -windowLimit:windowLimit
        
        % 
        shiftedImage = imtranslate(targetImage, [offsetCol, offsetRow]);
        
        % Calculate the difference image
        differenceImage = shiftedImage - targetImage;
        
        % Store the difference image 
        differenceImageSet{offsetRow+windowLimit+1,offsetCol+windowLimit+1} = computeIntegralImage(differenceImage.^2);
    end
end

for r = windowStartRow:windowEndRow
    for c = windowStartCol:windowEndCol
    
    % Calculate the offset
    offsetsRows(offsetCounter) = r-row;
    offsetsCols(offsetCounter) = c-col;
    
    % Get the patch at this position using integral image
    integralImage = differenceImageSet{offsetsRows(offsetCounter)+windowLimit+1, offsetsCols(offsetCounter)+windowLimit+1};
    
    % Compute the sum of squared differences
    distances(offsetCounter)= evaluateIntegralImage(integralImage, r, c, patchSize);
    
    offsetCounter=offsetCounter+1;
    end    
end
end