%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Stimulation for functional runs of fMRI design  %%%
%%%   programmer: Federica Falagiarda October 2019   %%%
%%%   current last mod: May 2021                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Once fully run, this script has given a txt output file per run (nReps*3) with:%

% stimuli are presented in blocks; each block contains one modality of stimuli %
% possible modalities are: visual (face), auditory (voice), bimodal (face and voice vombined) %
% there are four possible emotions portrayed by four identities %
% EMOTIONS: disgust, fear, happiness, sadness, neutral %
% identities: act27 female, act30 female, act32 lae, act33, male %

expName = 'eventrelatedCombiemo';

%%% All useful variables/parameters %%%

% colors
white = 255;
black = 0;
midgrey = [127 127 127];
bgColor = black;
fixColor = black;
textColor = white;

% variables to build block / trial loops
nBlocks = 3; % num of different runs - one per modality * num of reps
nTrials = 20; % per run: 4 emotions * 4 actors * 2 within-run reps (more stable beta)
visualModality = 1;
auditoryModality = 2;
multiModality = 3;

% for the frame loop (visual stim)
nFrames = 30; % total num of frames in a whole video
nStimPerEvent = 2;
stimXsize = 720;
stimYsize = 480;


% input info
subjNumber = input('Subject number:', 's');
subjAge = input('Age:');
nReps = input('Number of repetitions:');
nSes = input('Session nr:', 's');
% if no value is supplied, do 12 reps
if isempty(nReps)
    nReps=10;
end

% this defines the modality block order within a subject
% modality orded will be fixed within participant, and randomized/balanced across %
% 1 = visual, 2 = auditory, 3 = bimodal
blockModalityVector = input('Input in square brackets - modality order:');
% if no value is supplied, choose order randomly
if isempty(blockModalityVector)
    blockModalityVector=randperm(3);
end

% add supporting functions to the path
addpath(genpath('./supporting_functions'));


%% INITIALIZE SCREEN AND START THE STIMULI PRESENTATION %%

% basic setup checking
AssertOpenGL;

% This sets a PTB preference to possibly skip some timing tests: a value
% of 0 runs these tests, and a value of 1 inhibits them. This
% should always be set to 0 for actual experiments
%Screen('Preference', 'SkipSyncTests', 2);
Screen('Preference', 'SkipSyncTests', 0);

Screen('Preference', 'ConserveVRAM', 4096);

% define default font size for all text uses (i.e. DrawFormattedText fuction)
Screen('Preference', 'DefaultFontSize', 32);

screenVector = Screen('Screens');
% OpenWindow
%[mainWindow, screenRect] = Screen('OpenWindow', max(screenVector), bgColor, [0 0 1000 700], 32, 2);
[mainWindow, screenRect] = Screen('OpenWindow', max(screenVector), bgColor, [], 32, 2);
%[mainWindow, screenRect] = Screen('OpenWindow', 0, bgColor, [0 0 700 500], 32, 2);
%[mainWindow, screenRect] = Screen('OpenWindow', 0, bgColor);

% estimate the monitor flip interval for the onscreen window
interFrameInterval = Screen('GetFlipInterval', mainWindow); % in seconds
msInterFrameInterval = interFrameInterval*1000; %in ms

% timings in my trial sequence
ISI = 5 - interFrameInterval/3; % actually full event duration
fixationDur = 0.5 - interFrameInterval/3;
responseDur = 4 - interFrameInterval/3;
practiceResponseDur = 5 - interFrameInterval/3;
videoFrameRate = 29.97;
frameDuration = 1/videoFrameRate - interFrameInterval/3;
audioFileDuration = 1 - 2*interFrameInterval/3;
minJitter=-0.25;
maxJitter=0.25;
% create a distribution to draw random jitters
%jitterDistribution=create_jitter(minJitter,maxJitter);

% get width and height of the screen
[widthWin, heightWin] = Screen('WindowSize', mainWindow);
widthDis = Screen('DisplaySize', max(screenVector));
Priority(MaxPriority(mainWindow));

% to overcome the well-known randomisation problem
RandStream.setGlobalStream (RandStream('mt19937ar','seed',sum(100*clock)));

% hide mouse cursor
HideCursor(mainWindow);
% Listening enabled and any output of keypresses to Matlabs windows is
% suppressed (see ref. page for ListenChar)
ListenChar(-1);
KbName('UnifyKeyNames');

