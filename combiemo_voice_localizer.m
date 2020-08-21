%%% Voice Localizer for the CombiEmo Exp %%%
% programmer: Federica Falagiarda 2020

expName = 'voice_localizer_combiemo';
expStart = GetSecs;

%%% some useful variables/parameters %%%
% background color and fixation color
white = 255;
black = 0;
bgColor = black;
fixColor = black;
textColor = white;

%%% input info
subjNumber = input('Subject number:'); % subject number
subjAge = input('Age:');
nReps = input('Number of repetitions:'); % number or reps of this localizer, ideally 12+ %

if isempty(nReps)
    nReps=12;
end

% add supporting functions to the path
addpath(genpath('./supporting_functions'));

%%% SET UP OUTPUT FILES %%%
dataFileName = [cd '/data/subj' num2str(subjNumber) '_' expName '.txt'];
% format for the output od the data %
formatString = '%d, %d, %s, %1.3f, %1.3f, %1.3f, \n'; 
keypressFormatString = '%d, %1.3f, \n';
baselineFormatString = '%1.3f, \n';

% open a file for reading AND writing
% permission 'a' appends data without deleting potential existing content

if exist(dataFileName, 'file') == 0
    dataFile = fopen(dataFileName, 'a');
        
    % header
    fprintf(dataFile, ['Experiment:\t' expName '\n']);
    fprintf(dataFile, ['date:\t' datestr(now) '\n']);
    fprintf(dataFile, ['Subject:\t' num2str(subjNumber) '\n']);
    fprintf(dataFile, ['Age:\t' num2str(subjAge) '\n']);
    
    %data
    fprintf(dataFile, '%s \n', 'block, trial, stimulusname, ISIduration, stimduration, timestamp'); 
    fclose(dataFile);
   
end

%%% INITIALIZE SCREEN AND START THE STIMULI PRESENTATION %%%

% basic setup checking
AssertOpenGL;

% This sets a PTB preference to possibly skip some timing tests: a value
% of 0 runs these tests, and a value of 1 inhibits them. This
% should always be set to 0 for actual experiments
Screen('Preference', 'SkipSyncTests', 0);
%Screen('Preference', 'SkipSyncTests', 2);

Screen('Preference', 'ConserveVRAM', 4096);

% define default font size for all text uses (i.e. DrawFormattedText fuction)
Screen('Preference', 'DefaultFontSize', 28);

% OpenWindow
%[mainWindow, screenRect] = Screen('OpenWindow', max(screenVector), bgColor, [0 0 1000 700], 32, 2);
[mainWindow, screenRect] = Screen('OpenWindow', max(Screen('Screens')), bgColor, [], 32, 2);

% estimate the monitor flip interval for the onscreen window
interFrameInterval = Screen('GetFlipInterval', mainWindow); % in seconds
msInterFrameInterval = interFrameInterval*1000; %in ms
 
% timings in my stimuli presentation
fileDuration = 1 - interFrameInterval/3;
ISI = 0.1 - interFrameInterval/3;
% create a distribution to draw random jitters
%minJitter=-0.25;
%maxJitter=0.25;
%jitterDistribution=create_jitter(minJitter,maxJitter);

% get width and height of the screen
screenVector = Screen('Screens');
[widthWin, heightWin] = Screen('WindowSize', mainWindow);
widthDis = Screen('DisplaySize', max(screenVector));
%Priority(MaxPriority(mainWindow));

% to overcome the well-known randomisation problem
RandStream.setGlobalStream (RandStream('mt19937ar','seed',sum(100*clock)));

% hide mouse cursor
HideCursor(mainWindow);
% % Listening enabled and any output of keypresses to Matlabs windows is
% % suppressed (see ref. page for ListenChar)
ListenChar(-1);
KbName('UnifyKeyNames');

