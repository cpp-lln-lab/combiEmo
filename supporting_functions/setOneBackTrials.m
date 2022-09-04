function [pseudorandBack] = setOneBackTrials(pseudorand, a, backTrials)

    pseudorandBack = pseudorand;

    for b = 1:(length(pseudorand.stimName) + a)
        % a is the number of back trials
        if a == 1
            if b <= backTrials
                pseudorandBack(b) = pseudorand(b);

            elseif b == backTrials + 1
                pseudorandBack(b) = pseudorand(backTrials);

            elseif b > backTrials + 1
                pseudorandBack(b) = pseudorand(b - 1);

            end

        elseif a == 2
            if b <= backTrials(1)
                pseudorandBack(b) = pseudorand(b);

            elseif b == backTrials(1) + 1
                pseudorandBack(b) = pseudorand(backTrials(1));

            elseif b == backTrials(2) + 2
                pseudorandBack(b) = pseudorand(backTrials(2));

            elseif b > backTrials(1) + 1 && b < backTrials(2) + 2
                pseudorandBack(b) = pseudorand(b - 1);

            elseif b > backTrials(2) + 2
                pseudorandBack(b) = pseudorand(b - 2);

            end
        end

    end

end
