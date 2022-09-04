function [pseudovector, index] = pseudorandptb(vector)
    %
    % uses the PTB function Shuffle to pseudorandomize the input vector
    %
    % USAFGE::
    %
    %  [pseudovector,index] = pseudorandptb(vector)
    %
    % Constraints:
    %
    % - in a vector with repeated values,
    %   it randomizes the values until the resulting vector has no equal consecutive values.
    %
    % - it also gives the index of the (pseudo)randomization as output,
    %   the same way that Shuffle does.
    %
    % (C) Copyright 2020 Federica Falagiarda
    % (C) Copyright 2022 Remi Gau

    % vector that will get a value of one if a value in the shuffled vector is equal to its following value
    repetitionindexvector = zeros(length(vector) - 1, 1);

    while 1

        % randomize vector
        [pseudovector, index] = Shuffle(vector);

        for v = 1:(length(pseudovector) - 1)
            truefalseindex = strcmp(pseudovector(v), pseudovector(v + 1));
            repetitionindexvector(v) = truefalseindex;
        end

        % if all values in this vector are zeros,
        % no value is repeated adjacently
        % hence meeting our criterion for a successful pseudorandomization
        if sum(repetitionindexvector) == 0
            break
        end

    end

end
