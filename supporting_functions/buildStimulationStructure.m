function buildStimulationStructure(whichScript)

    % This function buils the structure containing the stimuli
    % exclusively for the experiment combiemo.
    % This structure would normally have been already saved,
    % but this can be re-done running this function.
    % Run one of the following lines:
    % buildStimulationStructure('face_localizer_combiemo')
    % buildStimulationStructure('voice_localizer_combiemo')
    % buildStimulationStructure('eventrelated_combiemo')

    % Open a PTB window, cos it's needed for some future operations
    AssertOpenGL;
    Screen('Preference', 'SkipSyncTests', 2);
    [mainWindow, ~] = Screen('OpenWindow', max(Screen('Screens')), 0, [], 32, 2);

    if whichScript == 'eventrelated_combiemo'

        % visual stimuli
        frameNum = (1:30);
        actor = {'27', '30', '32', '33'};
        emotion = {'ne', 'di', 'fe', 'ha', 'sa'};

        allFrameNamesFaces = cell(30, 20);
        c = 1;
        for a = 1:length(actor)
            for e = 1:length(emotion)
                for f = 1:length(frameNum)
                    allFrameNamesFaces{f, c} = {['V' actor{a} emotion{e} '_' num2str(frameNum(f))]};
                end
                c = c + 1;
            end
        end

        % build one structure per "video"
        nFrames = 30;
        frameDuration = 1 / 29.97; % where to find the images
        framePath = fullfile('visual_stim', 'face_frames');

        Ne27Struct = struct;
        Ne27Struct = buildFramesStruct(mainWindow, Ne27Struct, nFrames, frameDuration, allFrameNamesFaces(:, 1), framePath);
        Di27Struct = struct;
        Di27Struct = buildFramesStruct(mainWindow, Di27Struct, nFrames, frameDuration, allFrameNamesFaces(:, 2), framePath);
        Fe27Struct = struct;
        Fe27Struct = buildFramesStruct(mainWindow, Fe27Struct, nFrames, frameDuration, allFrameNamesFaces(:, 3), framePath);
        Ha27Struct = struct;
        Ha27Struct = buildFramesStruct(mainWindow, Ha27Struct, nFrames, frameDuration, allFrameNamesFaces(:, 4), framePath);
        Sa27Struct = struct;
        Sa27Struct = buildFramesStruct(mainWindow, Sa27Struct, nFrames, frameDuration, allFrameNamesFaces(:, 5), framePath);

        Ne30Struct = struct;
        Ne30Struct = buildFramesStruct(mainWindow, Ne30Struct, nFrames, frameDuration, allFrameNamesFaces(:, 6), framePath);
        Di30Struct = struct;
        Di30Struct = buildFramesStruct(mainWindow, Di30Struct, nFrames, frameDuration, allFrameNamesFaces(:, 7), framePath);
        Fe30Struct = struct;
        Fe30Struct = buildFramesStruct(mainWindow, Fe30Struct, nFrames, frameDuration, allFrameNamesFaces(:, 8), framePath);
        Ha30Struct = struct;
        Ha30Struct = buildFramesStruct(mainWindow, Ha30Struct, nFrames, frameDuration, allFrameNamesFaces(:, 9), framePath);
        Sa30Struct = struct;
        Sa30Struct = buildFramesStruct(mainWindow, Sa30Struct, nFrames, frameDuration, allFrameNamesFaces(:, 10), framePath);

        Ne32Struct = struct;
        Ne32Struct = buildFramesStruct(mainWindow, Ne32Struct, nFrames, frameDuration, allFrameNamesFaces(:, 11), framePath);
        Di32Struct = struct;
        Di32Struct = buildFramesStruct(mainWindow, Di32Struct, nFrames, frameDuration, allFrameNamesFaces(:, 12), framePath);
        Fe32Struct = struct;
        Fe32Struct = buildFramesStruct(mainWindow, Fe32Struct, nFrames, frameDuration, allFrameNamesFaces(:, 13), framePath);
        Ha32Struct = struct;
        Ha32Struct = buildFramesStruct(mainWindow, Ha32Struct, nFrames, frameDuration, allFrameNamesFaces(:, 14), framePath);
        Sa32Struct = struct;
        Sa32Struct = buildFramesStruct(mainWindow, Sa32Struct, nFrames, frameDuration, allFrameNamesFaces(:, 15), framePath);

        Ne33Struct = struct;
        Ne33Struct = buildFramesStruct(mainWindow, Ne33Struct, nFrames, frameDuration, allFrameNamesFaces(:, 16), framePath);
        Di33Struct = struct;
        Di33Struct = buildFramesStruct(mainWindow, Di33Struct, nFrames, frameDuration, allFrameNamesFaces(:, 17), framePath);
        Fe33Struct = struct;
        Fe33Struct = buildFramesStruct(mainWindow, Fe33Struct, nFrames, frameDuration, allFrameNamesFaces(:, 18), framePath);
        Ha33Struct = struct;
        Ha33Struct = buildFramesStruct(mainWindow, Ha33Struct, nFrames, frameDuration, allFrameNamesFaces(:, 19), framePath);
        Sa33Struct = struct;
        Sa33Struct = buildFramesStruct(mainWindow, Sa33Struct, nFrames, frameDuration, allFrameNamesFaces(:, 20), framePath);

        % put them all together
        myFacesStructArray = {Ne27Struct, Di27Struct, Fe27Struct, Ha27Struct, Sa27Struct, Ne30Struct, Di30Struct, Fe30Struct, Ha30Struct, Sa30Struct, Ne32Struct, Di32Struct, Fe32Struct, Ha32Struct, Sa32Struct, Ne33Struct, Di33Struct, Fe33Struct, Ha33Struct, Sa33Struct};

        % AUDITORY STIMULI
        stimName = {'27ne', '27di', '27fe', '27ha', '27sa', '30ne', '30di', '30fe', '30ha', '30sa', '32ne', '32di', '32fe', '32ha', '32sa', '33ne', '33di', '33fe', '33ha', '33sa'};
        stimEmotion = repmat(1:5, 1, 4);
        stimActor = [repmat(27, 1, 5), repmat(30, 1, 5), repmat(32, 1, 5), repmat(33, 1, 5)];

        %% Read everything into a structure
        % preallocate
        myExpTrials = struct;
        % for the experiment
        for t = 1:length(stimName)
            myExpTrials(t).stimulusname = stimName{t};
            myExpTrials(t).visualstimuli = myFacesStructArray{t};
            [myExpTrials(t).audy, myExpTrials(t).audfreq] = audioread([cd '/auditory_stim/A' myExpTrials(t).stimulusname '.wav']);
            myExpTrials(t).wavedata = myExpTrials(t).audy';
            myExpTrials(t).nrchannels = size(myExpTrials(t).wavedata, 1);
            myExpTrials(t).emotion = stimEmotion(t);
            myExpTrials(t).actor = stimActor(t);
        end

        % save resulting structure
        save(['expTrials'], 'myExpTrials');

    end

    % Screen close all
    sca;

end
