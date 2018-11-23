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

windowStartRow = max(row - windowLimit, 1+patchLimit);
windowEndRow = min(row + windowLimit, imageRow-patchLimit);
windowStartCol = max(col - windowLimit, 1+patchLimit);
windowEndCol = min(col + windowLimit, imageCol-patchLimit);

% targetImageWindowStartRow = 1+patchLimit;
% targetImageWindowEndRow = imageRow-patchLimit;
% targetImageWindowStartCol = 1+patchLimit;
% targetImageWindowEndCol = imageCol-patchLimit;
% For each offset in offsets
% for offset = 1:searchWindowSize^2-1
%     differenceImage = zeros(imageRow,imageCol); 
%     
%     for ti = targetImageWindowStartRow:targetImageWindowEndRow
%         for tj = targetImageWindowStartCol:targetImageWindowEndCol
%             if (ti+offsetsRows(offset)<targetImageWindowStartRow || ti+offsetsRows(offset)>targetImageWindowEndRow || tj+offsetsCols(offset)<targetImageWindowStartCol || tj+offsetsCols(offset)>targetImageWindowEndCol)
%                 differenceImage(ti,tj) = targetImage(ti,tj);      
%             else
%                 differenceImage(ti,tj) = targetImage(ti,tj) - targetImage(ti+offsetsRows(offset),tj+offsetsCols(offset));
%             end  
%         end
%     end    
%     
% end

% Calculate the offset
i=1;

for offsetRow = -windowLimit:windowLimit
    for offsetCol = -windowLimit:windowLimit
        shiftedImage = imtranslate(targetImage, [offsetCol, offsetRow]);
        differenceImage = double(shiftedImage - targetImage);
        differenceImageSet{offsetRow+windowLimit+1,offsetCol+windowLimit+1} = computeIntegralImage(differenceImage.^2);
    end
end

for r = windowStartRow:windowEndRow
    for c = windowStartCol:windowEndCol
    offsetsRows(i) = r-row;
    offsetsCols(i) = c-col;
    integralImage = differenceImageSet{offsetsRows(i)+windowLimit+1, offsetsCols(i)+windowLimit+1};
    distances(i)= evaluateIntegralImage(integralImage, r, c, patchSize);
    i=i+1;
    end    
end
end