% prepare the KbQueue to collect responses
[id, names, info] = GetKeyboardIndices();
deviceNumber=max(id); % deviceNumber must refer to external devices in an fMRI session %
KbQueueCreate(deviceNumber);

        % FIXATION CROSS JAZZ %
        % estimate the distance between subject and monitor, in cm
        testDistance = 60; % to be changed with real value

        %calcualte degree to pixels conversion coefficient
        deg2pixCoeff = 1/(atan(widthDis/(widthWin*(testDistance*10)))*180/pi);
        
        % define the dimension of the fixation cross in degrees and convert it to
        % pixels using the deg2pix coefficient
        fixationSizeDeg = 0.3;
        fixationSizePix = round(fixationSizeDeg * deg2pixCoeff);

        % define the dimension of the line for your fixation cross and convert it
        % to pixels
        lineSize = 0.05;
        lineSizePix = round(lineSize *deg2pixCoeff);

        % find the center of the screen and transpose to column
        centros = (screenRect(3:4)/2)';

        % fixation cross coordinates
        fixationXY = repmat(centros, 1, 4) + [0, 0, fixationSizePix, -fixationSizePix; fixationSizePix, -fixationSizePix, 0, 0];
        
        % define distance of stimulus from center of the screen and convert
        % it to pixels
        stimDegDistance = 6;
        stimPixDistance = round(stimDegDistance * deg2pixCoeff);
        

%% CREATING THE VISUAL STIMULI

frameNum = (1:30);
actor = {'27','30','32','33'};
emotion = {'ne','di','fe','ha','sa'};

allFrameNamesFaces = cell(30,20);
c=1;
for a = 1:length(actor)
    for e = 1:length(emotion)
        for f = 1:length(frameNum)
        allFrameNamesFaces{f,c} = {['V' actor{a} emotion{e} '_' num2str(frameNum(f))]};
        end
        c=c+1;
    end
end


% Build one structure per "video"

framePath = '/visual_stim/face_frames/'; % where to find the images

Ne27Struct = struct; Ne27Struct = buildFramesStruct(mainWindow, Ne27Struct, nFrames, frameDuration, allFrameNamesFaces(:,1), framePath);
Di27Struct = struct; Di27Struct = buildFramesStruct(mainWindow, Di27Struct, nFrames, frameDuration, allFrameNamesFaces(:,2), framePath);
Fe27Struct = struct; Fe27Struct = buildFramesStruct(mainWindow, Fe27Struct, nFrames, frameDuration, allFrameNamesFaces(:,3), framePath);
Ha27Struct = struct; Ha27Struct = buildFramesStruct(mainWindow, Ha27Struct, nFrames, frameDuration, allFrameNamesFaces(:,4), framePath);
Sa27Struct = struct; Sa27Struct = buildFramesStruct(mainWindow, Sa27Struct, nFrames, frameDuration, allFrameNamesFaces(:,5), framePath);

Ne30Struct = struct; Ne30Struct = buildFramesStruct(mainWindow, Ne30Struct, nFrames, frameDuration, allFrameNamesFaces(:,6), framePath);
Di30Struct = struct; Di30Struct = buildFramesStruct(mainWindow, Di30Struct, nFrames, frameDuration, allFrameNamesFaces(:,7), framePath);
Fe30Struct = struct; Fe30Struct = buildFramesStruct(mainWindow, Fe30Struct, nFrames, frameDuration, allFrameNamesFaces(:,8), framePath);
Ha30Struct = struct; Ha30Struct = buildFramesStruct(mainWindow, Ha30Struct, nFrames, frameDuration, allFrameNamesFaces(:,9), framePath);
Sa30Struct = struct; Sa30Struct = buildFramesStruct(mainWindow, Sa30Struct, nFrames, frameDuration, allFrameNamesFaces(:,10), framePath);

