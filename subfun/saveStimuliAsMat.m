function saveStimuliAsMat()
    %
    % loads images of all requested stimuli and saves them as a mat file
    %
    %
    % (C) Copyright 2020 Federica Falagiarda
    % (C) Copyright 2022 Remi Gau

    % TODO make saving optional?

    cfg = setParameters();

    fprintf('Preparing frame structures for each video \n');

    for a = 1:length(cfg.actor)
        for s = 1:length(cfg.syllable)
            myVidStructArray.([cfg.actor{a}, cfg.syllable{s}]) = loadImages(cfg, ...
                                                                            cfg.actor{a}, ...
                                                                            cfg.syllable{s});
        end
    end

    stimuliMatFile = fullfile(cfg.dir.root, 'stimuli', 'stimuli.mat');

    save(stimuliMatFile, 'myVidStructArray', '-v7');

end
