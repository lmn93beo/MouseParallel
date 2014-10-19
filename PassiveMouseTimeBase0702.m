%% Clear the workspace
close all;
clear all;

addpath(genpath('.\'));

global MainStruct DAQstruct LickLog


%% Initialize DAQ Devices
recports = {'ai0','ai1','ai2','ai3'};
outputports = {'port0/line2','port0/line1','port0/line0','port0/line3'};
num_mice = length(recports);

[RecSession, OutputSession] = InitDAQ(recports,outputports);

%% Initialize Sound
% fnInitSound();
% playsound = 0; %Do we want sound?

%% Set image info
% Image struct array - contains image name and value
% values 1= target or right; 0 = neutral or no reward; -1= punish stop or left
Im = fnSetImageInfo();
ImageFolder = uigetdir(pwd);


%% Initialize and open screen
Screen('Preference', 'SkipSyncTests', 1 );

screens = Screen('Screens');
screenNumber = 0;

%% Stimulus information
[ScaleFactor, TargetPosRange, FixationCrossSize, UseCross, CrossLineWidth,...
        BackgCol, TargetCol, Box1Col, Box2Col, BoxHeight, BoxWidth, ...
        NumFramesWaitZeroSpeed, SpeedArray, blankTime, flashTime, flashimage] = fnStimulusInfo();

%% Juice information

JuiceTime = 0.005;
ImmediateReset = 1;

%% Initialize structs to keep track of performance
[StopTimes, FalsePos, PictureTypeList] = fnInitLog(num_mice);

%% Window-relevant parameters
[window, windowRect] = Screen('OpenWindow', screenNumber, BackgCol);

%Get relevant screen parameters:
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

% Set the priority level that will be called
topPriorityLevel = MaxPriority(window);

%% Initialize images
[TextureList, s1, s2] = fnInitImages(ImageFolder, Im, TargetCol, BackgCol, window);

%% Timing information
ifi = Screen('GetFlipInterval', window);
waitFrames = 1;

% Divide the horizontal length into equal intervals.
% In each interval the speed is specified in SpeedArray. (each row represents
% one trial)
[numTrials, numIntervals] = size(SpeedArray);
PositionArray = 0 : screenXpixels/numIntervals : screenXpixels;

%% Experimental loop
Priority(topPriorityLevel);

for trial = 1:numTrials
        % If this is the first trial we present a start screen and wait for
        % a key press
                
        if trial == 1
                DrawFormattedText(window, 'Press Any Key To Begin', ...
                        'center', 'center', [255 255 255]);
                Screen('Flip', window);
                KbStrokeWait;
        end
        
        % Break the cycle if key is pressed.
        if KbCheck
              break;  
        end
        
        %% Draw initial blank screen and flash
        vbl = fndrawflash(window,xCenter,yCenter,flashimage,blankTime,flashTime,BackgCol);
        
        %% Initialize the position and select a texture to show
        [ImxCenter, FrameCount, soundplayed, JuiceGiven, FPCount, TimeJuiceGiven,...
                ResetGiven, index, PictureTypeList, ShownTexture] = ...
                fnInitTrial(num_mice,PictureTypeList,TextureList,Im);      
        
        %% Main loop
        while ImxCenter < screenXpixels && ~KbCheck
                %% Draw Stimulus on the screen
                %Construct the rectangle containing the image, then draw the image
                imageRect = fnScaleImage(s1,s2,ScaleFactor,...
                        [ImxCenter yCenter],screenYpixels);
                Screen('DrawTexture', window, ShownTexture, [], imageRect);
                
                %Draw the frame. Frame changes color when the image is inside.
                if imageRect(1) > xCenter-TargetPosRange && ...
                                imageRect(3) < xCenter+TargetPosRange
                        Screen('FrameRect',window, Box2Col, [xCenter-TargetPosRange yCenter-BoxHeight xCenter+TargetPosRange yCenter+BoxHeight],BoxWidth);
                else
                        Screen('FrameRect',window, Box1Col, [xCenter-TargetPosRange yCenter-BoxHeight xCenter+TargetPosRange yCenter+BoxHeight],BoxWidth);
                end
                
                %Draw the cross
                if UseCross
                        fnDrawFixationCross(FixationCrossSize,window,windowRect,CrossLineWidth);
                end
                
%                 %% Play sound
%                 %Code copied from Kofiko's MouseWheelDrawCycleNew
%                 if imageRect(1) > xCenter-TargetPosRange && soundplayed == 0 && ...
%                                 playsound && Im(index).val == 1
%                         PsychPortAudio('Start',Handle,1,0,0); 
%                         soundplayed = 1;
%                 end
                                
                %% Reward + Keep track of statistics  8/26/14
                
                %OutputDecisionList is 1 when the mouse makes a correct lick
                OutputDecisionList = imageRect(1)> xCenter-TargetPosRange & ...
                        imageRect(3)< xCenter+TargetPosRange &...
                        JuiceGiven == 0 & DAQstruct.LickedList == 1 & Im(index).val == 1;
                
                                
                %FalsePosList is 1 when the mouse makes a wrong lick.
                FalsePosList = imageRect(1)> xCenter-TargetPosRange & ...
                        imageRect(3)< xCenter+TargetPosRange &...
                        FPCount == 0 & JuiceGiven == 0 & DAQstruct.LickedList == 1 & Im(index).val ~= 1;
                
                        
                % If a juice is detected...
                if sum(OutputDecisionList) ~= 0
                        
                        % Update the new port state
                        MainStruct.CurrentPortState = ...
                                MainStruct.CurrentPortState + OutputDecisionList;
                        
                        StopTimes = StopTimes + OutputDecisionList;
                                             
                        if ImmediateReset 
                                % Direct the output ports
                                OutputSession.outputSingleScan(MainStruct.CurrentPortState);
                                disp('Reward given. Current state is ');
                                disp(MainStruct.CurrentPortState);
                                
                                % Close port immediately
                                MainStruct.CurrentPortState = ...
                                        MainStruct.CurrentPortState - OutputDecisionList;
                                OutputSession.outputSingleScan(MainStruct.CurrentPortState);
                                disp('Reset made. Current state is ');
                                disp(MainStruct.CurrentPortState);
                                
                        end
                        
                        %Print out a statement
                        arrayfun(@(x) fprintf('Mouse %d gets reward!\n',x),...
                                find(OutputDecisionList==1));
                        
                        %Change the JuiceGiven
                        JuiceGiven = JuiceGiven + OutputDecisionList;
                        TimeJuiceGiven = TimeJuiceGiven + OutputDecisionList * GetSecs();
                end
                
                % Update FalsePosList statistics if juice not given                
                if sum(FalsePosList) ~= 0
                        FalsePos = FalsePos + FalsePosList;
                        FPCount = FPCount + FalsePosList;
                end
                
                if ~ImmediateReset
                        % Used when we want the port to open for longer...
                        
                        % Should reset detects whether a port should be reset to 0.
                        ShouldReset = TimeJuiceGiven ~= 0 & GetSecs()-TimeJuiceGiven > JuiceTime & ResetGiven == 0;
                        
                        % After JuiceTime, reset port to 0...
                        if sum(ShouldReset) ~= 0
                                %Update new port state
                                MainStruct.CurrentPortState = MainStruct.CurrentPortState - ShouldReset;
                                
                                %Direct the output ports
                                OutputSession.outputSingleScan(MainStruct.CurrentPortState);
                                
                                
                                
                                %Change 'ResetGiven'
                                ResetGiven = ResetGiven + ShouldReset;
                                
                                %Print out a statement
                                arrayfun(@(x) fprintf('Resetting port %d.\n',x),...
                                        find(ShouldReset == 1));
                        end
                end
                
                %% Flip and Update Position
                vbl = Screen('Flip',window,vbl + (waitFrames-0.5)*ifi,0,1);
                         
                %Find the corresponding speed and update center accordingly
                [ImxCenter, FrameCount] = fnUpdatePosition(PositionArray,...
                        ImxCenter,SpeedArray,trial,ifi,screenXpixels,numIntervals,FrameCount, NumFramesWaitZeroSpeed);
                
        end
end
Priority(0);
%% Stop acquistion, clear screen, write log and exit.
RecSession.stop();
OutputSession.stop();

% Write trial summary into output files
sca;
disp('Writing logs...');
fnWriteLog(PictureTypeList,StopTimes,FalsePos,recports);
disp('Logs written!');
