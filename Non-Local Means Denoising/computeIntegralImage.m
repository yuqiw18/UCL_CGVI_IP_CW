function [integralImage] = computeIntegralImage(image)
    [imageRow,imageCol,~] = size(image);   
    integralImage = zeros(imageRow,imageCol); 
    for r = 1 : imageRow;
        for c = 1 : imageCol
            if (r==1 && c ==1) % Handle starting point
                integralImage(r,c) = image(r,c);
            elseif (r ==1) % Handle left column
                integralImage(r,c) = integralImage(r,c-1) + image(r,c);
            elseif (c ==1) % Handle top row
                integralImage(r,c) = integralImage(r-1,c) + image(r,c);
            else % Handle any other condition
                integralImage(r,c) = integralImage(r,c-1) + sum(image(1:r-1,c),'all') + image(r,c);
            end
        end
    end
end