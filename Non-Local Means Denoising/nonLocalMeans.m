function [denoisingResult] = nonLocalMeans(targetImage, sigma, h, patchSize, windowSize)

%% Non-Local Mean Denoising
% Preallocate
targetImage = im2double(rgb2gray(targetImage));
offsetsRows = zeros(windowSize^2,1);
offsetsCols = zeros(windowSize^2,1);
distances = zeros(windowSize^2,1);
differenceImageIntegralSet{windowSize^2} = 0;
result = zeros(size(targetImage));

% Get row and col from original image 
[imageRow, imageCol] = size(targetImage);

windowLimit = (windowSize-1)/2;

% Calculate offsets for row and col
i = 1;
for r = -windowLimit :windowLimit
    for c = -windowLimit : windowLimit
        offsetsRows(i) = r;
        offsetsCols(i) = c;
        i= i+1;  
    end
end

% Calculate 
for offset = 1: i -1
    differeceImage = zeros(size(targetImage));
    for r = 1:imageRow
        for c = 1:imageCol
            if (r+offsetsRows(offset)<1 || r+offsetsRows(offset)>imageRow|| c+offsetsCols(offset)<1 || c+offsetsCols(offset)>imageCol)
                differeceImage(r,c) = targetImage(r,c);
            else
                differeceImage(r,c) = targetImage(r,c) - targetImage(r+offsetsRows(offset),c+offsetsCols(offset));
            end
        end
    end
    differenceImageIntegralSet{offset} = computeIntegralImage(differeceImage.^2);           
end

% Denoising
for r = 1:imageRow
    for c = 1:imageCol
        sumOfweightedPixel =0 ;
        sumOfWeight = 0;
        for offset = 1:i-1          
            distances(offset) = evaluateIntegralImage(differenceImageIntegralSet{offset}, r, c, patchSize);   
            weight = computeWeighting(distances(offset),h,sigma);    
            sumOfWeight = sumOfWeight + weight;          
            if r+offsetsRows(offset)<1 || r+offsetsRows(offset)>imageCol || c+offsetsCols(offset)<1 || c+offsetsCols(offset)>imageRow
                sumOfweightedPixel =sumOfweightedPixel+ 0;
            else
                sumOfweightedPixel = sumOfweightedPixel + targetImage(r+offsetsRows(offset),c+offsetsCols(offset)) * weight;
            end  
        end       
        denoisedPixel = sumOfweightedPixel / sumOfWeight ;
        result(r,c) = denoisedPixel;      
    end
end
end