Ne32Struct = struct; Ne32Struct = buildFramesStruct(mainWindow, Ne32Struct, nFrames, frameDuration, allFrameNamesFaces(:,11), framePath);
Di32Struct = struct; Di32Struct = buildFramesStruct(mainWindow, Di32Struct, nFrames, frameDuration, allFrameNamesFaces(:,12), framePath);
Fe32Struct = struct; Fe32Struct = buildFramesStruct(mainWindow, Fe32Struct, nFrames, frameDuration, allFrameNamesFaces(:,13), framePath);
Ha32Struct = struct; Ha32Struct = buildFramesStruct(mainWindow, Ha32Struct, nFrames, frameDuration, allFrameNamesFaces(:,14), framePath);
Sa32Struct = struct; Sa32Struct = buildFramesStruct(mainWindow, Sa32Struct, nFrames, frameDuration, allFrameNamesFaces(:,15), framePath);

Ne33Struct = struct; Ne33Struct = buildFramesStruct(mainWindow, Ne33Struct, nFrames, frameDuration, allFrameNamesFaces(:,16), framePath);
Di33Struct = struct; Di33Struct = buildFramesStruct(mainWindow, Di33Struct, nFrames, frameDuration, allFrameNamesFaces(:,17), framePath);
Fe33Struct = struct; Fe33Struct = buildFramesStruct(mainWindow, Fe33Struct, nFrames, frameDuration, allFrameNamesFaces(:,18), framePath);
Ha33Struct = struct; Ha33Struct = buildFramesStruct(mainWindow, Ha33Struct, nFrames, frameDuration, allFrameNamesFaces(:,19), framePath);
Sa33Struct = struct; Sa33Struct = buildFramesStruct(mainWindow, Sa33Struct, nFrames, frameDuration, allFrameNamesFaces(:,20), framePath);

% put them all together
myFacesStructArray = {Ne27Struct,Di27Struct,Fe27Struct,Ha27Struct,Sa27Struct,Ne30Struct,Di30Struct,Fe30Struct,Ha30Struct,Sa30Struct,Ne32Struct,Di32Struct,Fe32Struct,Ha32Struct,Sa32Struct,Ne33Struct,Di33Struct,Fe33Struct,Ha33Struct,Sa33Struct};


%% AUDITORY STIMULI
%stimNameVoices = {'A27ne.wav','A27di.wav','A27fe.wav','A27ha.wav','A27sa.wav','A30ne.wav','A30di.wav','A30fe.wav','A30ha.wav','A30sa.wav','A32ne.wav','A32di.wav','A32fe.wav','A32ha.wav','A32sa.wav','A33ne.wav','A33di.wav','A33fe.wav','A33ha.wav','A33sa.wav'};
stimName = {'27ne','27di','27fe','27ha','27sa','30ne','30di','30fe','30ha','30sa','32ne','32di','32fe','32ha','32sa','33ne','33di','33fe','33ha','33sa'};

stimEmotion = repmat(1:5,1,4);
stimActor = [repmat(27,1,5),repmat(30,1,5),repmat(32,1,5),repmat(33,1,5)];

%% Read everything into a structure
% preallocate
myExpTrials = struct;
% for the experiment
for t = 1:length(stimName)
        myExpTrials(t).stimulusname = stimName{t};
        myExpTrials(t).visualstimuli = myFacesStructArray{t};
        [myExpTrials(t).audy, myExpTrials(t).audfreq] = audioread([cd '/auditory_stim/rms_A' myExpTrials(t).stimulusname '.wav']);
        myExpTrials(t).wavedata = myExpTrials(t).audy';
        myExpTrials(t).nrchannels = size(myExpTrials(t).wavedata,1);
        myExpTrials(t).emotion = stimEmotion(t);
        myExpTrials(t).actor = stimActor(t);
end

% black image for audio-only presentation
blackImage = Screen('MakeTexture', mainWindow ,imread([cd '/visual_stim/black_img.png']));

%% Insert the task stimuli as extra trials
% vector with block numbers
allBlocks = 1:nReps;
stimEmotion = repmat(1:5,1,4);

% randomly select a third of the blocks to have 2 1-back stimuli for the voices %
twoBackStimBlocksVoices = datasample(allBlocks,round(length(allBlocks)/3),'Replace',false);
% from the remaining blocks, select another third to have one 1-back stimulus %
remainingBlocksVoices = setdiff(allBlocks,twoBackStimBlocksVoices);
oneBackStimBlocksVoices = datasample(remainingBlocksVoices,round(length(allBlocks)/3),'Replace',false);
% the unselected blocks will have no 1-back stimuli
zeroBackStimBlocksVoices = setdiff(remainingBlocksVoices,oneBackStimBlocksVoices);

