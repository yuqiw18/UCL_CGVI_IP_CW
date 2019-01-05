%% Task 5: Selection Editing
clear;
clc;
sourceImage = imread("./images/tom.jpg");
SelectionEditing(sourceImage, true, "TF");

%sourceImage = imread("./images/orange.jpg");
%SelectionEditing(sourceImage, true, "LIC");