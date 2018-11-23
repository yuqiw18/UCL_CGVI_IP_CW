function [integralImage] = computeIntegralImage(image)
% As described in lecture slide p56 - use cumulative sum
% Shift the top and left by 1
[imageRow,imageCol,~] = size(image);   
shiftTop = zeros(1, imageCol+1);
shiftLeft = zeros(imageRow,1);
image = cat(2, shiftLeft, image);
image = cat(1, shiftTop, image);
[imageRow,imageCol,~] = size(image);   
integralImage = zeros(imageRow,imageCol);

% Calculate the integral image using recureence relation
for r = 1 : imageRow
    cumSum = cumsum(image(r, :));
    if r == 1
       integralImage(r, :) = cumSum;
    else
        for c = 1 : imageCol
           integralImage(r, c) = integralImage(r-1, c) + cumSum(c) ;
        end
    end
end
end