function [result] = nonLocalMeansNaive(targetImage, sigma, h, patchSize, searchWindowSize)

%% Non-Local Mean Denoising - Naive

targetImage = double(rgb2gray(targetImage));

% Get row and col from original image 
[imageRow, imageCol] = size(targetImage);

% Preallocate
result = targetImage;

% Determine the patch boundary with respect to the center point
patchLimit = (patchSize-1)/2;

% Determine the window boundary with respect to the center point
windowLimit = (searchWindowSize-1)/2;

% Create the valid area for patch generation so that no patch will overflow
% to the outside of image 
%   ---------------------------- <- TargetImage
%   |         |PL              |
%   |    *----------------|    |
%   | PL |Patch Generation|    |
%   |----|      Area      |    | -> *: CurrentPosition e.g.(r,c)
%   |    |----------------|    |               
%   |                          |
%   ---------------------------- -> PL: PatchLimit (Distance)

patchGenerationStartRow = 1+patchLimit;
patchGenerationEndRow = imageRow-patchLimit;
patchGenerationStartCol = 1+patchLimit;
patchGenerationEndCol = imageCol-patchLimit;
     
for row = patchGenerationStartRow:patchGenerationEndRow     
    for col = patchGenerationStartCol:patchGenerationEndCol  
            
%         % Generate the window area using provided parameters
%         % Boundary check: ignore out of boundary area and shift the row col by
%         % patch limit
%         %
%         windowStartRow = max(row - windowLimit, 1+patchLimit);
%         windowEndRow = min(row + windowLimit, imageRow-patchLimit);
%         windowStartCol = max(col - windowLimit, 1+patchLimit);
%         windowEndCol = min(col + windowLimit, imageCol-patchLimit);
%         
%         % Get the current patch centered at r,c
%         centralPatch = targetImage(row-patchLimit:row+patchLimit,col-patchLimit:col+patchLimit);      
%         
%         offsetCounter=1;
%         
%         distances = [];     
%         offsetsRows = [];
%         offsetsCols = [];
%         
%         % Loop through all the pixels in the SearchWindow 
%         for r = windowStartRow : windowEndRow
%             for c = windowStartCol : windowEndCol    
%                 % Calculate the offset
%                 offsetsRows(offsetCounter) = r-row;       
%                 offsetsCols(offsetCounter) = c-col;
%                 % Get the patch at this position
%                 slidePatch = targetImage(r-patchLimit:r+patchLimit,c-patchLimit:c+patchLimit);
%                 % Compute the sum of squared differences
%                 distances(offsetCounter) = sum((slidePatch - centralPatch).^2, 'all');           
%                 offsetCounter=offsetCounter+1;            
%             end
%         end
%                      
%         % Compute the current weight
%         currentWeight = computeWeighting(distances, h, sigma, patchSize);
%         
%         % 
%         pixelWeightImage = targetImage(row + offsetsRows(1):row+offsetsRows(offsetCounter-1), col+offsetsCols(1):col+offsetsCols(offsetCounter-1))';
%         
%         testImage = reshape(pixelWeightImage, offsetCounter-1, 1);
%         
%         pixelWeightImage = testImage.* currentWeight;
%         
%         % Accumulate the pixel weight sum
%         pixelWeightSum = sum(pixelWeightImage, 'all');
%         
%         % Accumulate the weight sum
%         weightSum = sum(currentWeight, 'all');
%        
%         result(row, col) = pixelWeightSum/weightSum;
         [offsetRows, offsetCols, distances]=templateMatchingNaive(targetImage, row, col, patchSize, searchWindowSize);
        
        weight =  computeWeighting(distances, h, sigma, patchSize);
        sum_weight = sum(weight);

        a = targetImage(row+offsetRows(1):row+offsetRows(length(offsetRows)),col+offsetCols(1):col+offsetCols(length(offsetRows)))';
        b = reshape(a,1,length(offsetRows)).*weight;
        
        sum_pixel_in_wind = sum(b);
        
        
        result(row,col) =  sum_pixel_in_wind/sum_weight;     
    end
end
end