function [cfg] = setConfigurationFaceEmo()
    % (C) Copyright 2022 Remi Gau

    [cfg] = setConfiguration();

    cfg.vidDuration = 2;
    cfg.videoFrameRate = 25;
    % total num of frames in a whole video
    cfg.nbFrames = cfg.videoFrameRate * cfg.vidDuration;

    tmp = [];
    for a = 1:numel(cfg.actor)
        tmp = [tmp repmat(cfg.actor(a), 1, numel(cfg.syllable))];
    end
    cfg.stimActors = tmp;

    cfg.design.nbTrials = numel(cfg.stimSyll);

    %% Task(s)

    % Instruction
    cfg.task.instruction = 'TACHE\n Appuyez quand une syllabe est repetee deux fois d''affilee';

    cfg.bids.MRI.Instructions = cfg.task.instruction;
    cfg.bids.MRI.TaskDescription = ['One-back task.', ...
                                    'The participant is asked to press a button, ', ...
                                    'when he/she sees a repeated syllable independently of the actor.', ...
                                    'This is to force the participant to attend each syllable ', ...
                                    'that is presented (consonant AND vowel).'];
    cfg.bids.MRI.CogAtlasID = 'https://www.cognitiveatlas.org/task/id/tsk_4a57abb949bcd/';
    cfg.bids.MRI.CogPOID = 'http://www.wiki.cogpo.org/index.php?title=N-back_Paradigm';

    %% Experiment Design
    cfg.extraColumns = {'stim_file', ...
                        'block', ...
                        'target', ...
                        'key_name'};

    cfg.stimName = {'27ne', '27di', '27fe', '27ha', '27sa', '30ne', '30di', '30fe', '30ha', '30sa', '32ne', '32di', '32fe', '32ha', '32sa', '33ne', '33di', '33fe', '33ha', '33sa'};
    cfg.stimEmotion = repmat(1:5, 1, 4);
    cfg.stimActor = [repmat(27, 1, 5), repmat(30, 1, 5), repmat(32, 1, 5), repmat(33, 1, 5)];

    % define actors and syllables used as stim
    % (S1 = AV, S2 = GH, S3 = JB)
    cfg.actor = {'S1', 'S2', 'S3'};
    cfg.syllable = {'pa', 'pi', 'pe', 'fa', 'fi', 'fe', 'la', 'li', 'le'};

    if cfg.debug.do
        cfg.actor = cfg.actor(1:3);
        cfg.syllable = cfg.syllable(1:2);
    end

    % variables necessary during randomization
    cfg.stimSyll = repmat(cfg.syllable, 1, numel(cfg.actor));

end
