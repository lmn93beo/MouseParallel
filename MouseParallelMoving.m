% Clear the workspace, initialize and open screen.
close all;
clear all;
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
[window, windowRect] = Screen('OpenWindow', screenNumber, [0 0 0]);

%Get relevant screen parameters:
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

% Set the priority level that will be called
topPriorityLevel = MaxPriority(window);

%----------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------
ifi = Screen('GetFlipInterval', window);
waitFrames = 1;



%----------------------------------------------------------------------
%                       Stimulus Information
%----------------------------------------------------------------------
ScaleFactor = 0.5; %How big the image is relative to the full screen height
TargetPosRange = 500; %How big the target box is (from center-range to center+range)
FixationCrossSize = 40;

%Divide the horizontal length into equal intervals.
%In each interval the speed is specified in SpeedArray. (each row
%represents one trial)
SpeedArray = [200 100 200 100 200 100 200 100 200 100;
              400 100 400 100 400 100 400 100 400 100];
[numTrials, numIntervals] = size(SpeedArray);
PositionArray = 0 : screenXpixels/numIntervals : screenXpixels;

%----------------------------------------------------------------------
%                       Initialize Images
%----------------------------------------------------------------------
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

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------
Priority(topPriorityLevel);
for trial = 1:numTrials
    % If this is the first trial we present a start screen and wait for a
    % key-press
    if trial == 1
        DrawFormattedText(window, 'Press Any Key To Begin', ...
            'center', 'center', [255 255 255]);
        vbl = Screen('Flip', window);
        KbStrokeWait;
    end
    
    % Initialize the position and select a texture to show
    ImxCenter = 0;
    index = round(rand)+1;
    ShownTexture = TextureList{index};
    
    while ImxCenter < screenXpixels && ~KbCheck 
    
        %Construct the rectangle containing the image, then draw the image
        imageRect = fnScaleImage(s1,s2,ScaleFactor,[ImxCenter yCenter],screenYpixels);
        Screen('DrawTexture', window, ShownTexture, [], imageRect);

        %Draw the frame. Frame changes color when the image is inside.
        if imageRect(1) > xCenter-TargetPosRange && imageRect(3) < xCenter+TargetPosRange
            Screen('FrameRect',window, [255 255 255], [xCenter-TargetPosRange yCenter-300 xCenter+TargetPosRange yCenter+300],30);
        else
            Screen('FrameRect',window, [100 100 100], [xCenter-TargetPosRange yCenter-300 xCenter+TargetPosRange yCenter+300],30);
        end
        
        %Draw the cross
        fnDrawFixationCross(FixationCrossSize,window,windowRect);

        %Flip
        vbl = Screen('Flip',window,vbl + (waitFrames-0.5)*ifi);

        %Find the corresponding speed and update center accordingly    
        [m, n] = size(find(PositionArray <= ImxCenter));
        ImxCenter = ImxCenter + ifi*SpeedArray(trial,n);
    end
end

Priority(0);

% Clear the screen and exit
sca;
close all;
clear all;