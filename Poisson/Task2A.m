%% Task 2A
clear;
clc;
sourceImage = imread("./images/cows.jpg");
targetImage = imread("./images/cows.jpg");
ImportingGradients(sourceImage, targetImage, false);