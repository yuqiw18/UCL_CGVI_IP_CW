function [result] = nonLocalMeansNaive(targetImage, sigma, h, patchSize, searchWindowSize)

%% Non-Local Mean Denoising - Naive

targetImage = im2double(rgb2gray(targetImage));

% Get row and col from original image 
[imageRow, imageCol] = size(targetImage);

% Preallocate
result = zeros(imageRow, imageCol);

% Determine the patch boundary with respect to the center point
patchLimit = (patchSize-1)/2;

% Determine the window boundary with respect to the center point
windowLimit = (searchWindowSize-1)/2;

% Create the valid area for patch generation so that no patch will overflow
% to the outside of image 
%   ---------------------------- <- TargetImage
%   |         |PL              |
%   |    |----------------|    |
%   | PL |Patch generation|    |
%   |----|      Area      |    |
%   |    |----------------|    |               
%   |                          |
%   ---------------------------- -> PL: PatchLimit (Distance)

patchGenerationStartRow = 1+patchLimit;
patchGenerationEndRow = imageRow-patchLimit;
patchGenerationStartCol = 1+patchLimit;
patchGenerationEndCol = imageCol-patchLimit;
     
for r = patchGenerationStartRow:patchGenerationEndRow  
    
    % Generate the window area using provided parameters
    % Boundary check: ignore out of boundary area and shift the row col by
    % patch limit
    %
    windowStartRow = max(r - windowLimit, 1+patchLimit);
    windowEndRow = min(r + windowLimit, imageRow-patchLimit);
    
    for c = patchGenerationStartCol:patchGenerationEndCol  
             
        windowStartCol = max(c - windowLimit, 1+patchLimit);
        windowEndCol = min(c + windowLimit, imageCol-patchLimit);
        
        % Get the current patch centered at r,c
        centralPatch = targetImage(r-patchLimit:r+patchLimit,c-patchLimit:c+patchLimit);      
        
        % Reset the weights
        pixelWeightSum = 0;
        weightSum = 0;

        % Loop through all the pixels in the SearchWindow 
        for currentSearchWindowRow = windowStartRow : windowEndRow
            for currentSearchWindowCol = windowStartCol : windowEndCol

                % Retrieve the patch at current position
                slidePatch = double(targetImage(currentSearchWindowRow-patchLimit:currentSearchWindowRow+patchLimit, currentSearchWindowCol-patchLimit:currentSearchWindowCol+patchLimit));

                % Compute the sum of squared differences
                distance = sum((slidePatch - centralPatch).^2, 'all'); 

                % Compute the current weight
                currentWeight = computeWeighting(distance, h, sigma, patchSize);

                % Accumulate the pixel weight sum
                pixelWeightSum = pixelWeightSum + slidePatch(1+patchLimit,1+patchLimit) * currentWeight;

                % Accumulate the weight sum
                weightSum = weightSum + currentWeight;
            end
        end
        
        result(r, c) = pixelWeightSum/weightSum;
    end
end
end