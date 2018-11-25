 function [offsetsRows, offsetsCols, distances] = templateMatchingNaive(targetImage,row,col,patchSize,searchWindowSize)
% This function should for each possible offset in the search window
% centred at the current row and col, save a value for the offsets and
% patch distances, e.g. for the offset (-1,-1)
% offsetsRows(1) = -1;
% offsetsCols(1) = -1;
% distances(1) = 0.125;

% The distance is simply the SSD over patches of size patchSize between the
% 'template' patch centred at row and col and a patch shifted by the
% current offset

%% Template Matching (Naive)

% % Preallocate
% windowRegionSize = searchWindowSize.^2;
% offsetsRows = zeros(windowRegionSize,1);
% offsetsCols = zeros(windowRegionSize,1);
% distances = zeros(windowRegionSize, 1);

% Get row and col from original image 
[imageRow, imageCol] = size(targetImage);

% Determine the patch boundary with respect to the center point
patchLimit = (patchSize-1)/2;

% Determine the window boundary with respect to the center point
windowLimit = (searchWindowSize-1)/2;

% Generate the patch using provided parameters
centralPatch = targetImage(row-patchLimit:row+patchLimit,col-patchLimit:col+patchLimit);

% Generate the window area using provided parameters
% Boundary check: ignore out of boundary area and shift the row col by
% patch limit
% |------------------------| <- Window
% |           WL           |
% |     |------------|     |
% |     |     PL     |     |
% |     |     |      |     | WL: WindowLimit
% |-WL--|-PL--*-PL-----WL---------------- <- TargetImage   
% |     |     |######|&&&&&|            | 
% |     |     PL#####|&&&&&|            | -> #: Valid area in patch
% |     |---- |------|&&&&&|            | -> &: Valid area in window    
% |           WL&&&&&&&&&&&|            | -> *: CurrentPosition e.g.(r,c)   
% |------------------------|            | 
%             |                         | 
%             |------------------------- PL: PatchLimit
windowStartRow = max(row - windowLimit, 1+patchLimit);
windowEndRow = min(row + windowLimit, imageRow-patchLimit);
windowStartCol = max(col - windowLimit, 1+patchLimit);
windowEndCol = min(col + windowLimit, imageCol-patchLimit);

% Calculate the offset and SSD
offsetCounter=1;

for r = windowStartRow:windowEndRow
    for c = windowStartCol:windowEndCol
        
    % Calculate the offset
    offsetsRows(offsetCounter) = r-row;
    offsetsCols(offsetCounter) = c-col;
    
    % Get the patch at this position
    slidePatch = targetImage(r-patchLimit:r+patchLimit,c-patchLimit:c+patchLimit);
    
    % Compute the sum of squared differences
    distances(offsetCounter) = sum((slidePatch - centralPatch).^2, 'all'); 
    
    offsetCounter=offsetCounter+1;
    end
end
end