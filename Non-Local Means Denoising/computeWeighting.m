function [result] = computeWeighting(d, h, sigma, patchSize)
    %Implement weighting function from the slides
    %Be careful to normalise/scale correctly!
    %% Weighting Function
    % d - SSD
    % h - decay paramter
    % sigma - noise standard deviation
    % d value is way too big unless using normalised double image
    % Need to scale the value correctly
    % Tried:
    % d^2 -> does not work, black image
    %
    % (d/patchSize)^2 -> does not work, black image
    %
    % (d/patchSize^2) -> works, denoised image
    
    result = exp(-max(d/(patchSize^2)-2*(sigma^2),0)/h^2);
    
end