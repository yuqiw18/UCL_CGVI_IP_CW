%% Task 4: Image Editing
clear;
clc;

% Free Painting
% sourceImageFP1 = imread("./images/falcon.jpg");
% sourceImageFP2 = imread("./images/jet.jpg");
% sourceImageFP3 = imread("./images/blimp.jpg");
% targetImageFP = imread("./images/sky.jpg");
% newTargetImageFP = MixingGradients(sourceImageFP1, targetImageFP, true);
% newTargetImageFP = MixingGradients(sourceImageFP2, newTargetImageFP, true);
% newTargetImageFP = MixingGradients(sourceImageFP3, newTargetImageFP, true);

% Face swapping
sourceImageFS = imread("./images/face1.jpg");
targetImageFS = imread("./images/face2.jpg");
ImportingGradients(sourceImageFS, targetImageFS, true);