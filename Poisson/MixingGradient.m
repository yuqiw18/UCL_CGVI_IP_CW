function MixingGradient(targetImage,sourceImage,SourceMask,row_start,col_start, rgbMode)

if(rgbMode == false)
    sourceImage = sourceImage(:,:,1);
    targetImage = targetImage(:,:,1);
end

maskRegion = roipoly(im2double(sourceImage));


%TargetImg   = double(rgb2gray(imread('images/beach.png')))/255;
%SourceImg   = double(rgb2gray(imread('images/pig.jpg')))/255;
%SourceMask  = im2bw(imread('images/sourceMask.jpg'));
TargetMask  = getTargetMask(targetImage,SourceMask,row_start,col_start);


%remove the selected region
img = targetImage;
one_index = find(TargetMask == 1);
img(one_index) = 0;

%calculate the divergence using laplace caculator
templt = [0 -1 0; -1 4 -1; 0 -1 0];
Source_Laplace = imfilter((sourceImage), templt, 'replicate');


[row,col,channel] = size(sourceImage);
bMixingGradients = zeros(row,col,channel);
for c = 1:channel
    for i = 2:row-1
        for j = 2:col-1
            sum = 0;
            ii = i + row_start;
            jj = j + col_start;
            if(abs(targetImage(ii,jj,c)-targetImage(ii-1,jj,c)) > abs(sourceImage(i,j,c)-sourceImage(i-1,j,c)))
                sum = sum + targetImage(ii,jj,c)-targetImage(ii-1,jj,c);
            else
                sum = sum + sourceImage(i,j,c)-sourceImage(i-1,j,c);
            end
        
            if(abs(targetImage(ii,jj,c)-targetImage(ii,jj+1,c)) > abs(sourceImage(i,j,c)-sourceImage(i,j+1,c)))
                sum = sum + targetImage(ii,jj,c)-targetImage(ii,jj+1,c);
            else
                sum = sum + sourceImage(i,j,c)-sourceImage(i,j+1,c);
            end
        
            if(abs(targetImage(ii,jj,c)-targetImage(ii+1,jj,c)) > abs(sourceImage(i,j,c)-sourceImage(i+1,j,c)))
                sum = sum + targetImage(ii,jj,c)-targetImage(ii+1,jj,c);
            else
                sum = sum + sourceImage(i,j,c)-sourceImage(i+1,j,c);
            end
        
            if(abs(targetImage(ii,jj,c)-targetImage(ii,jj-1,c)) > abs(sourceImage(i,j,c)-sourceImage(i,j-1,c)))
                sum = sum + targetImage(ii,jj,c)-targetImage(ii,jj-1,c);
            else
                sum = sum + sourceImage(i,j,c)-sourceImage(i,j-1,c);
            end
            bMixingGradients(i,j,c) = sum;
        end
    end
end



%generate the boundary of the roi(8-neighbor)
%TargetBoundary = boundary_8(TargetMask);

%generate the boundary of the roi(4-neighbor)
TargetBoundary = boundary_4(TargetMask);
%figure();
%imshow(TargetBoundary);

%number the roi
[roi_row,roi_col] = find(TargetMask == 1);
[source_row,source_col] = find(SourceMask == 1);
roi_index_max = length(roi_row);

%Remove roi from target image
TargetImg_removed = targetImage;
for i = 1:roi_index_max
    TargetImg_removed(roi_row(i),roi_col(i)) = 0;
end


%Generate A matrix
A = sparse(roi_index_max,roi_index_max,0);
%Generate B matrix
b1 = zeros(roi_index_max,1);

for i = 1:roi_index_max
    for j = 1:roi_index_max  %Deal with edge later!
        % Fill in the A matrix
        if(i == j)
            A(i,j) = 4;%length(find(connected_4 == 1));
        else
            % if p_j in N_pi
            if(roi_row(j) == roi_row(i)-1 & roi_col(j) == roi_col(i))
                % if pj is up of pi
                A(i,j) = -1;
            end
            if(roi_row(j) == roi_row(i) & roi_col(j) == roi_col(i)+1)
                % if pj is right of pi
                A(i,j) = -1;
            end
            if(roi_row(j) == roi_row(i)+1 & roi_col(j) == roi_col(i))
                % if pj is down of pi
                A(i,j) = -1;
            end
            if(roi_row(j) == roi_row(i) & roi_col(j) == roi_col(i)-1)
                % if pj is left of pi
                A(i,j) = -1;
            end
        end
    end
    %Now fill in the B matrix
end

for i = 1:roi_index_max
    sum1 = 0;

    if(TargetBoundary(roi_row(i)-1,roi_col(i)) == 1)
        % if up of pi is in boundary
        sum1 = sum1 + targetImage(roi_row(i)-1,roi_col(i),1);

    end
    if(TargetBoundary(roi_row(i),roi_col(i)+1) == 1)
        % if right of pi is in boundary
        sum1 = sum1 + targetImage(roi_row(i),roi_col(i)+1,1);

    end
    if(TargetBoundary(roi_row(i)+1,roi_col(i)) == 1)
        % if down of pi is in boundary
        sum1 = sum1 + targetImage(roi_row(i)+1,roi_col(i),1);

    end
    if(TargetBoundary(roi_row(i),roi_col(i)-1) == 1)
        % if left of pi is in boundary
        sum1 = sum1 + targetImage(roi_row(i),roi_col(i)-1,1);

    end

    sum1 = sum1 + bMixingGradients(source_row(i),source_col(i),1);

    b1(i) = sum1;

end

%A = sparse(A);
x1 = A\b1;

%Fill the image with the x
TargetImg_filled = TargetImg_removed;
for i = 1:roi_index_max
    TargetImg_filled(roi_row(i),roi_col(i),1) = x1(i);
end

end