%% Task 2 & Task 3
clear;
clc;

% Load images
sourceImage = double(imread("./images/portrait.jpg"));
targetImage = double(imread("./images/portrait.jpg"));

% Task 2 - Grayscale Image with Importing Gradients and Mixing Gradients
SeamlessCloning(sourceImage, targetImage, false);

% Task 3 - Colored Image
% SeamlessCloning(sourceImage, targetImage, true);