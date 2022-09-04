function [cfg, myExpTrials] = postInitializationSetup(cfg, myExpTrials, myVidStructArray)
    %
    % generic function to finalize some set up after psychtoolbox has been initialized
    %
    % USAGE::
    %
    %  [cfg, myExpTrials] = postInitializationSetup(cfg, myExpTrials, myVidStructArray)
    %
    %
    % (C) Copyright 2020 Federica Falagiarda
    % (C) Copyright 2022 Remi Gau

    % timings in my trial sequence
    % (substract interFrameInterval/3 to make sure that flipping is done
    % at 3sec straight and not 1 frame later)
    cfg.timing.ISI = 3 - cfg.screen.ifi / 6;
    cfg.timing.frameDuration = 1 / cfg.videoFrameRate - cfg.screen.ifi / 6;

    talkToMe(cfg, '\nTurning images into textures.\n');
    stimNames = fieldnames(myVidStructArray);
    for iStim = 1:numel(stimNames)
        thisStime = stimNames{iStim};
        for iFrame = 1:numel(myVidStructArray.(thisStime))
            myVidStructArray.(thisStime)(iFrame).duration = cfg.timing.frameDuration;  %#ok<*SAGROW>
            myVidStructArray.(thisStime)(iFrame).imageTexture = Screen('MakeTexture', ...
                                                                       cfg.screen.win, ...
                                                                       myVidStructArray.(thisStime)(iFrame).stimImage);
        end
    end
    % add textures to myExpTrials structure
    for t = 1:length(stimNames)
        myExpTrials(t).visualStimuli = myVidStructArray.(stimNames{t});
    end

end