% build structure for all stimuli needed in this localizer
%
stimNameVoices = {'A27ne.wav','A27di.wav','A27fe.wav','A27ha.wav','A27sa.wav','A30ne.wav','A30di.wav','A30fe.wav','A30ha.wav','A30sa.wav','A32ne.wav','A32di.wav','A32fe.wav','A32ha.wav','A32sa.wav','A33ne.wav','A33di.wav','A33fe.wav','A33ha.wav','A33sa.wav'};
stimEmotion = repmat(1:5,1,4);
stimActor = [repmat(27,1,5),repmat(30,1,5),repmat(32,1,5),repmat(33,1,5)];
blockTypeVoices = 1; % 1 for voices, 2 for objects

stimNameObjects = {'waterpour.wav','carignition.wav','mixing.wav','egg.wav','bikebell.wav','applause.wav','engine.wav','grinder.wav','sharpener.wav','opencan.wav','churchbell.wav','hairdryer.wav','keyboard.wav','phone.wav','river.wav','saw.wav','thunder.wav','toothbrush.wav','traffic.wav','wind.wav'};
blockTypeObjects = 2;



%% Build structures for stimuli presentation
nStim = 20; %per block

voices = struct;
for v=1:nStim
    voices(v).stimulusname = stimNameVoices{v};
    [voices(v).y, voices(v).freq] = audioread([cd '/auditory_stim/' voices(v).stimulusname]);
    voices(v).wavedata = voices(v).y';
    voices(v).nrchannels = size(voices(v).wavedata,1);
    voices(v).emotion = stimEmotion(v);
    voices(v).actor = stimActor(v);
    voices(v).blocktype = blockTypeVoices;
end

objects = struct;
for o=1:nStim
    objects(o).stimulusname = stimNameObjects{o};
    [objects(o).y, objects(o).freq] = audioread([cd '/auditory_stim/' objects(o).stimulusname]);
    objects(o).wavedata = objects(o).y';
    objects(o).nrchannels = size(objects(o).wavedata,1);
    objects(o).blocktype = blockTypeObjects;
end



%% Insert the task stimuli as extra trials
% vector with block numbers
allBlocks = 1:nReps;
% randomly select a third of the blocks to have 2 1-back stimuli for the voices %
twoBackStimBlocksVoices = datasample(allBlocks,round(length(allBlocks)/3),'Replace',false);
% from the remaining blocks, select another third to have one 1-back stimulus %
remainingBlocksVoices = setdiff(allBlocks,twoBackStimBlocksVoices);
oneBackStimBlocksVoices = datasample(remainingBlocksVoices,round(length(allBlocks)/3),'Replace',false);
% the unselected blocks will have no 1-back stimuli
zeroBackStimBlocksVoices = setdiff(remainingBlocksVoices,oneBackStimBlocksVoices);
% randomly select a third of the blocks to have 2 1-back stimuli for the objects%
twoBackStimBlocksObjects = datasample(allBlocks,round(length(allBlocks)/3),'Replace',false);
% from the remaining blocks, select another third to have one 1-back stimulus %
remainingBlocksObjects = setdiff(allBlocks,twoBackStimBlocksObjects);
oneBackStimBlocksObjects = datasample(remainingBlocksObjects,round(length(allBlocks)/3),'Replace',false);
% the unselected blocks will have no 1-back stimuli
zeroBackStimBlocksObjects = setdiff(remainingBlocksObjects,oneBackStimBlocksObjects);


%% Presentation code

% triggers
triiger = struct;
triiger.testingDevice = 'mri'; triiger.triggerKey = 's'; triiger.numTriggers = 1; triiger.win = mainWindow; triiger.text.color = textColor;
triiger.bids.MRI.RepetitionTime = 2.55;

waitForTrigger(triiger);

% prepare the KbQueue to collect responses
[id, names, info] = GetKeyboardIndices();
deviceNumber=max(id); % deviceNumber must refer to external devices in an fMRI session %
KbQueueCreate(deviceNumber);


