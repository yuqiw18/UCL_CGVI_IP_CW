%% Task 2B
clear;
clc;
sourceImage = imread("./images/cows.jpg");
targetImage = imread("./images/cows.jpg");
MixingGradients(sourceImage, targetImage, false);