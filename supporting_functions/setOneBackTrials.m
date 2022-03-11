function [pseudorandFacesBack] = setOneBackTrials(pseudorandFaces, a, backTrialsFaces)

    pseudorandFacesBack = pseudorandFaces;

    for b = 1:(length(pseudorandFaces.stimName) + a)
        % a is the number of back trials
        if a == 1
            if b <= backTrialsFaces
                pseudorandFacesBack(b) = pseudorandFaces(b);

            elseif b == backTrialsFaces + 1
                pseudorandFacesBack(b) = pseudorandFaces(backTrialsFaces);

            elseif b > backTrialsFaces + 1
                pseudorandFacesBack(b) = pseudorandFaces(b - 1);

            end

        elseif a == 2
            if b <= backTrialsFaces(1)
                pseudorandFacesBack(b) = pseudorandFaces(b);

            elseif b == backTrialsFaces(1) + 1
                pseudorandFacesBack(b) = pseudorandFaces(backTrialsFaces(1));

            elseif b == backTrialsFaces(2) + 2
                pseudorandFacesBack(b) = pseudorandFaces(backTrialsFaces(2));

            elseif b > backTrialsFaces(1) + 1 && b < backTrialsFaces(2) + 2
                pseudorandFacesBack(b) = pseudorandFaces(b - 1);

            elseif b > backTrialsFaces(2) + 2
                pseudorandFacesBack(b) = pseudorandFaces(b - 2);

            end
        end

    end

end