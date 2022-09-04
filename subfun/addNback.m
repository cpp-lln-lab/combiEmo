function expTrialsBack = addNback(cfg, expTrials, backTrials, r)
    %
    % add 1-back trials for current block type
    %
    % USAGE::
    %
    %  expTrialsBack = addNback(cfg, expTrials, backTrials, r)
    %
    %
    % (C) Copyright 2020 Federica Falagiarda
    % (C) Copyright 2022 Remi Gau

    IS_TARGET = 1;

    expTrialsBack = expTrials;

    for iTrial = 1:(length(cfg.stimSyll) + r)

        if iTrial <= backTrials(1)
            expTrialsBack(iTrial) = expTrials(iTrial);

            % repetition of the previous syllable - different actor
        elseif iTrial == backTrials(1) + 1

            expTrialsBack(iTrial) = pickAnotherStim(expTrials, backTrials, iTrial, 1);
            expTrialsBack(iTrial).trialtype = IS_TARGET;

            % repetition of the previous syllable - different actor
        elseif iTrial == backTrials(2) + 2

            expTrialsBack(iTrial) = pickAnotherStim(expTrials, backTrials, iTrial, 2);
            expTrialsBack(iTrial).trialtype = IS_TARGET;

        elseif iTrial > backTrials(1) + 1 && iTrial < backTrials(2) + 2
            expTrialsBack(iTrial) = expTrials(iTrial - 1);

        end

        %%
        if r == 2

            if iTrial > backTrials(2) + 2
                expTrialsBack(iTrial) = expTrials(iTrial - 2);

            end

        elseif r == 3

            % repetition of the previous syllable - different actor
            if iTrial == backTrials(3) + 3

                expTrialsBack(iTrial) = pickAnotherStim(expTrials, backTrials, iTrial, 3);
                expTrialsBack(iTrial).trialtype = IS_TARGET;

            elseif iTrial > backTrials(2) + 2 && iTrial < backTrials(3) + 3
                expTrialsBack(iTrial) = expTrials(iTrial - 2);

            elseif iTrial > backTrials(3) + 3
                expTrialsBack(iTrial) = expTrials(iTrial - 3);

            end

        end

    end

end

function value = pickAnotherStim(expTrials, backTrials, iTrial, nBackValue)

    % find where the same-syllable-different-actor rows are
    syllVector = {expTrials.syllable};
    syllRepeated = {expTrials(backTrials(nBackValue)).syllable};
    syllTF = ismember(syllVector, syllRepeated);
    syllIndices = find(syllTF);

    % get rid of current actor
    syllIndices(syllIndices == iTrial - nBackValue) = [];

    % and choose randomly among the others

    value = expTrials(randsample(syllIndices, 1));

end
