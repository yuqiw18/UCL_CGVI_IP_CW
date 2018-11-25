function [result] = nonLocalMeansIntegralImage(targetImage, sigma, h, patchSize, searchWindowSize)

%% Non-Local Mean Denoising - Integral
% 
targetImage = double(rgb2gray(targetImage));

% Get row and col from original image 
[imageRow, imageCol] = size(targetImage);

% Preallocate
% result = double(zeros(imageRow, imageCol));
result = targetImage;

% Determine the patch boundary with respect to the center point
patchLimit = (patchSize-1)/2;

% Determine the window boundary with respect to the center point
windowLimit = (searchWindowSize-1)/2;

differenceImageSet = cell(searchWindowSize, searchWindowSize);

% Create the valid area for patch generation so that no patch will overflow
% to the outside of image 
%   ---------------------------- <- TargetImage
%   |         |PL              |
%   |    *----------------|    |
%   | PL |Patch Generation|    | -> *: CurrentPosition e.g.(r,c)
%   |----|      Area      |    |
%   |    |----------------|    |               
%   |                          |
%   ---------------------------- -> PL: PatchLimit (Distance)

patchGenerationStartRow = 1+patchLimit;
patchGenerationEndRow = imageRow-patchLimit;
patchGenerationStartCol = 1+patchLimit;
patchGenerationEndCol = imageCol-patchLimit;

% Extract the difference images
for dRow = -windowLimit:windowLimit
    for dCol = -windowLimit:windowLimit
        
        shiftedImage = double(zeros(imageRow, imageCol));
        
        % By checking the offsets we can figure out which direction the image
        % should be shifted to
        if (dRow > 0 && dCol > 0) 
            shiftedImage(1+dRow:imageRow, 1+dCol:imageCol) = targetImage(1:imageRow-dRow,1:imageCol-dCol);
        elseif (dRow <= 0 && dCol <= 0 )
            shiftedImage(1:imageRow+dRow, 1:imageCol+dCol) = targetImage(1-dRow:imageRow,1-dCol:imageCol);
        elseif (dRow > 0 && dCol <= 0)
            shiftedImage(1+dRow:imageRow, 1:imageCol+dCol) = targetImage(1:imageRow-dRow,1-dCol:imageCol);
        elseif (dRow <=0 && dCol > 0)
            shiftedImage(1:imageRow+dRow, 1+dCol:imageCol) = targetImage(1-dRow:imageRow,1:imageCol-dCol);
        end
        
        % Calculate the difference image
        differenceImage = shiftedImage - targetImage;
        
        % Store the difference image 
        differenceImageSet{dRow+windowLimit+1,dCol+windowLimit+1} = computeIntegralImage(differenceImage.^2);
    end
end

for row = patchGenerationStartRow:patchGenerationEndRow
    % Generate the window area using provided parameters
    % Boundary check: ignore out of boundary area and shift the row col by
    % patch limit
    
    windowStartRow = max(row - windowLimit, 1+patchLimit);
    windowEndRow = min(row + windowLimit, imageRow-patchLimit);
    
    for col = patchGenerationStartCol:patchGenerationEndCol
        
        windowStartCol = max(col - windowLimit, 1+patchLimit);
        windowEndCol = min(col + windowLimit, imageCol-patchLimit);

        % Reset the weights
        pixelWeightSum = 0;
        weightSum = 0;

        % Loop through all the pixels in the SearchWindow 
        for dRow = windowStartRow : windowEndRow
            for dCol = windowStartCol : windowEndCol

                offsetRow = dRow - row;
                offsetCol = dCol - col;

                % Retrive the Integral Image for the corresponding
                % offset
                integralImage = differenceImageSet{offsetRow+windowLimit+1, offsetCol+windowLimit+1};

                % Compute the distance
                distance = evaluateIntegralImage(integralImage, dRow+patchLimit, dCol+patchLimit, patchSize);

                % Compute the current weight
                currentWeight = computeWeighting(distance, h, sigma, patchSize);

                % Compute the weighted pixel sum
                pixelWeightSum = pixelWeightSum + targetImage(dRow,dCol) * currentWeight;

                % Accumulate the weight sum
                weightSum = weightSum + currentWeight;
            end
        end
        
        % Denoised position
        result(row, col) = pixelWeightSum/weightSum;
    end
end
end