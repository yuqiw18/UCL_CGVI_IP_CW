%% Some parameters to set - make sure that your code works at image borders!
patchSize = 3;
sigma = 12; % standard deviation (different for each image!)
h = 0.55; %decay parameter
windowSize = 5;

if (mod(patchSize,2) ~= 1)
    patchSize = patchSize + 1;
end

if (mod(windowSize,2) ~= 1)
    windowSize = windowSize + 1;
end

%TODO - Read an image (note that we provide you with smaller ones for
%debug in the subfolder 'debug' int the 'image' folder);
%Also unless you are feeling adventurous, stick with non-colour
%images for now.
%NOTE: for each image, please also read its CORRESPONDING 'clean' or
%reference image. We will need this later to do some analysis
%NOTE2: the noise level is different for each image (it is 20, 10, and 5 as
%indicated in the image file names)

%REPLACE THIS
imageNoisy = imread('images/alleyNoisy_sigma20.png');
imageReference = imread('images/alleyReference.png');

% disp('Efficiency - Integral');
% tic;
% %TODO - Implement the non-local means function
% filteredWithIntegral = nonLocalMeansIntegralImage(imageNoisy, sigma, h, patchSize, windowSize);
% toc

disp('Efficiency - Naive');
tic;
%TODO - Implement the non-local means function
filteredWithNaive = nonLocalMeansNaive(imageNoisy, sigma, h, patchSize, windowSize);
toc

%% Let's show your results!

imageNoisy = double(rgb2gray(imageNoisy));
imageReference = double(rgb2gray(imageReference));

%Show the denoised image
% figure('name', 'NL-Means Denoised Image - Integral');
% imshow(uint8(filteredWithIntegral));

%Show the denoised image
figure('name', 'NL-Means Denoised Image - Naive');
imshow(uint8(filteredWithNaive));

%Show difference image
% diff_image = abs(imageNoisy - filteredWithIntegral);
% figure('name', 'Difference Image - Integral');
% imshow(diff_image / max(max((diff_image))));

%Show difference image
diff_image = abs(imageNoisy - filteredWithNaive);
figure('name', 'Difference Image - Naive');
imshow(diff_image / max(max((diff_image))));

%Print some statistics ((Peak) Signal-To-Noise Ratio)
disp('For Noisy Input');
[peakSNR, SNR] = psnr(uint8(imageNoisy), uint8(imageReference));
disp(['SNR: ', num2str(SNR, 10), '; PSNR: ', num2str(peakSNR, 10)]);

% disp('For Denoised Result - Integral');
% [peakSNR, SNR] = psnr(uint8(filteredWithIntegral), uint8(imageReference));
% disp(['SNR: ', num2str(SNR, 10), '; PSNR: ', num2str(peakSNR, 10)]);

disp('For Denoised Result - Naive');
[peakSNR, SNR] = psnr(uint8(filteredWithNaive), uint8(imageReference));
disp(['SNR: ', num2str(SNR, 10), '; PSNR: ', num2str(peakSNR, 10)]);

%Feel free (if you like only :)) to use some other metrics (Root
%Mean-Square Error (RMSE), Structural Similarity Index (SSI) etc.)