function [integralImage] = computeIntegralImage(image)
%% Hard Coded
% This part was done before I fuuly understood the concept
% It works but is not efficient
% % Shift the top and left by 1
% [imageRow,imageCol,~] = size(image);   
% shiftTop = zeros(1, imageCol+1);
% shiftLeft = zeros(imageRow,1);
% image = cat(2, shiftLeft, image);
% image = cat(1, shiftTop, image);
% [imageRow,imageCol,~] = size(image);   
% 
% % Preallocate
% integralImage = zeros(imageRow,imageCol); 
% 
% % Calculate the integral image
% for r = 1 : imageRow;
%     for c = 1 : imageCol
%         if (r==1 && c ==1) % Handle starting point
%             integralImage(r,c) = image(r,c);
%         elseif (r ==1) % Handle left column
%             integralImage(r,c) = integralImage(r,c-1) + image(r,c);
%         elseif (c ==1) % Handle top row
%             integralImage(r,c) = integralImage(r-1,c) + image(r,c);
%         else % Handle any other condition
%             integralImage(r,c) = integralImage(r,c-1) + sum(image(1:r-1,c),'all') + image(r,c);
%         end
%     end
% end

%% More Efficient Way
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