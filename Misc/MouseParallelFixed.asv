% Clear the workspace, initialize and open screen.
close all;
clear all;
PsychDefaultSetup(2);       
screens = Screen('Screens');
screenNumber = max(screens);
[window, windowRect] = Screen('OpenWindow', screenNumber, [0 0 0]);

%Get relevant parameters:
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

% Set the priority level that will be called
topPriorityLevel = MaxPriority(window);

%----------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------
ifi = Screen('GetFlipInterval', window);
AnswerPhaseDuration = 3; 
PrePhaseDuration = 1; 
PostPhaseDuration = 3;
WaitingPhaseDuration = 1;
numTrials = 3;

%----------------------------------------------------------------------
%                       Stimulus Information
%----------------------------------------------------------------------
ScaleFactor = 0.5; %How big the image is relative to the full screen height
TargetPosRange = 500; %How big the target box is (from center-range to center+range)
FixationCrossSize = 40;


%----------------------------------------------------------------------
%                       Initialize Images
%----------------------------------------------------------------------
%Read images from the folder 'Images'
ImageFolder = fullfile(pwd,'Images');
file = dir(ImageFolder);
NF = length(file)-2;
ImageList = cell(NF,1);
TextureList = cell(NF,1);
for k = 1 : NF
  ImageList{k} = imread(fullfile(ImageFolder, file(k+2).name));
  TextureList{k} = Screen('MakeTexture',window,ImageList{k});
end
[s1, s2, s3] = size(ImageList{1});

%Calculate positions of left, center and right.
imageRectCenter = fnScaleImage(s1,s2,ScaleFactor,[xCenter yCenter],screenYpixels);
imageRectLeft = fnScaleImage(s1,s2,ScaleFactor,[(xCenter-TargetPosRange)/2 yCenter],screenYpixels);
imageRectRight = fnScaleImage(s1,s2,ScaleFactor,[2*xCenter-(xCenter-TargetPosRange)/2 yCenter],screenYpixels);


Priority(topPriorityLevel);

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

for trial = 1:numTrials
    % If this is the first trial we present a start screen and wait for a
    % key-press
    if trial == 1
        DrawFormattedText(window, 'Press Any Key To Begin', ...
            'center', 'center', [255 255 255]);
        vbl = Screen('Flip', window);
        KbStrokeWait;
    end
    if ~KbCheck
        %Choose the letter to show
        index = round(rand)+1;
        ShownTexture = TextureList{index};

        %****************Phase 1: Pre-Phase*************************
        %Draw the frame (empty)
        Screen('FrameRect',window, [255 255 255], [xCenter-TargetPosRange yCenter-300 xCenter+TargetPosRange yCenter+300],30);
        %Draw the cross
        fnDrawFixationCross(FixationCrossSize,window,windowRect);
        %Draw the letter
        Screen('DrawTexture', window, ShownTexture, [], imageRectLeft);
        %Flip
        vbl = Screen('Flip',window,vbl+WaitingPhaseDuration);


        %****************Phase 2: Answer Phase*************************
        %Draw the frame
        Screen('FrameRect',window, [255 255 255], [xCenter-TargetPosRange yCenter-300 xCenter+TargetPosRange yCenter+300],30);
        %Draw the letter
        Screen('DrawTexture', window, ShownTexture, [], imageRectCenter);
        %Flip
        vbl = Screen('Flip',window,vbl+PrePhaseDuration);


        %****************Phase 3: Reward & Punishment Phase****************



        %****************Phase 4: Post-Phase*************************
        %Draw the frame (empty)
        Screen('FrameRect',window, [255 255 255], [xCenter-TargetPosRange yCenter-300 xCenter+TargetPosRange yCenter+300],30);
        %Draw the cross
        fnDrawFixationCross(FixationCrossSize,window,windowRect);
        %Draw the letter
        Screen('DrawTexture', window, ShownTexture, [], imageRectRight);
        %Flip
        vbl = Screen('Flip',window,vbl+AnswerPhaseDuration);

        %****************Phase 5: Waiting Phase*************************
        %Draw the frame (empty)
        Screen('FrameRect',window, [255 255 255], [xCenter-TargetPosRange yCenter-300 xCenter+TargetPosRange yCenter+300],30);
        vbl = Screen('Flip',window,vbl+PostPhaseDuration);
                  
    end
end
Priority(0);
% Clear the screen and exit.
sca;
close all;
clear all;