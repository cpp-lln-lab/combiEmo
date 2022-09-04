function [cfg] = setConfigurationVoiceEmo()
    % (C) Copyright 2022 Remi Gau

    [cfg] = setConfiguration();

    %% Auditory Stimulation
    cfg.audio.do = true;
    cfg.audio.channels = 2;

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
end
