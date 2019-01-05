%% Task 4: Image Editing
clear;
clc;
sourceImage1 = imread("./images/falcon.jpg");
sourceImage2 = imread("./images/jet.jpg");
sourceImage3 = imread("./images/blimp.jpg");
targetImage = imread("./images/sky.jpg");
newTargetImage = MixingGradients(sourceImage1, targetImage, true);
newTargetImage = MixingGradients(sourceImage2, newTargetImage, true);
newTargetImage = MixingGradients(sourceImage3, newTargetImage, true);