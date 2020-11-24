%%% Face Localizer for the CombiEmo Exp %%%
% programmer: Federica Falagiarda 2020

expName = 'facelocalizerCombiemo';
%expStart = GetSecs;

%%% some useful variables/parameters %%%
% background color and fixation color
white = 255;
black = 0;
bgColor = black;
textColor = white;

%%% input info
subjNumber = input('Subject number:'); % subject number
subjAge = input('Age:'); % age
nReps = input('Number of repetitions:'); % number or reps of this localizer, ideally 10+ %
nSes = input('Session nr:', 's');

if isempty(nReps)
    nReps=10;
end

% add supporting functions to the path
addpath(genpath('./supporting_functions'));

%%% SET UP OUTPUT FILES %%%
dataFileName = [cd '/data/sub-' num2str(subjNumber) '_ses-' num2str(nSes) '_task-' expName '_allevents.tsv'];
dataFileNameBIDS = [cd '/data/sub-' num2str(subjNumber) '_ses-' num2str(nSes) '_task-' expName '_events.tsv'];

% format for the output od the data %
formatString = '%d, %d, %s, %1.3f, %1.3f, %1.3f \n';
formatStringBIDS = '%1.3f, %1.3f, %s \n';
keypressFormatString = '%d, %1.3f \n';
baselineFormatString = '%s, %1.3f \n';

% open files for reading AND writing
% permission 'a' appends data without deleting potential existing content
if exist(dataFileName, 'file') == 0
    dataFile = fopen(dataFileName, 'a');        
    % header
    fprintf(dataFile, ['Experiment:\t' expName '\n']);
    fprintf(dataFile, ['date:\t' datestr(now) '\n']);
    fprintf(dataFile, ['Subject:\t' num2str(subjNumber) '\n']);
    fprintf(dataFile, ['Age:\t' num2str(subjAge) '\n']);    
    % header for the data
    fprintf(dataFile, '%s \n', 'block, trial, stimulusname, ISIduration, stimduration, timestamp'); 
    fclose(dataFile);
end
% open files for reading AND writing
% permission 'a' appends data without deleting potential existing content
if exist(dataFileNameBIDS, 'file') == 0
    dataFile = fopen(dataFileNameBIDS, 'a');        
    % header for the data
    fprintf(dataFile, '%s \n', 'onset, duration, trial_type'); 
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
 
%%% more useful variables %%%
% timings in my stimuli presentation sequence %
ISI = 0.1 - interFrameInterval/5;
fixationDur = 0.5 - interFrameInterval/5;
responseDur = 4 - interFrameInterval/5;
practiceResponseDur = 5 - interFrameInterval/5;
nFrames=30;
videoFrameRate = 29.97;
frameDuration = 1/videoFrameRate - interFrameInterval/5;

% build structure needed for getResponse function
cfg = struct;
cfg.keyboard.escapeKey = 'ESCAPE';
cfg.keyboard.responseKey = []; % leave this empty to cue for all keys %
cfg.keyboard.keyboard = [];
cfg.keyboard.responseBox = [];

% get width and height of the screen
screenVector = Screen('Screens');
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

%% creating my stimuli through a structures system
frameNum = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30'}; % numbers used in images names %
actor = {'27','30','32','33'}; % actor numbers %
emotion = {'ne','di','fe','ha','sa'}; % how emotions are identified in the images names %
objectNames = {'candlesmall','carrousel','coffee','discs','fanceiling','fire','fireworks','flag','kettle','leaves','lpplayer','roulette','sewing','spinningtop','tire','toilet','trafficlight','water','waterfalls','windmills'};

% A big cell array will all the file names of the faces images, each full face video is arranged by column, and has 30 frames (rows) %
allFrameNamesFaces = cell(30,20); % preallocate cell-array
c=1; % fill in the cell array with the names (strings) %
for a = 1:length(actor)
    for e = 1:length(emotion)
        for f = 1:length(frameNum)
        allFrameNamesFaces{f,c} = {['V' actor{a} emotion{e} '_' frameNum{f}]}; % names of the files are built through the actor number + emotion letters + frame number %
        end
        c=c+1;
    end
end

