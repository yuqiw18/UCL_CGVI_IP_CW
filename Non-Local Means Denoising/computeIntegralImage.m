function [integralImage] = computeIntegralImage(image)  
    [w,h,~] = size(image);
    
    integralImage = zeros(w,h);
    
    for x = 1:w
        for y = 1:h
            if (x==1 && y ==1) % Handle starting point
                integralImage(x,y) = image(x,y);
            elseif (x ==1) % Handle left column
                integralImage(x,y) = integralImage(x,y-1) + image(x,y);
            elseif (y ==1) % Handle top row
                integralImage(x,y) = integralImage(x-1,y) + image(x,y);
            else % Handle any other condition
                integralImage(x,y) = integralImage(x-1,y) + sum(image(x,1:y-1),'all') + image(x,y) ;
            end
        end
    end        

    % Normalize the integral
    normalizedIntegralImage = integralImage/integralImage(w,h);  
    % Convert back to uint8
    normalizedIntegralImage = uint8(normalizedIntegralImage * 255);
end