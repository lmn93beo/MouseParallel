%% Notes
%Right ports are for targets
%Left ports are for non-targets.

%% Clear the workspace
close all;
clear all;
addpath(genpath('.\'));

global MainStruct DAQstruct LickLog


%% Initialize DAQ Devices
recports = {'ai0','ai1','ai2','ai3'};
outputports = {'port0/line0','port0/line2','port0/line1','port0/line3'};
targetports = [1 1 0 0]; %Assign which port is target/distractor
distractorports = 1 - targetports;
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
        ImxCenter = 0;
        FrameCount = 0;
        soundplayed = 0; %Makes sure that the sound is played once.
        JuiceGiven = zeros(1,num_mice); %Indicates whether juice has been given for the trial.
             
        % FPCount counts how many licks on distractors in a trial (similar
        % to JuiceGiven). Count as a false positive only when FPCount = 0.
        FPCount = zeros(1,num_mice);
        
        
        TimeJuiceGiven = zeros(1,num_mice); %Time that the juice was given. 0 means not given
        ResetGiven = zeros(1,num_mice);
        index = round(rand*4);
        PictureTypeList = [PictureTypeList Im(index).val];
        ShownTexture = TextureList{index};
        
        
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
                
                %OutputDecisionList is 1 when the mouse licks right on
                %target
                OutputDecisionList = imageRect(1)> xCenter-TargetPosRange & ...
                        imageRect(3)< xCenter+TargetPosRange & targetports &...
                        JuiceGiven == 0 & DAQstruct.LickedList == 1 & Im(index).val == 1;
                
                %OutputDecisionList2 is 1 when the mouse licks left on non-target 
                OutputDecisionList2 = imageRect(1)> xCenter-TargetPosRange & ...
                        imageRect(3)< xCenter+TargetPosRange & distractorports &...
                        JuiceGiven == 0 & DAQstruct.LickedList == 1 & Im(index).val ~= 1;
                
                                
                %FalsePosList is 1 when the mouse licks left on target.
                FalsePosList = imageRect(1)> xCenter-TargetPosRange & ...
                        imageRect(3)< xCenter+TargetPosRange & distractorports &...
                        FPCount == 0 & DAQstruct.LickedList == 1 & Im(index).val == 1;
                
                %FalsePosList2 is 1 when the mouse licks right on non-target.
                FalsePosList2 = imageRect(1)> xCenter-TargetPosRange & ...
                        imageRect(3)< xCenter+TargetPosRange & targetports &...
                        FPCount == 0 & DAQstruct.LickedList == 1 & Im(index).val ~= 1;
                
                        
                % If mouse licks on the correct port
                if sum(OutputDecisionList) ~= 0 || sum(OutputDecisionList2) ~= 0
%                         disp('OutputDecisionList is ')
%                         disp(OutputDecisionList)
%                         disp('OutputDecisionList2 is ')
%                         disp(OutputDecisionList2),
                        % Update the new port state
                        MainStruct.CurrentPortState = ...
                                MainStruct.CurrentPortState + max(OutputDecisionList,OutputDecisionList2);
                        
                        StopTimes = StopTimes + max(OutputDecisionList,OutputDecisionList2);
                                             
                        if ImmediateReset 
                                % Direct the output ports
                                OutputSession.outputSingleScan(MainStruct.CurrentPortState);
                                disp('Reward given. Current state is ');
                                disp(MainStruct.CurrentPortState);
                                
                                % Close port immediately
                                MainStruct.CurrentPortState = ...
                                        MainStruct.CurrentPortState - max(OutputDecisionList,OutputDecisionList2);
                                OutputSession.outputSingleScan(MainStruct.CurrentPortState);
                                disp('Reset made. Current state is ');
                                disp(MainStruct.CurrentPortState);
                                
                        end
                        
                        %Print out a statement
                        arrayfun(@(x) fprintf('Mouse %d gets reward!\n',x),...
                                find(OutputDecisionList==1));
                        
                        %Change the JuiceGiven
                        JuiceGiven = JuiceGiven + max(OutputDecisionList,OutputDecisionList2);
                        TimeJuiceGiven = TimeJuiceGiven + OutputDecisionList * GetSecs();
                end
                
                % If mouse licks on incorrect port           
                if sum(FalsePosList) ~= 0 || sum(FalsePosList2) ~= 0
                        %Still give juice?
%                         disp('FalsePosList: ')
%                         disp(FalsePosList)
%                         disp('FalsePosList2: ')
%                         disp(FalsePosList2)
                        
                        disp('Wrong lick!');
                        FalsePos = FalsePos + max(FalsePosList,FalsePosList2);
                        FPCount = FPCount + max(FalsePosList,FalsePosList2);
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
                
                %% Flip
                vbl = Screen('Flip',window,vbl + (waitFrames-0.5)*ifi,0,1);
                %vbl = Screen('AsyncFlipBegin',window,vbl + (waitFrames-0.5)*ifi,0,1);
                %         vbl = Screen('Flip',window,0,0,1,0);
                
                %% Update position
                %Find the corresponding speed and update center accordingly
                [m, n] = size(find(PositionArray <= ImxCenter));
                
                if SpeedArray(trial,n) == 0
                        FrameCount = FrameCount + 1;
                end
                
                if FrameCount == NumFramesWaitZeroSpeed;
                        ImxCenter = ImxCenter + screenXpixels/numIntervals;
                        FrameCount = 0;
                end
                
                ImxCenter = ImxCenter + ifi*SpeedArray(trial,n);
                
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
