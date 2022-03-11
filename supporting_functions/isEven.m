function [output] = isEven(n)
    % This function finds whether the input number is even or odd %
    % The output is 1 for even and 0 for odd %
    if rem(n, 2) == 0.
        output = 1;
    else
        output = 0;
    end