% A big cell array will all the file names of the objects images, each full object video is arranged by column, and has 30 frames (rows) %
allFrameNamesObjects = cell(30,20); % preallocate cell'array
c=1; % fill in the cell array with the names (strings) %
for o = 1:length(objectNames)
    for f = 1:length(frameNum)
    allFrameNamesObjects{f,c} = {[objectNames{o} frameNum{f}]}; % names of the files are built through the object name + frame number %
    end
    c=c+1;
end


% Preallocate one structure per video and then fill it with names and images"
faceFramePath = '/visual_stim/face_frames_unmasked/'; % where to find the face images

Ne27Struct = struct; Ne27Struct = buildFramesStruct(mainWindow, Ne27Struct, nFrames, frameDuration, allFrameNamesFaces(:,1), faceFramePath);
Di27Struct = struct; Di27Struct = buildFramesStruct(mainWindow, Di27Struct, nFrames, frameDuration, allFrameNamesFaces(:,2), faceFramePath);
Fe27Struct = struct; Fe27Struct = buildFramesStruct(mainWindow, Fe27Struct, nFrames, frameDuration, allFrameNamesFaces(:,3), faceFramePath);
Ha27Struct = struct; Ha27Struct = buildFramesStruct(mainWindow, Ha27Struct, nFrames, frameDuration, allFrameNamesFaces(:,4), faceFramePath);
Sa27Struct = struct; Sa27Struct = buildFramesStruct(mainWindow, Sa27Struct, nFrames, frameDuration, allFrameNamesFaces(:,5), faceFramePath);

Ne30Struct = struct; Ne30Struct = buildFramesStruct(mainWindow, Ne30Struct, nFrames, frameDuration, allFrameNamesFaces(:,6), faceFramePath);
Di30Struct = struct; Di30Struct = buildFramesStruct(mainWindow, Di30Struct, nFrames, frameDuration, allFrameNamesFaces(:,7), faceFramePath);
Fe30Struct = struct; Fe30Struct = buildFramesStruct(mainWindow, Fe30Struct, nFrames, frameDuration, allFrameNamesFaces(:,8), faceFramePath);
Ha30Struct = struct; Ha30Struct = buildFramesStruct(mainWindow, Ha30Struct, nFrames, frameDuration, allFrameNamesFaces(:,9), faceFramePath);
Sa30Struct = struct; Sa30Struct = buildFramesStruct(mainWindow, Sa30Struct, nFrames, frameDuration, allFrameNamesFaces(:,10), faceFramePath);

Ne32Struct = struct; Ne32Struct = buildFramesStruct(mainWindow, Ne32Struct, nFrames, frameDuration, allFrameNamesFaces(:,11), faceFramePath);
Di32Struct = struct; Di32Struct = buildFramesStruct(mainWindow, Di32Struct, nFrames, frameDuration, allFrameNamesFaces(:,12), faceFramePath);
Fe32Struct = struct; Fe32Struct = buildFramesStruct(mainWindow, Fe32Struct, nFrames, frameDuration, allFrameNamesFaces(:,13), faceFramePath);
Ha32Struct = struct; Ha32Struct = buildFramesStruct(mainWindow, Ha32Struct, nFrames, frameDuration, allFrameNamesFaces(:,14), faceFramePath);
Sa32Struct = struct; Sa32Struct = buildFramesStruct(mainWindow, Sa32Struct, nFrames, frameDuration, allFrameNamesFaces(:,15), faceFramePath);

Ne33Struct = struct; Ne33Struct = buildFramesStruct(mainWindow, Ne33Struct, nFrames, frameDuration, allFrameNamesFaces(:,16), faceFramePath);
Di33Struct = struct; Di33Struct = buildFramesStruct(mainWindow, Di33Struct, nFrames, frameDuration, allFrameNamesFaces(:,17), faceFramePath);
Fe33Struct = struct; Fe33Struct = buildFramesStruct(mainWindow, Fe33Struct, nFrames, frameDuration, allFrameNamesFaces(:,18), faceFramePath);
Ha33Struct = struct; Ha33Struct = buildFramesStruct(mainWindow, Ha33Struct, nFrames, frameDuration, allFrameNamesFaces(:,19), faceFramePath);
Sa33Struct = struct; Sa33Struct = buildFramesStruct(mainWindow, Sa33Struct, nFrames, frameDuration, allFrameNamesFaces(:,20), faceFramePath);

