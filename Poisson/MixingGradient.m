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


[rrr,ccc,d] = size(sourceImage);
mix_grad = zeros(rrr,ccc,3);
for dim = 1:3
    
    for i = 2:rrr-1
        for j = 2:ccc-1
            sum = 0;
            ii = i + row_start;
            jj = j + col_start;
            if(abs(targetImage(ii,jj,dim)-targetImage(ii-1,jj,dim)) > abs(sourceImage(i,j,dim)-sourceImage(i-1,j,dim)))
                sum = sum + targetImage(ii,jj,dim)-targetImage(ii-1,jj,dim);
            else
                sum = sum + sourceImage(i,j,dim)-sourceImage(i-1,j,dim);
            end
        
            if(abs(targetImage(ii,jj,dim)-targetImage(ii,jj+1,dim)) > abs(sourceImage(i,j,dim)-sourceImage(i,j+1,dim)))
                sum = sum + targetImage(ii,jj,dim)-targetImage(ii,jj+1,dim);
            else
                sum = sum + sourceImage(i,j,dim)-sourceImage(i,j+1,dim);
            end
        
            if(abs(targetImage(ii,jj,dim)-targetImage(ii+1,jj,dim)) > abs(sourceImage(i,j,dim)-sourceImage(i+1,j,dim)))
                sum = sum + targetImage(ii,jj,dim)-targetImage(ii+1,jj,dim);
            else
                sum = sum + sourceImage(i,j,dim)-sourceImage(i+1,j,dim);
            end
        
            if(abs(targetImage(ii,jj,dim)-targetImage(ii,jj-1,dim)) > abs(sourceImage(i,j,dim)-sourceImage(i,j-1,dim)))
                sum = sum + targetImage(ii,jj,dim)-targetImage(ii,jj-1,dim);
            else
                sum = sum + sourceImage(i,j,dim)-sourceImage(i,j-1,dim);
            end
            mix_grad(i,j,dim) = sum;
        %lapla(i,j) = 4 * SourceImg(i,j)-SourceImg(i-1,j)-SourceImg(i,j+1)-SourceImg(i+1,j)-SourceImg(i,j-1);
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
b2 = zeros(roi_index_max,1);
b3 = zeros(roi_index_max,1);
for i = 1:roi_index_max
    for j = 1:roi_index_max  %Deal with edge later!
        % Fill in the A matrix
        if(i == j)
            %connected_4 = [TargetMask(roi_row(i)-1,roi_col(i));% up
            %               TargetMask(roi_row(i),roi_col(i)+1);% right
            %               TargetMask(roi_row(i)+1,roi_col(i));% down
            %               TargetMask(roi_row(i),roi_col(i)-1);% left
            %               ];
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
    sum2 = 0;
    sum3 = 0;
    if(TargetBoundary(roi_row(i)-1,roi_col(i)) == 1)
        % if up of pi is in boundary
        sum1 = sum1 + targetImage(roi_row(i)-1,roi_col(i),1);
        sum2 = sum2 + targetImage(roi_row(i)-1,roi_col(i),2);
        sum3 = sum3 + targetImage(roi_row(i)-1,roi_col(i),3);
    end
    if(TargetBoundary(roi_row(i),roi_col(i)+1) == 1)
        % if right of pi is in boundary
        sum1 = sum1 + targetImage(roi_row(i),roi_col(i)+1,1);
        sum2 = sum2 + targetImage(roi_row(i),roi_col(i)+1,2);
        sum3 = sum3 + targetImage(roi_row(i),roi_col(i)+1,3);
    end
    if(TargetBoundary(roi_row(i)+1,roi_col(i)) == 1)
        % if down of pi is in boundary
        sum1 = sum1 + targetImage(roi_row(i)+1,roi_col(i),1);
        sum2 = sum2 + targetImage(roi_row(i)+1,roi_col(i),2);
        sum3 = sum3 + targetImage(roi_row(i)+1,roi_col(i),3);
    end
    if(TargetBoundary(roi_row(i),roi_col(i)-1) == 1)
        % if left of pi is in boundary
        sum1 = sum1 + targetImage(roi_row(i),roi_col(i)-1,1);
        sum2 = sum2 + targetImage(roi_row(i),roi_col(i)-1,2);
        sum3 = sum3 + targetImage(roi_row(i),roi_col(i)-1,3);
    end
    %sum = sum + Source_Laplace(source_row(i)-1,source_col(i)) + Source_Laplace(source_row(i),source_col(i)+1) + Source_Laplace(source_row(i)+1,source_col(i)) + Source_Laplace(source_row(i),source_col(i)-1);
    %sum = sum + 4*aaa(source_row(i),source_col(i)) - aaa(source_row(i)-1,source_col(i)) - aaa(source_row(i),source_col(i)+1) - aaa(source_row(i)+1,source_col(i)) - aaa(source_row(i),source_col(i)-1);
    %sum = sum + V_pq(source_row(i),source_col(i));
    sum1 = sum1 + mix_grad(source_row(i),source_col(i),1);
    sum2 = sum2 + mix_grad(source_row(i),source_col(i),2);
    sum3 = sum3 + mix_grad(source_row(i),source_col(i),3);
    b1(i) = sum1;
    b2(i) = sum2;
    b3(i) = sum3; 
end

%A = sparse(A);
x1 = A\b1;
x2 = A\b2;
x3 = A\b3;

%Fill the image with the x
TargetImg_filled = TargetImg_removed;
for i = 1:roi_index_max
    TargetImg_filled(roi_row(i),roi_col(i),1) = x1(i);
    TargetImg_filled(roi_row(i),roi_col(i),2) = x2(i);
    TargetImg_filled(roi_row(i),roi_col(i),3) = x3(i);
end

end