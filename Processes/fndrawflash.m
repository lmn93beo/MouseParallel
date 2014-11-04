function vbl = fndrawflash(window,xCenter,yCenter,flashimage,blankTime,flashTime,TargetPosRange,...
        BoxHeight,BoxWidth,Box1Col)
global MainStruct

% Start to count number of licks
MainStruct.numLicks = [0 0 0 0];

% Draw the flashing image at the start of each trial

%Make texture
image = imread(flashimage);
texture = Screen('MakeTexture',window,image);

Screen('FrameRect',window, Box1Col, [xCenter-TargetPosRange yCenter-BoxHeight xCenter+TargetPosRange yCenter+BoxHeight],BoxWidth);
vbl = Screen('Flip',window);

Screen('FrameRect',window, Box1Col, [xCenter-TargetPosRange yCenter-BoxHeight xCenter+TargetPosRange yCenter+BoxHeight],BoxWidth);
vbl = Screen('Flip',window,vbl+blankTime);


singleflashTime = 0.2;
numFlash = flashTime/singleflashTime;

for i = 1:numFlash
        Screen('FrameRect',window, Box1Col, [xCenter-TargetPosRange yCenter-BoxHeight xCenter+TargetPosRange yCenter+BoxHeight],BoxWidth);
        vbl = Screen('Flip',window,vbl+singleflashTime/2);
        Screen('FrameRect',window, Box1Col, [xCenter-TargetPosRange yCenter-BoxHeight xCenter+TargetPosRange yCenter+BoxHeight],BoxWidth);
        Screen('DrawTexture',window,texture,[],[xCenter-300 yCenter-300 xCenter+300 yCenter+300]);
        vbl = Screen('Flip',window,vbl+singleflashTime/2);
end

Screen('FrameRect',window, Box1Col, [xCenter-TargetPosRange yCenter-BoxHeight xCenter+TargetPosRange yCenter+BoxHeight],BoxWidth);
vbl = Screen('Flip',window,vbl+singleflashTime/2);
Screen('FrameRect',window, Box1Col, [xCenter-TargetPosRange yCenter-BoxHeight xCenter+TargetPosRange yCenter+BoxHeight],BoxWidth);

vbl = Screen('Flip',window,vbl+singleflashTime);

% Check num licks again. If non-zero, give punishment!
if sum(MainStruct.numLicks) ~= 0
        arrayfun(@(x) fprintf('Mouse %d gets punished!\n',x),...
                                find(MainStruct.numLicks~=0));
end
end