function [cfg] = setConfigurationVoiceEmo()
    % (C) Copyright 2022 Remi Gau

    [cfg] = setConfiguration();

    %% Auditory Stimulation
    cfg.audio.do = true;
    cfg.audio.channels = 2;

    %% Task(s)
    cfg.task.name = 'emotionLocalizerVocal';

    % Instruction
    cfg.task.instruction = 'TACHE\n Appuyez quand une syllabe est repetee deux fois d''affilee';

    cfg.bids.MRI.Instructions = cfg.task.instruction;

    %% Experiment Design
    cfg.extraColumns = {'stim_file', ...
                        'block', ...
                        'target', ...
                        'key_name'};
end
