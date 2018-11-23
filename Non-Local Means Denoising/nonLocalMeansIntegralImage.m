function [result] = nonLocalMeansIntegralImage(targetImage, sigma, h, patchSize, searchWindowSize)

%% Non-Local Mean Denoising - Integral
% Preallocate

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

for currentSearchWindowRow = -windowLimit:windowLimit
    for currentSearchWindowCol = -windowLimit:windowLimit
        shiftedImage = imtranslate(targetImage,[currentSearchWindowCol, currentSearchWindowRow]); 
        differenceImage = shiftedImage - targetImage;
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

        % the same values in the other non local means version
        pixelWeightSum = 0;
        weightSum = 0;

        % Loop through all the pixels in the SearchWindow 
        for currentSearchWindowRow = windowStartRow : windowEndRow
            for currentSearchWindowCol = windowStartCol : windowEndCol

                offsetRow = currentSearchWindowRow - r;
                offsetCol = currentSearchWindowCol - c;

                % retrive the Integral Image for the corresponding
                % offset
                integral_image = differenceImageSet{offsetRow+windowLimit+1, offsetCol+windowLimit+1};

                % Compute the distance (how is explained inside the function)
                distance = evaluateIntegralImage(integral_image, currentSearchWindowRow, currentSearchWindowCol, patchSize);

                %compute the weights
                weight = computeWeighting(distance, h, sigma, patchSize);

                % compute the weighted sum
                pixelWeightSum = pixelWeightSum + targetImage(currentSearchWindowRow,currentSearchWindowCol) * weight;

                % keep adding the weights in order to normalize.
                weightSum = weightSum + weight;
            end
        end

        % store the resulting denoised pixel at location (row, col)
        result(r, c) = pixelWeightSum/weightSum;
    end
end

% We need to normalize to actually see something otherwise is going to
% bee too bright.
%result = 255*(result - min(result(:))) / (max(result(:)) - min(result(:)));
%result = uint8(result);
end