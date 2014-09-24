function vbl = fndrawflash(window,xCenter,yCenter,flashimage,blankTime,flashTime,BackgCol)
% Draw the flashing image at the start of each trial

%Make texture
image = imread(flashimage);
texture = Screen('MakeTexture',window,image);

Screen('FillRect',window,BackgCol);
vbl = Screen('Flip',window);

Screen('FillRect',window,0);
Screen('DrawTexture',window,texture,[],[xCenter-300 yCenter-300 xCenter+300 yCenter+300]);
vbl = Screen('Flip',window,vbl+blankTime);


singleflashTime = 0.2;
numFlash = flashTime/singleflashTime;

for i = 1:numFlash
        Screen('FillRect',window,BackgCol);
        vbl = Screen('Flip',window,vbl+singleflashTime/2);
        Screen('FillRect',window,255);
        Screen('DrawTexture',window,texture,[],[xCenter-300 yCenter-300 xCenter+300 yCenter+300]);
        vbl = Screen('Flip',window,vbl+singleflashTime/2);
end

Screen('FillRect',window,BackgCol);
vbl = Screen('Flip',window,vbl+singleflashTime/2);
vbl = Screen('Flip',window,vbl+blankTime);

end