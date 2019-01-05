%% Task 3B
clear;
clc;
sourceImage = imread("./images/graffiti.jpg");
targetImage = imread("./images/wood.jpg");
MixingGradients(sourceImage, targetImage, true);