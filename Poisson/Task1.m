%% Task 1: Grayscale Image
clear;
clc;

% Load the image
sourceImage = rgb2gray(imread("./images/portrait.jpg"));
targetImage = zeros(size(sourceImage));

% Return the binary mask
maskRegion = roipoly(im2double(sourceImage));
targetMaskRegion = zeros(size(maskRegion));
regionPixelCount = find(maskRegion);

% Get the boundary coordinate
boundary = bwboundaries(maskRegion);
boundaryCoord = cell2mat(boundary);

%
% 
% for n =1:size(smallMask_row);
%     result(smallMask_row(n),smallMask_col(n)) = f(n);
% end
% 
% 
% 
% figure;
% imshow(targetImage);


%% Test
%
% figure;
% imshow(maskRegion);
% title("Mask Region");
%
% figure;
% maskArea = maskRegion .* double(sourceImage);
% imshow(uint8(maskArea));
% title("Selected Region");