%% Task 3A
clear;
clc;
sourceImage = imread("./images/graffiti.jpg");
targetImage = imread("./images/wood.jpg");
ImportingGradients(sourceImage, targetImage, true);