% put all structures together in one array that will be embedded in another structure %
myFacesStructArray = {Ne27Struct,Di27Struct,Fe27Struct,Ha27Struct,Sa27Struct,Ne30Struct,Di30Struct,Fe30Struct,Ha30Struct,Sa30Struct,Ne32Struct,Di32Struct,Fe32Struct,Ha32Struct,Sa32Struct,Ne33Struct,Di33Struct,Fe33Struct,Ha33Struct,Sa33Struct};


% Preallocate and build one structure per object video too
objectFramePath = '/visual_stim/object_frames/'; % where to find the object images

candlesmallStruct = struct;  candlesmallStruct = buildFramesStruct(mainWindow, candlesmallStruct, nFrames, frameDuration, allFrameNamesObjects(:,1), objectFramePath);
carrouselStruct = struct;    carrouselStruct = buildFramesStruct(mainWindow, carrouselStruct, nFrames, frameDuration, allFrameNamesObjects(:,2), objectFramePath);
coffeeStruct = struct;       coffeeStruct = buildFramesStruct(mainWindow, coffeeStruct, nFrames, frameDuration, allFrameNamesObjects(:,3), objectFramePath);
discsStruct = struct;        discsStruct = buildFramesStruct(mainWindow, discsStruct, nFrames, frameDuration, allFrameNamesObjects(:,4), objectFramePath);
fanceilingStruct = struct;   fanceilingStruct = buildFramesStruct(mainWindow, fanceilingStruct, nFrames, frameDuration, allFrameNamesObjects(:,5), objectFramePath);
fireStruct = struct;         fireStruct = buildFramesStruct(mainWindow, fireStruct, nFrames, frameDuration, allFrameNamesObjects(:,6), objectFramePath);
fireworksStruct = struct;    fireworksStruct = buildFramesStruct(mainWindow, fireworksStruct, nFrames, frameDuration, allFrameNamesObjects(:,7), objectFramePath);
flagStruct = struct;         flagStruct = buildFramesStruct(mainWindow, flagStruct, nFrames, frameDuration, allFrameNamesObjects(:,8), objectFramePath);
kettleStruct = struct;       kettleStruct = buildFramesStruct(mainWindow, kettleStruct, nFrames, frameDuration, allFrameNamesObjects(:,9), objectFramePath);
leavesStruct = struct;       leavesStruct = buildFramesStruct(mainWindow, leavesStruct, nFrames, frameDuration, allFrameNamesObjects(:,10), objectFramePath);
lpplayerStruct = struct;     lpplayerStruct = buildFramesStruct(mainWindow, lpplayerStruct, nFrames, frameDuration, allFrameNamesObjects(:,11), objectFramePath);
rouletteStruct = struct;     rouletteStruct = buildFramesStruct(mainWindow, rouletteStruct, nFrames, frameDuration, allFrameNamesObjects(:,12), objectFramePath);
sewingStruct = struct;       sewingStruct = buildFramesStruct(mainWindow, sewingStruct, nFrames, frameDuration, allFrameNamesObjects(:,13), objectFramePath);
spinningtopStruct = struct;  spinningtopStruct = buildFramesStruct(mainWindow, spinningtopStruct, nFrames, frameDuration, allFrameNamesObjects(:,14), objectFramePath);
tireStruct = struct;         tireStruct = buildFramesStruct(mainWindow, tireStruct, nFrames, frameDuration, allFrameNamesObjects(:,15), objectFramePath);
toiletStruct = struct;       toiletStruct = buildFramesStruct(mainWindow, toiletStruct, nFrames, frameDuration, allFrameNamesObjects(:,16), objectFramePath);
trafficlightStruct = struct; trafficlightStruct = buildFramesStruct(mainWindow, trafficlightStruct, nFrames, frameDuration, allFrameNamesObjects(:,17), objectFramePath);
waterStruct = struct;        waterStruct = buildFramesStruct(mainWindow, waterStruct, nFrames, frameDuration, allFrameNamesObjects(:,18), objectFramePath);
waterfallsStruct = struct;   waterfallsStruct = buildFramesStruct(mainWindow, waterfallsStruct, nFrames, frameDuration, allFrameNamesObjects(:,19), objectFramePath);
windmillsStruct = struct;    windmillsStruct = buildFramesStruct(mainWindow, windmillsStruct, nFrames, frameDuration, allFrameNamesObjects(:,20), objectFramePath);