% randomly select a third of the blocks to have 2 1-back stimuli for the Faces %
twoBackStimBlocksFaces = datasample(allBlocks,round(length(allBlocks)/3),'Replace',false);
% from the remaining blocks, select another third to have one 1-back stimulus %
remainingBlocksFaces = setdiff(allBlocks,twoBackStimBlocksFaces);
oneBackStimBlocksFaces = datasample(remainingBlocksFaces,round(length(allBlocks)/3),'Replace',false);
% the unselected blocks will have no 1-back stimuli
zeroBackStimBlocksFaces = setdiff(remainingBlocksFaces,oneBackStimBlocksFaces);

% randomly select a third of the blocks to have 2 1-back stimuli for the objects%
twoBackStimBlocksPerson = datasample(allBlocks,round(length(allBlocks)/3),'Replace',false);
% from the remaining blocks, select another third to have one 1-back stimulus %
remainingBlocksPerson = setdiff(allBlocks,twoBackStimBlocksPerson);
oneBackStimBlocksPerson = datasample(remainingBlocksPerson,round(length(allBlocks)/3),'Replace',false);
% the unselected blocks will have no 1-back stimuli
zeroBackStimBlocksPerson = setdiff(remainingBlocksPerson,oneBackStimBlocksPerson);



%% BLOCK AND TRIAL LOOP
% for sound to be used: perform basic initialization of the sound driver
InitializePsychSound(1);
% priority
Priority(MaxPriority(mainWindow));

% triggers
trigger = struct;
trigger.testingDevice = 'mri'; trigger.triggerKey = 's'; trigger.numTriggers = 1; trigger.win = mainWindow; trigger.text.color = textColor;
trigger.bids.MRI.RepetitionTime = 1.75;

% time stamp as the experiment starts
expStart = GetSecs;

% Repetition loop
for rep = 1:nReps  
    
  
    
%     % check on participant every 3 blocks
%     if rep > 1
%         DrawFormattedText(mainWindow, 'Ready to continue?', 'center', 'center', textColor);
%         Screen('Flip', mainWindow);
%         waitForKb('space');
%     end
    
    
    % define an index, n, that knows which kind of block/rep it is for number of one back tasks for faces %
    if ismember(rep,zeroBackStimBlocksFaces)
        n = 0;
    elseif ismember(rep,oneBackStimBlocksFaces)
        n = 1;
    elseif ismember(rep,twoBackStimBlocksFaces)
        n = 2;
    end
    % a different index for voices
    if ismember(rep,zeroBackStimBlocksVoices)
        v = 0;
    elseif ismember(rep,oneBackStimBlocksVoices)
        v = 1;
    elseif ismember(rep,twoBackStimBlocksVoices)
        v = 2;
    end
    % a different index for bimodal
    if ismember(rep,zeroBackStimBlocksPerson)
        w = 0;
    elseif ismember(rep,oneBackStimBlocksPerson)
        w = 1;
    elseif ismember(rep,twoBackStimBlocksPerson)
        w = 2;
    end
    
    % and choose randomly which trial will be repeated in this block (if any)
    backTrialsFaces = sort(randperm(20,n));
    backTrialsVoices = sort(randperm(20,v));
    backTrialsPerson = sort(randperm(20,w));
    
    
    % blocks correspond to modality, so each rep has 3 blocks %
    % blocks are also separate acquisition runs %
    for block = 1:nBlocks
    blockModality = blockModalityVector(block);
    
    if blockModality == visualModality
        r = n;
        backTrials = backTrialsFaces;
        expName = 'eventrelatedCombiemoVisual';
    elseif blockModality == auditoryModality
        r = v;
        backTrials = backTrialsVoices;        
        expName = 'eventrelatedCombiemoAuditory';
    elseif blockModality == multiModality
        r = w;
        backTrials = backTrialsPerson;        
        expName = 'eventrelatedCombiemoBimodal';
    end
    
      repStart = GetSecs;
    
            % Set up output file for current run (1 BLOCK = 1 ACQUISITION RUN) % 
            %dataFileName = [cd '/data/sub-' num2str(subjNumber) '_ses-' num2str(nSes) '_task-' expName '_run-' num2str(rep) num2str(block) '_allevents.tsv'];
            dataFileNameBIDS = [cd '/data/sub-' num2str(subjNumber) '_ses-' num2str(nSes) '_task-' expName '_run-' num2str(rep) '_events.tsv'];
            
            
            % format for the output od the data %
            %formatStringBIDS = '%1.3f, %1.3f, %d, %d, %d \n'; %comma eparated%
            %formatStringKeys = '%1.3f, %1.3f, %s, %s, %s \n'; %comma eparated%
            formatStringBIDS = '%1.3f\t %1.3f\t %d\t %d\t %d \n';
            formatStringKeys = '%1.3f\t %1.3f\t %s\t %s\t %s \n';

            
            % open files for reading AND writing
            % permission 'a' appends data without deleting potential existing content
            if exist(dataFileNameBIDS, 'file') == 0
                dataFile = fopen(dataFileNameBIDS, 'a');
