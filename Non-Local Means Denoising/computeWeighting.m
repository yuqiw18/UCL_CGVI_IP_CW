function [result] = computeWeighting(d, h, sigma, patchSize)
    %Implement weighting function from the slides
    %Be careful to normalise/scale correctly!
    %% Weighting Function
    % d - SSD
    % h - decay paramter
    % sigma - noise standard deviation  
    result = exp(-max(d/(patchSize.^2) - 2*(sigma.^2),0)/(h.^2));
    
end