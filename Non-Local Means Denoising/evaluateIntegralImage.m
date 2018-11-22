function [patchSum] = evaluateIntegralImage(integralImage, row, col, patchSize)
% This function should calculate the sum over the patch centred at row, col
% of size patchSize of the integral image ii

%% Integral Image
[imageRow, imageCol] = size(integralImage);
patchLimit = (patchSize-1)/2;

%% Obsolete
% Works but is not efficient
% % L1 Calculation
% % Use position at <Top Left> corner and shift 1 unit towards the <Top Left>
% % Boundary check
% if (row-patchLimit-1<1 || col-patchLimit-1<1) % <Top Left> boundary check: both need at least 1 unit
%     L1 = 0;
% else
%     L1 = integralImage(row-patchLimit-1, col-patchLimit-1);
% end
% 
% % L2 Calculation
% % Use position at <Top Right> corner and shift 1 unit towards the <Top>
% if (row-patchLimit-1<1) % <Top> boundary check: need at least 1 unit
%     L2 = 0;
% elseif (col+patchLimit>imageCol) % <Right> boundary check: if overflow
%     L2 = integralImage(row-patchLimit-1, imageCol);
% else
%     L2 = integralImage(row-patchLimit-1, col+patchLimit);
% end
% 
% % L3 Calculation
% % Use position at <Bottom Right> corner
% if (row+patchLimit>imageRow && col+patchLimit>imageCol) % <Bottom Right> boundary check: if both overflow
%     L3 = integralImage(imageRow, imageCol);
% elseif (row+patchLimit>imageRow) % <Bottom> boundary check: if overflow
%     L3 = integralImage(imageRow, col+patchLimit);
% elseif (col+patchLimit>imageCol) % <Right> boundary check: if overflow
%     L3 = integralImage(row+patchLimit, imageCol);
% else
%     L3 = integralImage(row+patchLimit, col+patchLimit);
% end
% 
% % L4 Calculation
% % Use position at <Bottom Left> corner and shift 1 unit towards the <Left>
% if (col-patchLimit-1 < 1) % <Left> boundary check: need at least 1 unit
%     L4 = 0;
% elseif (row+patchLimit>imageRow) % <Bottom> boundary check: if overflow
%     L4 = integralImage(imageRow, col-patchLimit-1);
% else
%     L4 = integralImage(row+patchLimit, col-patchLimit-1);
% end
% Calculate the patch sum
%patchSum = L3 - L2 - L4 + L1;

%% Simplified
% rowLeftLimit = max(row-patchLimit-1, 1);
% rowRightLimit = min(row+patchLimit, imageRow);
% colTopLimit = max(col-patchLimit-1, 1);
% colBottomLimit = min(col+patchLimit, imageCol);

shiftVal = 1;

rowLeftLimit = max(row-patchLimit-1+shiftVal, 1);
rowRightLimit = min(row+patchLimit+shiftVal, imageRow);
colTopLimit = max(col-patchLimit-1+shiftVal, 1);
colBottomLimit = min(col+patchLimit+shiftVal, imageCol);

L1 = integralImage(rowLeftLimit, colTopLimit);
L2 = integralImage(rowLeftLimit, colBottomLimit);
L3 = integralImage(rowRightLimit, colBottomLimit);
L4 = integralImage(rowRightLimit, colTopLimit);

patchSum = L3 - L2 - L4 + L1;
end