% put all structures together in an array
myObjectsStructArray = {candlesmallStruct,carrouselStruct,coffeeStruct,discsStruct,fanceilingStruct,fireStruct,fireworksStruct,flagStruct,kettleStruct,leavesStruct,lpplayerStruct,rouletteStruct,sewingStruct,spinningtopStruct,tireStruct,toiletStruct,trafficlightStruct,waterStruct,waterfallsStruct,windmillsStruct};


%% create the structures with all the stimuli and corollary info
nStim = 20; %per block
stimNameFaces = {'V27ne ','V27di ','V27fe ','V27ha ','V27sa ','V30ne ','V30di ','V30fe ','V30ha ','V30sa ','V32ne ','V32di ','V32fe ','V32ha ','V32sa ','V33ne ','V33di ','V33fe ','V33ha ','V33sa '};
stimEmotion = repmat(1:5,1,4);
stimActor = [repmat(27,1,5),repmat(30,1,5),repmat(32,1,5),repmat(33,1,5)];
blockTypeFaces = 1; % 1 for faces, 2 for objects
blockTypeObjects = 2;

% Structure containing the video structures and all the needed info on the face stimuli %
faces = struct;
for v=1:nStim
    faces(v).stimulusname = stimNameFaces{v};
    faces(v).stimuli = myFacesStructArray{v};
    faces(v).emotion = stimEmotion(v);
    faces(v).actor = stimActor(v);
    faces(v).blocktype = blockTypeFaces;
end

% Structure containing the video structures and all the needed info on the object stimuli %
objects = struct;
for o=1:nStim
    objects(o).stimulusname = objectNames{o};
    objects(o).stimuli = myObjectsStructArray{o};
    objects(o).blocktype = blockTypeObjects;
end

%% Insert the task stimuli as extra trials
% vector with block numbers
allBlocks = 1:nReps;
% randomly select a third of the blocks to have 2 1-back stimuli for the Faces %
twoBackStimBlocksFaces = datasample(allBlocks,round(length(allBlocks)/3),'Replace',false);
% from the remaining blocks, select another third to have one 1-back stimulus %
remainingBlocksFaces = setdiff(allBlocks,twoBackStimBlocksFaces);
oneBackStimBlocksFaces = datasample(remainingBlocksFaces,round(length(allBlocks)/3),'Replace',false);
% the unselected blocks will have no 1-back stimuli
zeroBackStimBlocksFaces = setdiff(remainingBlocksFaces,oneBackStimBlocksFaces);
% randomly select a third of the blocks to have 2 1-back stimuli for the objects%
twoBackStimBlocksObjects = datasample(allBlocks,round(length(allBlocks)/3),'Replace',false);
% from the remaining blocks, select another third to have one 1-back stimulus %
remainingBlocksObjects = setdiff(allBlocks,twoBackStimBlocksObjects);
oneBackStimBlocksObjects = datasample(remainingBlocksObjects,round(length(allBlocks)/3),'Replace',false);
% the unselected blocks will have no 1-back stimuli
zeroBackStimBlocksObjects = setdiff(remainingBlocksObjects,oneBackStimBlocksObjects);


%% Stimuli presentation code
Screen('FillRect', mainWindow, bgColor);
[~, ~, lastEventTime] = Screen('Flip', mainWindow);
trial_type=struct('type',{'faces','objects','baseline'});

% triggers
trigger = struct;
trigger.testingDevice = 'mri'; trigger.triggerKey = 's'; trigger.numTriggers = 1; trigger.win = mainWindow; trigger.text.color = textColor;
trigger.bids.MRI.RepetitionTime = 2.55;

waitForTrigger(trigger);

% prepare the KbQueue to collect responses
[id, names, info] = GetKeyboardIndices();
deviceNumber=max(id); % deviceNumber must refer to external devices in an fMRI session %
KbQueueCreate(deviceNumber);

% measure exp start right after trigger
expStart = GetSecs;

% Start stimuli presentation (this is several repetition, but only one acquisition sequence) %
for rep=1:nReps
    
    Screen('FillRect', mainWindow, bgColor);
    DrawFormattedText(mainWindow, '+', 'center', 'center', textColor);
    [~, ~, lastEventTime] = Screen('Flip', mainWindow);
    
    % acquire some base line
    if rep == 1 || rep==(nReps/2+1)
        dataFile = fopen(dataFileName, 'a');
        fprintf(dataFile, baselineFormatString, 'baseline' ,GetSecs-expStart);
        fclose(dataFile);
