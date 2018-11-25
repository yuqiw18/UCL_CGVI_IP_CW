function [result] = nonLocalMeansNaive(targetImage, sigma, h, patchSize, searchWindowSize)

%% Non-Local Mean Denoising (Naive)

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
%   |----|      Area      |    | -> *: CurrentPosition e.g.(row,col)
%   |    |----------------|    |               
%   |                          |
%   ---------------------------- -> PL: PatchLimit
patchGenerationStartRow = 1+patchLimit;
patchGenerationEndRow = imageRow-patchLimit;
patchGenerationStartCol = 1+patchLimit;
patchGenerationEndCol = imageCol-patchLimit;
     
for row = patchGenerationStartRow:patchGenerationEndRow     
   
    % Generate the window area using provided parameters
    % Boundary check: ignore out of boundary area and shift the row col by
    % patch limit 
    windowStartRow = max(row - windowLimit, 1+patchLimit);
    windowEndRow = min(row + windowLimit, imageRow-patchLimit);
    
    for col = patchGenerationStartCol:patchGenerationEndCol  

        windowStartCol = max(col - windowLimit, 1+patchLimit);
        windowEndCol = min(col + windowLimit, imageCol-patchLimit);
        
        % Get the current patch centered at r,c
        centralPatch = targetImage(row-patchLimit:row+patchLimit,col-patchLimit:col+patchLimit);      
        
        % Reset values for each loop
        offsetCounter=1;
        distances = [];     
        offsetsRows = [];
        offsetsCols = [];
        weightSum = 0;
        pixelWeightSum = 0;
        
        % Loop through all the pixels in the SearchWindow 
        for r = windowStartRow : windowEndRow
            for c = windowStartCol : windowEndCol    
                % Calculate the offset
                offsetsRows(offsetCounter) = r-row;       
                offsetsCols(offsetCounter) = c-col;
                
                % Get the patch at this position (currentPatch)
                slidePatch = targetImage(r-patchLimit:r+patchLimit,c-patchLimit:c+patchLimit);
                
                % Compute the sum of squared differences
                distances(offsetCounter) = sum((slidePatch - centralPatch).^2, 'all');           
                
                % Get the current pixel value
                currentPixel = targetImage(row+offsetsRows(offsetCounter),col+offsetsCols(offsetCounter));
                
                % Compute current weight from current SSD
                currentWeight = computeWeighting(distances(offsetCounter), h, sigma, patchSize);
                
                % Accumulate the weighted pixel sum
                pixelWeightSum = pixelWeightSum + currentPixel * currentWeight;
            
                % Accumulate the weight sum
                weightSum = weightSum + currentWeight;
                
                % Counter
                offsetCounter=offsetCounter+1;     
            end
        end        
        
        % Assign the denoised value to current position
        result(row,col) =  pixelWeightSum/weightSum;     
    end
end
end