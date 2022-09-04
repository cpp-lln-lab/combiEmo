function playWav(repetitions, fileDuration, wavfilename)

    % Read WAV file from filesystem:
    [y, freq] = audioread(wavfilename);
    wavedata = y';
    nrchannels = size(wavedata, 1); % Number of rows == number of channels.

    if nrchannels < 2
        wavedata = [wavedata; wavedata];
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
    PsychPortAudio('Start', pahandle, repetitions, 0, 1);

    % Stay in a little loop for 2 seconds:
    timeStamp = GetSecs;
    t1 = 0;
    while t1 < fileDuration
        [keyIsDown, time, key] = KbCheck;

        %     if keyIsDown
        %         break
        %     end

        t2 = GetSecs;
        t1 = t2 - timeStamp;

    end

    % while 1
    %
    % [keyIsDown, ~, audioKey] = KbCheck;
    %
    %     % Query current playback status and print it to the Matlab window:
    %     PsychPortAudio('GetStatus', pahandle);
    %
    %     if keyIsDown
    %         if strcmp(KbName(find(audioKey)),'p')
    %             break
    %         end
    %     end
    %
    %
    % end

    % Stop playback:
    PsychPortAudio('Stop', pahandle);

    % Close the audio device:
    PsychPortAudio('Close', pahandle);

    % Done.
end
