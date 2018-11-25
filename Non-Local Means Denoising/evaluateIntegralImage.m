function [patchSum] = evaluateIntegralImage(integralImage, row, col, patchSize)
% This function should calculate the sum over the patch centred at row, col
% of size patchSize of the integral image ii

%% Integral Image Evaluation
% The boundaries are clipped so we only need to consider the start position
% for row and col

% L1 Calculation
if (row - patchSize<1 || col - patchSize<1)
    L1 = 0;
else
    L1 = integralImage(row - patchSize,col - patchSize);
end
    
% L2 Calculation
if (row - patchSize<1)
    L2 = 0;
else
    L2 = integralImage(row - patchSize,col);
end

% L3 Calculation
L3 = integralImage(row,col);

% L4 Calculation
if (col - patchSize<1)
    L4 = 0;
else
    L4 = integralImage(row,col - patchSize);
end

% Calculate the patch sum   
patchSum = L3 - L2 -L4 + L1;

%% Integral Image Evaluation - Obsolete
% % This was done before correcting/shifting the boundary!
% [imageRow, imageCol] = size(integralImage);
% patchLimit = (patchSize-1)/2;
% 
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
% 
% % Calculate the patch sum
% patchSum = L3 - L2 - L4 + L1;

end