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
%   |----|      Area      |    | -> *: CurrentPosition e.g.(row,col)
%   |    |----------------|    |               
%   |                          |
%   ---------------------------- -> PL: PatchLimit (Distance)

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
        
        % Loop through all the pixels in the SearchWindow 
        for r = windowStartRow : windowEndRow
            for c = windowStartCol : windowEndCol    
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
        
        % Reset the weights
        weightSum = 0;
        pixelWeightSum = 0;
        
        % Retrieve the image block
        % e.g.
        % (-1,-1) (-1,0) (-1,1)
        % (0,-1)  (0,0) (0,1)
        % (1,-1)  (1,0) (1,1)
        imageBlock = targetImage(row+offsetsRows(1):row+offsetsRows(offsetCounter-1),col+offsetsCols(1):col+offsetsCols(offsetCounter-1));
        
        % To calculate the weighted image block   
        % We need to multiply each value by its corresponding weight
        
        % However currentWeight is generated from a 1 by offsetCounter - 1
        % distances matrix
        % And imageBlock is a A by A matrix
        % We need to match the dimesion so that the calculation can be done
  
        % Though the logic should be right, the result is different from
        % integral algorithm
        % After some diggings we noticed that matlab the row and col is
        % swapped due the way matlab extract the value from matrix
        % Therefore we need to transpose the imageBock so that each value
        % can match its corresponding weight
        imageBlock = transpose(imageBlock);
        
        % Reshape to 1 by offsetCounter - 1 matrix
        imageBlock = reshape(imageBlock, offsetCounter-1, 1);
        
        % Calculate the weight for the corresponding position
        for i = 1:offsetCounter-1 
            
            % Compute the current weight
            currentWeight = computeWeighting(distances(i), h, sigma, patchSize); 
            
            % Compute the weighted pixel sum
            pixelWeightSum = pixelWeightSum + imageBlock(i,1) * currentWeight;
            
            % Accumulate the weight sum
            weightSum = weightSum + currentWeight;
        end               
          
        % Assign the denoised value to current position
        result(row,col) =  pixelWeightSum/weightSum;     
    end
end
end