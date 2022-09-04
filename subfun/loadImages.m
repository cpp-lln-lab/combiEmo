function [structureName] = loadImages(cfg, actor, syllable)
    %
    % builds a structure with the images/frames of a video
    %
    % USAGE::
    %
    % [structureName] = loadImages(cfg, actor, syllable)
    %
    %
    % the output of the function is a structure with a number of rows equal to nbFrames and 4 fields:
    %
    % - actor
    % - syllable
    % - stimFilename
    % - stimImage: the image data content
    %
    % (C) Copyright 2020 Federica Falagiarda
    % (C) Copyright 2022 Remi Gau

    structureName =  struct();

    fprintf('\nloading %s', [actor syllable]);

    allImages = bids.internal.file_utils('FPList', cfg.dir.stimuli, ['^' actor syllable '.*.png$']);

    for i = 1:cfg.nbFrames
        thisImage = deblank(allImages(i, :));
        structureName(i).actor = actor;
        structureName(i).syllable = syllable;
        structureName(i).stimFilename = bids.internal.file_utils(thisImage, 'filename');
        structureName(i).stimImage = imread(thisImage);
    end

end
