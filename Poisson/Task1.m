% Task 1: Grayscale Image
clear;
clc;

image = rgb2gray(imread("./images/portrait.jpg"));

% Return binary mask
maskRegion = roipoly(im2double(image));

% Get the boundary
boundary = bwboundaries(maskRegion);


%
% maskArea = maskRegion .* double(image);

%
% imshow(uint8(maskArea));