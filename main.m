% (C) Copyright 2022 Remi Gau
% Clear all the previous stuff
clear;
clc;
% cleanUp();

more off;

if ~ismac
    close all;
    clear Screen;
end

% make sure we got access to all the required functions and inputs
initEnv();

% set and load all the parameters to run the experiment
cfg = setParameters;

cfg = userInputs(cfg);

%% DESIGN

% num of different blocks (= different acquisition runs) per rep --> one per modality
nBlocks = 2;

nReps = input('NUMBER OF REPETITIONS :');
% if no value is supplied, do 10 reps
if isempty(nReps)
    nReps = 10;
end
if cfg.debug.do
    nReps = 2;
end

%% order of modalities within a subject
% modality orded will be fixed within participant, and balanced across
auditoryCond = 1;
visualCond = 2;

firstCondition = input('START WITH MODALITY ... ? (AUD=1 or VIS=2) :');

if firstCondition == 1
    orderCondVector = [auditoryCond, visualCond];
elseif firstCondition == 2
    orderCondVector = [visualCond, auditoryCond];
else
    orderCondVector = [auditoryCond, visualCond];
end

% ADD TARGET TRIALS
% vector with # of blocks per condition
% (if 5 reps, you have 5 blocks for each condition)
blockPerCond = 1:nReps;

% I want 10% of my trials (t=27) to be targets
% I will have 2 or 3 targets per block (adds 10 or 15 sec (max 15) per block) -->
% duration of the blocks = 150s = 2min30

% VISUAL
% randomly select half of the blocks to have 2 1-back stimuli for the audio
tmp = randperm(nReps);
twoBackBlocksVisual = tmp(1:round(nReps / 2));
% remaining half will have 3 1-back stimulus %
threeBackBlocksVisual = setdiff(blockPerCond, twoBackBlocksVisual);

% AUDIO
% randomly select half of the blocks to have 2 1-back stimuli for the audio
tmp = randperm(nReps);
twoBackBlocksAudio = tmp(1:round(nReps / 2));
% remaining half will have 3 1-back stimulus %
threeBackBlocksAudio = setdiff(blockPerCond, twoBackBlocksAudio);

clear tmp;

%% Load stimuli
talkToMe(cfg, '\nLoad stimuli:');

% to keep track of stimuli
myExpTrials = struct;

talkToMe(cfg, '\n visual');
stimuliMatFile = fullfile(cfg.dir.root, 'stimuli', 'stimuli.mat');
if ~exist(stimuliMatFile, 'file')
    saveStimuliAsMat();
end
load(stimuliMatFile, 'myVidStructArray');
stimNames = fieldnames(myVidStructArray);

talkToMe(cfg, '\n audio');
for t = 1:length(stimNames)
    myExpTrials(t).stimulusName = stimNames{t};
    myExpTrials(t).visualStimuli = myVidStructArray.(stimNames{t});
    myExpTrials(t).syllable = myVidStructArray.(stimNames{t})(1).syllable;
    myExpTrials(t).actor = myVidStructArray.(stimNames{t})(1).actor;
    [myExpTrials(t).audy, myExpTrials(t).audfreq] = audioread(fullfile(cfg.dir.stimuli, ...
                                                                       [myExpTrials(t).stimulusName '.wav']));
    myExpTrials(t).audioData = myExpTrials(t).audy';
    myExpTrials(t).trialtype = 0; % will be 1 if trial is a target
end

talkToMe(cfg, '\n');

%%  Experiment

