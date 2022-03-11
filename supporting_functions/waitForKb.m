function [answer] = waitForKb(targetKey, deviceNumber)

    % Waits for a specific Keyboard press

    if isempty(deviceNumber)
        deviceNumber = -3;
    end

    % Wait until all keys are released
    while KbCheck
    end

    answer = -1;

    while 1
        % Check the state of the keyboard.
        [keyIsDown, KbTime, keyCode] = KbCheck(deviceNumber);

        % If the subject is pressing a key
        % check whether it is the space button
        if keyIsDown
            if keyCode(KbName(targetKey))
                answer = 1;
                break
            end

            % If the user holds down a key, KbCheck will report multiple events.
            % To condense multiple 'keyDown' events into a single event, we wait until all
            % keys have been released.
            while KbCheck
            end
        end
    end
end