%         dataFile = fopen(dataFileNameBIDS, 'a');
%         fprintf(dataFile, formatStringBIDS, GetSecs-expStart, 10, 'baseline');
%         fclose(dataFile);
        WaitSecs(10);
    end
        
%     % fourth trigger of the first rep
%     % first of all other reps 
%     waitForKb('s');
%     Screen('FillRect', mainWindow, bgColor);
%     [~, ~, lastEventTime] = Screen('Flip', mainWindow);
    
    % define an index, a, that knows which kind of block/rep it is for number of one back tasks %
    if ismember(rep,zeroBackStimBlocksFaces)
        a = 0;
    elseif ismember(rep,oneBackStimBlocksFaces)
        a = 1;
    elseif ismember(rep,twoBackStimBlocksFaces)
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
    backTrialsFaces = sort(randperm(20,a));
    backTrialsObjects = sort(randperm(20,w));
    
    repStart = GetSecs;
    
        % pseudorandomization made based on emotion vector for the faces
        [pseudoEmoVector,pseudoEmoIndex] = pseudorandptb(stimEmotion);
        for ind=1:nStim
            faces(pseudoEmoIndex(ind)).pseudorandindex = ind;
        end

        % turn struct into table to reorder the faces structure through the pseudorandomization index %
        tablefaces = struct2table(faces);
        pseudorandtablefaces = sortrows(tablefaces,'pseudorandindex');

        % convert back into structure et voilà, you have a pseudorandomized structure to use in the trial/ stimui loop below
        pseudorandFaces = table2struct(pseudorandtablefaces);

        
    % add 1-back trials to the structure
    pseudorandFacesBack = pseudorandFaces;
    for b=1:(length(stimEmotion)+a)
        if a == 1
            if b <= backTrialsFaces
            pseudorandFacesBack(b) = pseudorandFaces(b);

            elseif b == backTrialsFaces+1
            pseudorandFacesBack(b) = pseudorandFaces(backTrialsFaces);

            elseif b > backTrialsFaces+1
            pseudorandFacesBack(b) = pseudorandFaces(b-1);

            end

        elseif a == 2
            if b <= backTrialsFaces(1)
            pseudorandFacesBack(b) = pseudorandFaces(b);

            elseif b == backTrialsFaces(1)+1
            pseudorandFacesBack(b) = pseudorandFaces(backTrialsFaces(1));

            elseif b == backTrialsFaces(2)+2
            pseudorandFacesBack(b) = pseudorandFaces(backTrialsFaces(2));

            elseif b > backTrialsFaces(1)+1 && b < backTrialsFaces(2)+2
            pseudorandFacesBack(b) = pseudorandFaces(b-1);

            elseif b > backTrialsFaces(2)+2
            pseudorandFacesBack(b) = pseudorandFaces(b-2);

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
                randObjectsBack(b) = randObjects(b);

                elseif b == backTrialsObjects+1
                randObjectsBack(b) = randObjects(backTrialsObjects);

                elseif b > backTrialsObjects+1
                randObjectsBack(b) = randObjects(b-1);

                end

            elseif w == 2
                if b <= backTrialsObjects(1)
                randObjectsBack(b) = randObjects(b);

                elseif b == backTrialsObjects(1)+1
                randObjectsBack(b) = randObjects(backTrialsObjects(1));

                elseif b == backTrialsObjects(2)+2
                randObjectsBack(b) = randObjects(backTrialsObjects(2));

                elseif b > backTrialsObjects(1)+1 && b < backTrialsObjects(2)+2
                randObjectsBack(b) = randObjects(b-1);

                elseif b > backTrialsObjects(2)+2
                randObjectsBack(b) = randObjects(b-2);

                end
            end

     end
    
    
        % FACES
        faceBlockStart=GetSecs;

        % record any keypress or scanner trigger (flush previously queued ones) %
        KbQueueFlush(deviceNumber);
        KbQueueStart(deviceNumber);
               
            %trial loop for faces blocks   
            for trial=1:nStim+a
                
                % frames presentation loop
                for g = 1:nFrames
                    Screen('DrawTexture', mainWindow, pseudorandFacesBack(trial).stimuli(g).imageTexture, [], [], 0);
                    [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);
                    % time stamp to measure stimulus duration on screen
                    if g == 1
                        stimStart = GetSecs;
                    end

                end

                % clear last frame                
                Screen('FillRect', mainWindow, bgColor);
                [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);                
                stimEnd = GetSecs;
                Screen('Flip', mainWindow, stimEnd+ISI);
                
                
        
        % print stimulus info to outputfile
        dataFile = fopen(dataFileName, 'a');
        fprintf(dataFile, formatString, rep, trial, pseudorandFacesBack(trial).stimulusname, GetSecs-stimEnd, stimEnd-stimStart, stimStart-expStart);
        fclose(dataFile);

            end
        
        %end of the block timestamp
        faceBlockEnd = GetSecs;
            
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
        fprintf(dataFile, formatStringBIDS, (firstPress(KbName(whichKeys(p)))-expStart), 0, thisPress);
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
        fprintf(dataFile, formatStringBIDS, (lastPress(KbName(whichKeys(p)))-expStart), 0, thisPress);
        end
        % print stimulus info to outputfile
        fprintf(dataFile, formatStringBIDS, faceBlockStart-expStart, faceBlockEnd-faceBlockStart, trial_type(1).type);
        fclose(dataFile);

        
        % OBJECTS                           
        objectBlockStart=GetSecs;
        
        % record any keypress or scanner trigger (flush previously queued ones) %
        KbQueueFlush(deviceNumber);
        KbQueueStart(deviceNumber);
        

            % trial loop for object blocks 
            for trial=1:nStim+w        

            
                % frames presentation loop
                for g = 1:nFrames
                    Screen('DrawTexture', mainWindow, randObjectsBack(trial).stimuli(g).imageTexture, [], [], 0);
                    [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);
                    % time stamp to measure stimulus duration on screen
                    if g == 1
                        stimStart = GetSecs;
                    end

                end

                % clear last frame                
                Screen('FillRect', mainWindow, bgColor);
                [~, ~, lastEventTime] = Screen('Flip', mainWindow, lastEventTime+frameDuration);
                stimEnd = GetSecs;
                Screen('Flip', mainWindow, stimEnd+ISI);              
                
                
        % print stimulus info to outputfile
        dataFile = fopen(dataFileName, 'a');
        fprintf(dataFile, formatString, rep, trial, randObjectsBack(trial).stimulusname, GetSecs-stimEnd, stimEnd-stimStart, stimStart-expStart);
        fclose(dataFile);

            end    
            
        %end of the block timestamp
        objectBlockEnd = GetSecs;
            
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
        fprintf(dataFile, formatStringBIDS, (firstPress(KbName(whichKeys(p)))-expStart), 0, thisPress);
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
        fprintf(dataFile, formatStringBIDS, (lastPress(KbName(whichKeys(p)))-expStart), 0, thisPress);
        end
        % print stimulus info to outputfile
        fprintf(dataFile, formatStringBIDS, objectBlockStart-expStart, objectBlockEnd-objectBlockStart, trial_type(2).type);
        fclose(dataFile);
         
            % more baseline
            Screen('FillRect', mainWindow, bgColor);
            DrawFormattedText(mainWindow, '+', 'center', 'center', textColor);
            [~, ~, lastEventTime] = Screen('Flip', mainWindow);
            if rep == nReps
                dataFile = fopen(dataFileName, 'a');
                fprintf(dataFile, baselineFormatString, 'baseline',GetSecs-expStart);
                fclose(dataFile);
%                 dataFile = fopen(dataFileNameBIDS, 'a');
%                 fprintf(dataFile, formatStringBIDS, GetSecs-expStart, 10, trial_type(3).type);
%                 fclose(dataFile);
                WaitSecs(10);
            end
end

% End of experiment + goodbye messages and duration display
expEnd = GetSecs;
DrawFormattedText(mainWindow, 'end of localizer :)', 'center', 'center', textColor);
Screen('Flip', mainWindow);
waitForKb('space');
disp('Face localizer duration:')
disp((expEnd-expStart)/60);
disp('Last rep duration:')
disp((expEnd-repStart));
ListenChar(0);
ShowCursor;
sca;