function cfg = set_cfg

    cfg.stimName = {'27ne', '27di', '27fe', '27ha', '27sa', '30ne', '30di', '30fe', '30ha', '30sa', '32ne', '32di', '32fe', '32ha', '32sa', '33ne', '33di', '33fe', '33ha', '33sa'};
    cfg.stimEmotion = repmat(1:5, 1, 4);
    cfg.stimActor = [repmat(27, 1, 5), repmat(30, 1, 5), repmat(32, 1, 5), repmat(33, 1, 5)];

end