% Safety loop: close the screen if code crashes
try

    %% Init the experiment
    cfg = initPTB(cfg);

    [cfg, myExpTrials] = postInitializationSetup(cfg, myExpTrials, myVidStructArray);

    unfold(cfg);

    % Repetition loop
    for rep = 1:nReps

        cfg.subject.runNb = rep;

        % define an index (v) number of one-back trials (2 or 3) in the block,
        % depending on the VISUAL blocks we are in
        if ismember(rep, twoBackBlocksVisual)
            v = 2;
        elseif ismember(rep, threeBackBlocksVisual)
            v = 3;
        end
        % same index but for AUDIO blocks (w)
        if ismember(rep, twoBackBlocksAudio)
            w = 2;
        elseif ismember(rep, threeBackBlocksAudio)
            w = 3;
        end

        % and choose randomly which trial will be repeated in this block (if any)
        backTrialsVisual = sort(randperm(cfg.design.nbTrials, v));
        backTrialsAudio = sort(randperm(cfg.design.nbTrials, w));

        % prepare the KbQueue to collect responses
        getResponse('init', cfg.keyboard.responseBox, cfg);

        % blocks correspond to modality, so each 'rep' has 2 blocks = 2 acquisition runs
        for block = 1:nBlocks

            blockStart = GetSecs;

            Screen('FillRect', cfg.screen.win, cfg.color.background, cfg.screen.winRect);

            DrawFormattedText(cfg.screen.win, ...
                              cfg.task.instruction, ...
                              'center', 'center', cfg.text.color);

            Screen('Flip', cfg.screen.win);

            blockModality = orderCondVector(block);
            if blockModality == visualCond
                r = v;
                backTrials = backTrialsVisual;
                modality = 'vis';
            elseif blockModality == auditoryCond
                r = w;
                backTrials = backTrialsAudio;
                modality = 'aud';
            end

            cfg.task.name = [cfg.expName modality];
            cfg.fileName.task = cfg.task.name;

            cfg = createFilename(cfg);

            % Prepare for the output logfiles with all
            logFile = struct('extraColumns', {cfg.extraColumns}, ...
                             'isStim', false);
            logFile = saveEventsFile('init', cfg, logFile);
            logFile = saveEventsFile('open', cfg, logFile);

            % Pseudorandomization made based on syllable vector
            [~, pseudoSyllIndex] = pseudorandptb(cfg.stimSyll);
            for ind = 1:length(cfg.stimSyll)
                pseudorandExpTrials(ind) = myExpTrials(pseudoSyllIndex(ind));
            end

            pseudoRandExpTrialsBack = addNback(cfg, pseudorandExpTrials, backTrials, r);

            standByScreen(cfg);
            talkToMe(cfg, '\nWAITING FOR TRIGGER (Instructions displayed on the screen)\n\n');
            waitForTrigger(cfg);

            talkToMe(cfg, sprintf('\nNumber of targets in coming trial: %i\n', r));

            cfg.experimentStart = GetSecs();

            getResponse('flush', cfg.keyboard.responseBox);
            getResponse('start', cfg.keyboard.responseBox);

            for iTrial = 1:(cfg.design.nbTrials + r)

                talkToMe(cfg, sprintf('\n - Running trial %.0f \n', iTrial));

                %  Check for experiment abortion from operator
                checkAbort(cfg, cfg.keyboard.keyboard);

                thisEvent.event = iTrial;
                thisEvent.key_name = 'n/a';
                thisEvent.modality = modality;
                thisEvent.block = block;
                thisEvent.repetition = rep;
                thisEvent.target = pseudoRandExpTrialsBack(iTrial).trialtype;
                thisEvent.stim_file = pseudoRandExpTrialsBack(iTrial).stimulusName;
                thisEvent.actor = pseudoRandExpTrialsBack(iTrial).actor;
                thisEvent.consonant = pseudoRandExpTrialsBack(iTrial).syllable(1);
                thisEvent.vowel = pseudoRandExpTrialsBack(iTrial).syllable(2);
                thisEvent.audioData = pseudoRandExpTrialsBack(iTrial).audioData;
                thisEvent.visualData = pseudoRandExpTrialsBack(iTrial).visualStimuli;

                switch modality
                    case 'vis'
                        instruction = 'Faites attention aux LEVRES';
                    case 'aud'
                        instruction = 'Faites attention aux VOIX';
                end

                if iTrial == 1
                    DrawFormattedText(cfg.screen.win, ...
                                      instruction, ...
                                      'center', ...
                                      'center', ...
                                      cfg.text.color);
                    Screen('Flip', cfg.screen.win);
                    WaitSecs(0.5);
                end

                Screen('FillRect', cfg.screen.win, cfg.color.background);
                [~, ~, lastEventTime] = Screen('Flip', cfg.screen.win);

                switch modality
                    case 'vis'

                        thisEvent.stim_file = [thisEvent.stim_file '*.png'];

                        % frames presentation loop
                        for f = 1:cfg.nbFrames

                            Screen('DrawTexture', ...
                                   cfg.screen.win, ...
                                   thisEvent.visualData(f).imageTexture);
                            [vbl, ~, lastEventTime, missed] = Screen('Flip', ...
                                                                     cfg.screen.win, ...
                                                                     lastEventTime + cfg.timing.frameDuration);

                            % time stamp to measure stimulus duration on screen
                            if f == 1
                                onset = vbl;
                            end

                        end

                        offset = vbl;

                    case 'aud'

                        thisEvent.stim_file = [thisEvent.stim_file '.wav'];

                        % Fill the audio playback buffer with the audio data:
                        PsychPortAudio('FillBuffer', cfg.audio.pahandle, thisEvent.audioData);

                        % Start audio playback
                        % 'repetitions' repetitions of the sound data,
                        % start it immediately (0)
                        % wait for the playback to start,
                        % return onset timestamp.
                        repetitions = 1;
                        when = 0;
                        waitForPlaybackStart = 1;
                        onset = PsychPortAudio('Start', cfg.audio.pahandle, repetitions, when, waitForPlaybackStart);

                        status.Active = true;
                        while status.Active
                            status = PsychPortAudio('GetStatus', cfg.audio.pahandle);
                        end
                        [~, ~, ~, offset] = PsychPortAudio('Stop', cfg.audio.pahandle);

                end

                % clear last frame
                Screen('FillRect', cfg.screen.win, cfg.color.background);

                % ISI
                [~, ~, ISIend] = Screen('Flip', cfg.screen.win, offset + cfg.timing.ISI);
                % fb about duration in cw
                talkToMe(cfg, sprintf('\nTiming ISI - the duration was: %f sec\n', ISIend - offset));

                thisEvent.duration = offset - onset;
                thisEvent.onset = onset - cfg.experimentStart;

                %% Save the events to the logfile
                % we save event by event so we clear this variable every loop
                thisEvent.isStim = logFile.isStim;
                thisEvent.fileID = logFile.fileID;
                thisEvent.extraColumns = logFile.extraColumns;
                saveEventsFile('save', cfg, thisEvent);

                %% Collect and saves the responses
                responseEvents = getResponse('check', cfg.keyboard.responseBox, cfg);
                if isfield(responseEvents(1), 'onset') && ~isempty(responseEvents(1).onset)
                    for iResp = 1:size(responseEvents, 1)
                        responseEvents(iResp).onset = ...
                            responseEvents(iResp).onset - cfg.experimentStart;
                        responseEvents(iResp).key_name = responseEvents(iResp).keyName;
                    end
                    responseEvents(1).isStim = false;
                    responseEvents(1).fileID = logFile.fileID;
                    responseEvents(1).extraColumns = logFile.extraColumns;

                    saveEventsFile('save', cfg, responseEvents);
                end

            end

            % End of the run
            WaitSecs(cfg.timing.endDelay);

            getResponse('stop', cfg.keyboard.responseBox);

            % Close the logfiles
            saveEventsFile('close', cfg, logFile);
            createJson(cfg, cfg);

            blockEnd = GetSecs;
            blockDur = blockEnd - blockStart;
            talkToMe(sprintf('\nTotal block duration: %f\n', blockDur));

        end

    end

    cfg = getExperimentEnd(cfg);

    getResponse('release', cfg.keyboard.responseBox);

    farewellScreen(cfg, 'Fin de l''experience :)\nMERCI !');

    cleanUp();

catch

    cleanUp();
    psychrethrow(psychlasterror);

end
