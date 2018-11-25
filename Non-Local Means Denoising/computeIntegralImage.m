function [integralImage] = computeIntegralImage(image)
%% Compute Integral Image
 % According to the concept
 % Still relatively efficient
 
 [imageRow,imageCol,~] = size(image);   
 
 % Preallocate
 integralImage = zeros(imageRow,imageCol); 
 
 % Calculate the integral image
 for r = 1 : imageRow
     for c = 1 : imageCol
         if (r==1 && c ==1) 
             % Handle starting point
             % *0000
             % 00000
             % 00000
             integralImage(r,c) = image(r,c);
         elseif (r ==1) 
             % Handle left column: Only Left values
             % ###I*
             % 00000
             % 00000
             integralImage(r,c) = integralImage(r,c-1) + image(r,c);
         elseif (c ==1) 
             % Handle top row: Only Top value 
             % #####
             % I####
             % *0000
             integralImage(r,c) = integralImage(r-1,c) + image(r,c);
         else
             % Handle any other condition: Left position value + Top position value - Top Left position value(Redundant) + Current position value
             % RRR##
             % RRRI#
             % ##I*0
             integralImage(r,c) = integralImage(r,c-1) + integralImage(r-1,c) - integralImage(r-1,c-1) + image(r,c);
         end
     end
 end

%% Optimisation: Cumulative Sum Method
% % As suggested in lecture slide p56 - use cumulative sum
% % The efficiency is almost same as the method I coded above though
% [imageRow,imageCol,~] = size(image);   
% integralImage = zeros(imageRow,imageCol);
% 
% % Calculate the integral image using recurrence relation
% for r = 1 : imageRow
%     cumSum = cumsum(image(r, :));
%     if r == 1
%        integralImage(r, :) = cumSum;
%     else
%         for c = 1 : imageCol
%            integralImage(r, c) = integralImage(r-1, c) + cumSum(c) ;
%         end
%     end
% end
end