function [result] = nonLocalMeansIntegralImage(targetImage, sigma, h, patchSize, searchWindowSize)

%% Non-Local Mean Denoising - Integral
% Preallocate
targetImage = im2double(rgb2gray(targetImage));

% Get row and col from original image 
[imageRow, imageCol] = size(targetImage);

% Preallocate
result = zeros(imageRow, imageCol);

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
%   | PL |Patch generation|    | -> *: CurrentPosition e.g.(r,c)
%   |----|      Area      |    |
%   |    |----------------|    |               
%   |                          |
%   ---------------------------- -> PL: PatchLimit (Distance)

patchGenerationStartRow = 1+patchLimit;
patchGenerationEndRow = imageRow-patchLimit;
patchGenerationStartCol = 1+patchLimit;
patchGenerationEndCol = imageCol-patchLimit;

for currentSearchWindowRow = -windowLimit:windowLimit
    for currentSearchWindowCol = -windowLimit:windowLimit
        
        shiftedImage = imtranslate(targetImage,[currentSearchWindowCol, currentSearchWindowRow]); 
        
        % Calculate the difference image
        differenceImage = shiftedImage - targetImage;
        
        % Store the difference image 
        differenceImageSet{currentSearchWindowRow+windowLimit+1,currentSearchWindowCol+windowLimit+1} = computeIntegralImage(differenceImage.^2);
    end
end

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

        % Reset the weights
        pixelWeightSum = 0;
        weightSum = 0;

        % Loop through all the pixels in the SearchWindow 
        for currentSearchWindowRow = windowStartRow : windowEndRow
            for currentSearchWindowCol = windowStartCol : windowEndCol

                offsetRow = currentSearchWindowRow - r;
                offsetCol = currentSearchWindowCol - c;

                % retrive the Integral Image for the corresponding
                % offset
                integralImage = differenceImageSet{offsetRow+windowLimit+1, offsetCol+windowLimit+1};

                % Compute the distance (how is explained inside the function)
                distance = evaluateIntegralImage(integralImage, currentSearchWindowRow, currentSearchWindowCol, patchSize);

                % Compute the current weight
                currentWeight = computeWeighting(distance, h, sigma, patchSize);

                % compute the weighted sum
                pixelWeightSum = pixelWeightSum + targetImage(currentSearchWindowRow,currentSearchWindowCol) * currentWeight;

                % keep adding the weights in order to normalize.
                weightSum = weightSum + currentWeight;
            end
        end

        result(r, c) = pixelWeightSum/weightSum;
    end
end
end