%                 % header
%                 fprintf(dataFile, ['Experiment:\t' expName '\n']);
%                 fprintf(dataFile, ['date:\t' datestr(now) '\n']);
%                 fprintf(dataFile, ['Subject:\t' num2str(subjNumber) '\n']);
%                 fprintf(dataFile, ['Age:\t' num2str(subjAge) '\n']);
                % header for the data
                fprintf(dataFile, '%s \n', 'onset   duration    trial_type  modality    actor');
                fclose(dataFile);
            end
    
        % Pseudorandomization made based on emotion vector for the faces
        [pseudoEmoVector,pseudoEmoIndex] = pseudorandptb(stimEmotion);
        for ind=1:length(stimEmotion)
            myExpTrials(pseudoEmoIndex(ind)).pseudorandindex = ind;
        end

        % turn struct into table to reorder it
        tableexptrials = struct2table(myExpTrials);
        pseudorandtabletrials = sortrows(tableexptrials,'pseudorandindex');

        % convert into structure to use in the trial/ stimui loop below
        pseudorandExpTrials = table2struct(pseudorandtabletrials);
        
        
        % add 1-back trials for current block type %
        pseudoRandExpTrialsBack = pseudorandExpTrials;
             for b=1:(length(stimEmotion)+r)
                if r == 1
                    if b <= backTrials
                    pseudoRandExpTrialsBack(b) = pseudorandExpTrials(b);

                    elseif b == backTrials+1 % this trial will have a repeated emotion but a different actor                        
                            % find where the same-emotion-different-actor rows are %
                            emotionVector = [pseudorandExpTrials.emotion]; 
                            emotionIndices = find(emotionVector == pseudorandExpTrials(backTrials).emotion);
                            emotionIndices(emotionIndices==(b-1)) = []; % get rid of current actor 
                            % and choose randomly among the others
                            pseudoRandExpTrialsBack(b) = pseudorandExpTrials(randsample(emotionIndices,1));                          

                    elseif b > backTrials+1
                    pseudoRandExpTrialsBack(b) = pseudorandExpTrials(b-1);

                    end

                elseif r == 2
                    if b <= backTrials(1)
                    pseudoRandExpTrialsBack(b) = pseudorandExpTrials(b);

                    elseif b == backTrials(1)+1 % this trial will have a repeated emotion but a different actor                        
                            % find where the same-emotion-different-actor rows are %
                            emotionVector = [pseudorandExpTrials.emotion]; 
                            emotionIndices = find(emotionVector == pseudorandExpTrials(backTrials(1)).emotion);
                            emotionIndices(emotionIndices==b-1) = []; % get rid of current actor 
                            % and choose randomly among the others
                            pseudoRandExpTrialsBack(b) = pseudorandExpTrials(randsample(emotionIndices,1));

                    elseif b == backTrials(2)+2 % this trial will have a repeated emotion but a different actor                        
                            % find where the same-emotion-different-actor rows are %
                            emotionVector = [pseudorandExpTrials.emotion]; 
                            emotionIndices = find(emotionVector == pseudorandExpTrials(backTrials(2)).emotion);
                            emotionIndices(emotionIndices==b-2) = []; % get rid of current actor 
                            % and choose randomly among the others
                            pseudoRandExpTrialsBack(b) = pseudorandExpTrials(randsample(emotionIndices,1));

                    elseif b > backTrials(1)+1 && b < backTrials(2)+2
                    pseudoRandExpTrialsBack(b) = pseudorandExpTrials(b-1);

                    elseif b > backTrials(2)+2
                    pseudoRandExpTrialsBack(b) = pseudorandExpTrials(b-2);
                    
                    end
                end
             end
        
            % 1 trigger then start
            waitForTrigger(trigger);
            
            % let me know how many trials in this run
            disp('Number of trials in this run:');
            disp(nTrials+r);

        % trial loop of the current run
        for trial = 1:(nTrials+r)
            
            % let me know the current trial number
            disp('Current trial:');
            disp(trial);

            % start queuing for triggers and subject's keypresses (flush previous queue) %
               % record any keypress or scanner trigger (flush previously queued ones) % 
               KbQueueFlush(deviceNumber);         
               KbQueueStart(deviceNumber);
    
            % which kind of block is it? Stimulus presentation changes based on modality %
            
            %% visual
            if blockModality == visualModality
                
                % get lastEventTime
                [vlb, ~, lastEventTime] = Screen('Flip', mainWindow);
                
                if trial == 1
                runStart = GetSecs;
                end

                   % frames presentation loop
                   for stimNr = 1:nStimPerEvent                    
                    for f = 1:nFrames   

                       Screen('DrawTexture', mainWindow, pseudoRandExpTrialsBack(trial).visualstimuli(f).imageTexture, [], [], 0);
                       [vlb, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);

                       % time stamp to measure stimulus duration on screen
                       if f == 1 && stimNr == 1
                          stimStart = GetSecs;
                       end

                    end
                   end
                    
                % clear last frame                
                Screen('FillRect', mainWindow, bgColor);
                [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);
                
                %Screen('Flip', mainWindow, stimEnd+ISI);
                [~, ~, stimEnd] = Screen('Flip', mainWindow);
                [~, ~, ISIend] = Screen('Flip', mainWindow, stimEnd+(ISI-(stimEnd-stimStart)));

                
            %% auditory    
            elseif blockModality == auditoryModality
                
              % get lastEventTime
              [vlb, ~, lastEventTime] = Screen('Flip', mainWindow);
              
              if trial == 1
              runStart = GetSecs;
              end
                
                if pseudoRandExpTrialsBack(trial).nrchannels < 2
                wavedata = [pseudoRandExpTrialsBack(trial).wavedata ; pseudoRandExpTrialsBack(trial).wavedata];
                nrchannels = 2;
                end

                try
                % Try with the 'freq'uency we wanted:
                pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
                catch
                    % Failed. Retry with default frequency as suggested by device:

                psychlasterror('reset');
                pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
                end

                % Fill the audio playback buffer with the audio data 'wavedata':
                PsychPortAudio('FillBuffer', pahandle, wavedata);

                % Start audio playback for 'repetitions' repetitions of the sound data,
                % start it immediately (0) and wait for the playback to start, return onset
                % timestamp.
                
                for stimNr = 1:nStimPerEvent 
                    
                    % stim start time stamp
                    if stimNr == 1
                    stimStart = PsychPortAudio('Start', pahandle, 1, 0, 1);
                    else 
                    PsychPortAudio('Start', pahandle, 1, 0, 1);
                    end
                    

                    % Stay in a little loop for the file duration:     
                    % use frames presentation loop to get the same duration as in the bimodal condition%
                    for f = 1:nFrames   

                    Screen('DrawTexture', mainWindow, blackImage, [], [], 0);
                    DrawFormattedText(mainWindow, '+', 'center', 'center', textColor);
                    [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);

                    end   
                    
                % Stop playback:
                [~, ~, ~, stimEnd] = PsychPortAudio('Stop', pahandle);
                end

                % Close the audio device:
                PsychPortAudio('Close', pahandle);

                % clear stimulus from screen
                Screen('Flip', mainWindow);
                [~, ~, ISIend] = Screen('Flip', mainWindow, stimEnd+(ISI-(stimEnd-stimStart)));

        
            %% bimodal
            elseif blockModality == multiModality   
                
              % get lastEventTime
              [vlb, ~, lastEventTime] = Screen('Flip', mainWindow);
              
              if trial == 1
              runStart = GetSecs;
              end
                
                % play audio first %
                if pseudoRandExpTrialsBack(trial).nrchannels < 2
                wavedata = [pseudoRandExpTrialsBack(trial).wavedata ; pseudoRandExpTrialsBack(trial).wavedata];
                nrchannels = 2;
                end

                try
                % Try with the 'freq'uency we wanted:
                pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
                catch
                    % Failed. Retry with default frequency as suggested by device:

                psychlasterror('reset');
                pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
                end

                % Fill the audio playback buffer with the audio data 'wavedata':
                PsychPortAudio('FillBuffer', pahandle, wavedata);

                % Start audio playback for 'repetitions' repetitions of the sound data,
                % start it immediately (0) and wait for the playback to start, return onset
                % timestamp.
                
                for stimNr = 1:nStimPerEvent
                    
                    % stim start time stamp
                    if stimNr == 1
                    stimStart = PsychPortAudio('Start', pahandle, 1, 0, 1);
                    else 
                    PsychPortAudio('Start', pahandle, 1, 0, 1);
                    end

                    % frames presentation loop
                    for f = 1:nFrames   

                    Screen('DrawTexture', mainWindow, pseudoRandExpTrialsBack(trial).visualstimuli(f).imageTexture, [], [], 0);
                    [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);

                    end

                    % Stop playback:
                    [~, ~, ~, stimEnd] = PsychPortAudio('Stop', pahandle);
                
                end

                % Close the audio device:
                PsychPortAudio('Close', pahandle);

                % flip screen and ISI
                % clear stimulus from screen
                Screen('Flip', mainWindow);
                [~, ~, ISIend] = Screen('Flip', mainWindow, stimEnd+(ISI-(stimEnd-stimStart)));

            end
            
                    % SAVE DATA TO THE OUTPUT FILE % header 'rep, block, modality, trial, actor, emotion, stimlus duration'    
                    %save timestamps to output file
                    % write keypresses and timestamps on its file
                    % find cued keypresses and then save them to putput
                    [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(deviceNumber);
                    whichKeys = KbName(find(firstPress));
                    howManyKeyInputs = length(whichKeys);
                    % open output file to append
                    dataFile = fopen(dataFileNameBIDS, 'a');
                    % print keypresses to outputfile
                    for p = 1:howManyKeyInputs
                       whichKeypress = KbName(KbName(whichKeys(p)));
                        % identify whether the key event was a press or a trigger %
                        if whichKeypress == 's'
                            thisPress = 'trigger';
                        else
                            thisPress = 'keypress';
                        end
                            % print first keypresses info to output file 
                            fprintf(dataFile, formatStringKeys, (firstPress(KbName(whichKeys(p)))-runStart), 0, whichKeypress, thisPress, 'keyevent');
                    end
                    whichKeys = KbName(find(lastPress));
                    howManyKeyInputs = length(whichKeys);
                    % print keypresses to outputfile
                    for p = 1:howManyKeyInputs
                       whichKeypress = KbName(KbName(whichKeys(p)));
                        % identify whether the key event was a press or a trigger %
                        if whichKeypress == 's'
                            thisPress = 'trigger';
                        else
                            thisPress = 'keypress';
                        end
                            % print second keypresses info to output file 
                            fprintf(dataFile, formatStringKeys, (lastPress(KbName(whichKeys(p)))-runStart), 0, whichKeypress, thisPress, 'keyevent');
                    end
                    % print stimulus info to outputfile
                    fprintf(dataFile, formatStringBIDS, stimStart-runStart, stimEnd-stimStart, pseudoRandExpTrialsBack(trial).emotion, blockModality, pseudoRandExpTrialsBack(trial).actor);
                    fclose(dataFile);
                

        end

            repEnd = GetSecs;
            repDuration = (repEnd - repStart)
        
        
        disp('Press space to go on');
            if block == 3
                DrawFormattedText(mainWindow, 'Well done! Now you can rest for about 30 seconds, and the next block will start afterwards... \n\n Remember to press when you perceive the same emotion twice in a row', 'center', 'center', textColor);
            else
                DrawFormattedText(mainWindow, 'Well done! The next block is coming up... \n\n Remember to press when you perceive the same emotion twice in a row', 'center', 'center', textColor);
            end
        Screen('Flip', mainWindow);
        waitForKb('space');
        

    
    end
    
    
end

DrawFormattedText(mainWindow, 'End of the experiment :)', 'center', 'center', textColor);
Screen('Flip', mainWindow);
expEnd = GetSecs;
disp('Exp duration:')
disp((expEnd-expStart)/60);
waitForKb('space');
ListenChar(0);
ShowCursor;
sca;