for rep=1:nReps
    
    Screen('FillRect', mainWindow, bgColor);
    DrawFormattedText(mainWindow, '+', 'center', 'center', textColor);
    [~, ~, lastEventTime] = Screen('Flip', mainWindow);
    
    % acquire some base line
    if rep == 1 || rep==round((nReps/2+1))
           dataFile = fopen(dataFileName, 'a');
           fprintf(dataFile, baselineFormatString, GetSecs-expStart);
           fclose(dataFile);
           WaitSecs(10);
    end

    
    % define an index, a, that knows which kind of block/rep it is for number of one back tasks %
    if ismember(rep,zeroBackStimBlocksVoices)
        a = 0;
    elseif ismember(rep,oneBackStimBlocksVoices)
        a = 1;
    elseif ismember(rep,twoBackStimBlocksVoices)
        a = 2;
    end
    % a different index for objects
    if ismember(rep,zeroBackStimBlocksObjects)
        w = 0;
    elseif ismember(rep,oneBackStimBlocksObjects)
        w = 1;
    elseif ismember(rep,twoBackStimBlocksObjects)
        w = 2;
    end
    
    % and choose randomly which trial will be repeated in this block (if any)
    backTrialsVoices = sort(randperm(20,a));
    backTrialsObjects = sort(randperm(20,w));
    
        % pseudorandomization made based on emotion vector
        [pseudoEmoVector,pseudoEmoIndex] = pseudorandptb(stimEmotion);
        for ind=1:nStim
            voices(pseudoEmoIndex(ind)).pseudorandindex = ind;
        end

        % turn struct into table to reorder it
        tablevoices = struct2table(voices);
        pseudorandtablevoices = sortrows(tablevoices,'pseudorandindex');

        % convert into structure to use in the trial/ stimui loop below
        pseudorandVoices = table2struct(pseudorandtablevoices);
        
        % add 1-back trials to the structure
            pseudorandVoicesBack = pseudorandVoices;
            for b=1:(length(stimEmotion)+a)
                if a == 1
                    if b <= backTrialsVoices
                    pseudorandVoicesBack(b) = pseudorandVoices(b);

                    elseif b == backTrialsVoices+1
                    pseudorandVoicesBack(b) = pseudorandVoices(backTrialsVoices);

                    elseif b > backTrialsVoices+1
                    pseudorandVoicesBack(b) = pseudorandVoices(b-1);

                    end

                elseif a == 2
                    if b <= backTrialsVoices(1)
                    pseudorandVoicesBack(b) = pseudorandVoices(b);

                    elseif b == backTrialsVoices(1)+1
                    pseudorandVoicesBack(b) = pseudorandVoices(backTrialsVoices(1));

                    elseif b == backTrialsVoices(2)+2
                    pseudorandVoicesBack(b) = pseudorandVoices(backTrialsVoices(2));

                    elseif b > backTrialsVoices(1)+1 && b < backTrialsVoices(2)+2
                    pseudorandVoicesBack(b) = pseudorandVoices(b-1);

                    elseif b > backTrialsVoices(2)+2
                    pseudorandVoicesBack(b) = pseudorandVoices(b-2);

                    end
                end

            end
    
         % shuffle object structure (pseudorand needed based on some feature?)%
         randObjects = Shuffle(objects);
         % add 1-back trials to the structure
         randObjectsBack = randObjects;
         for b=1:(length(stimEmotion)+w)
                if w == 1
                    if b <= backTrialsObjects
                    randObjectsBack(b) = objects(b);

                    elseif b == backTrialsObjects+1
                    randObjectsBack(b) = objects(backTrialsObjects);

                    elseif b > backTrialsObjects+1
                    randObjectsBack(b) = objects(b-1);

                    end

                elseif w == 2
                    if b <= backTrialsObjects(1)
                    randObjectsBack(b) = objects(b);

                    elseif b == backTrialsObjects(1)+1
                    randObjectsBack(b) = objects(backTrialsObjects(1));

                    elseif b == backTrialsObjects(2)+2
                    randObjectsBack(b) = objects(backTrialsObjects(2));

                    elseif b > backTrialsObjects(1)+1 && b < backTrialsObjects(2)+2
                    randObjectsBack(b) = objects(b-1);

                    elseif b > backTrialsObjects(2)+2
                    randObjectsBack(b) = objects(b-2);

                    end
                end

         end
    
    
        % stimuli presentation loop
        for trial=1:nStim+a
            
            % record any keypress or scanner trigger (flush previously queued ones) % 
            KbQueueFlush(deviceNumber);         
            KbQueueStart(deviceNumber);
            
            % fixation cross
            DrawFormattedText(mainWindow, '+', 'center', 'center', textColor);
            Screen('Flip', mainWindow);


            if pseudorandVoicesBack(trial).nrchannels < 2
                wavedata = [pseudorandVoicesBack(trial).wavedata ; pseudorandVoicesBack(trial).wavedata];
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
            stimStart = GetSecs;
            PsychPortAudio('Start', pahandle, 1, 0, 1);


            % Stay in a little loop for the file duration:        
            t1 = 0;
            while t1 < fileDuration
                [keyIsDown, time, key] = KbCheck;

                %     if keyIsDown
                %         break
                %     end

                t2 = GetSecs;
                t1 = t2 - stimStart;            
            end

            % Stop playback:
            PsychPortAudio('Stop', pahandle);

            % Close the audio device:
            PsychPortAudio('Close', pahandle);

            stimEnd = GetSecs;
            Screen('Flip', mainWindow, stimEnd+ISI);

            % find cued keypresses and then save them to putput
            [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(deviceNumber);
            whichKeys = KbName(find(firstPress));
            howManyKeyInputs = length(whichKeys);
            % open output file to append
            dataFile = fopen(dataFileName, 'a');
            % print keypresses to outputfile
            for p = 1:howManyKeyInputs
                fprintf(dataFile, keypressFormatString, KbName(whichKeys(p)), (firstPress(KbName(whichKeys(p)))-expStart));
            end
            % print stimulus info to outputfile
            fprintf(dataFile, formatString, rep, trial, pseudorandVoicesBack(trial).stimulusname, GetSecs-stimEnd, stimEnd-stimStart, stimStart-expStart);
            fclose(dataFile);

        end

        % stimuli presentation loop for objects
        for trial=1:nStim+w
            
               % record any keypress or scanner trigger (flush previously queued ones) % 
               KbQueueFlush(deviceNumber);         
               KbQueueStart(deviceNumber);
            
            % fixation cross
            DrawFormattedText(mainWindow, '+', 'center', 'center', textColor);
            Screen('Flip', mainWindow);

            % audio presentation
            if randObjectsBack(trial).nrchannels < 2
                wavedata = [randObjectsBack(trial).wavedata ; randObjectsBack(trial).wavedata];
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
            stimStart = GetSecs;
            PsychPortAudio('Start', pahandle, 1, 0, 1);

            % Stay in a little loop for the file duration:        
            t1 = 0;
            while t1 < fileDuration
                [keyIsDown, time, key] = KbCheck;

                %     if keyIsDown
                %         break
                %     end

                t2 = GetSecs;
                t1 = t2 - stimStart;            
            end

            % Stop playback:
            PsychPortAudio('Stop', pahandle);

            % Close the audio device:
            PsychPortAudio('Close', pahandle);

            stimEnd = GetSecs;
            Screen('Flip', mainWindow, stimEnd+ISI);
            
            % find cued keypresses and then save them to putput
            [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(deviceNumber);
            whichKeys = KbName(find(firstPress));
            howManyKeyInputs = length(whichKeys);
            % open outputfile to append
            dataFile = fopen(dataFileName, 'a');
            % print keypresses to outputfile
            for p = 1:howManyKeyInputs
                fprintf(dataFile, keypressFormatString, KbName(whichKeys(p)), (firstPress(KbName(whichKeys(p)))-expStart));
            end
            % print stimulus info to outputfile
            fprintf(dataFile, formatString, rep, trial, randObjectsBack(trial).stimulusname, GetSecs-stimEnd, stimEnd-stimStart, stimStart-expStart);
            fclose(dataFile);

        end   
        
             % more baseline
            if rep == nReps
                dataFile = fopen(dataFileName, 'a');
                fprintf(dataFile, baselineFormatString, GetSecs-expStart);
                fclose(dataFile);
                WaitSecs(10);
            end
end

DrawFormattedText(mainWindow, 'end of localizer :)', 'center', 'center', textColor);
Screen('Flip', mainWindow);
expEnd = GetSecs;
disp('Voice localizer duration:')
disp((expEnd-expStart)/60);
waitForKb('space');
ListenChar(0);
ShowCursor;
sca;