function [pseudovector, index] = pseudorandptb(vector)

    % [pseudovector,index] = pseudorandptb(vector)
    % This function uses the PTB function Shuffle to pseudorandomize the input vector in the following way:
    % in a vector with repeated values, it randomizes the values until the resulting vector has no equal consecutive values.
    % It also gives the index of the (pseudo)randomization as output, the same way that Shuffle does.

    % vector that will get a value of one if a value in the shuffled vector is euqal to its following value %
    repetitionindexvector = zeros(length(vector) - 1, 1);

    while 1

        % randomize vector
        [pseudovector, index] = Shuffle(vector);

        for v = 1:(length(pseudovector) - 1)

            if sum(pseudovector(v) + pseudovector(v + 1)) == 2 * pseudovector(v)
                truefalseindex = 1; % 1 if a number is equal to its following number in the shuffled vector
            else
                truefalseindex = 0; % 0 otherwise
            end

            repetitionindexvector(v) = truefalseindex;

        end

        % if all values in this vector are zeros, no value is repeated adjecently
        % hence meeting our criterion for a successful pseudorandomization
        if sum(repetitionindexvector) == 0
            break
        end

    end

end
