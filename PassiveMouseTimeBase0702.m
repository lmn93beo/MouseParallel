%% Clear the workspace
close all; 
clear all;

global DAQstruct

%% Initialize DAQ Devices
DAQstruct.LickedList = [0 0 0 0]; 

disp('Getting devices...');
daq.getDevices();

% Create two sessions - one for continuous background recording and 
% one for output and then set parameters for each of them.
RecSession = daq.createSession('ni');
RecSession.Rate = 2000; %rate of sampling per second
OutputSession = daq.createSession('ni');

%Add channels
disp('Adding channels...');
RecSession.addAnalogInputChannel('Dev2',{'ai0','ai1','ai2','ai3'},'Voltage');
OutputSession.addDigitalChannel('Dev1',['port0/line0','port0/line1',...
      'port0/line2','port0/line3'],'OutputOnly');



%Add listener
lh = RecSession.addlistener('DataAvailable', @plotData);
RecSession.NotifyWhenDataAvailableExceeds = 2000;

% s will run forever until it is told to stop
RecSession.IsContinuous = true;

% Start the acquisition
disp('Starting background acquisition...');
RecSession.startBackground();

%% Set image info

ImageFolder = uigetdir(pwd);

% Image struct array - contains image name and value
% values 1= target or right; 0 = neutral or no reward; -1= punish stop or left

Im(1).name='H.bmp';
Im(1).val=1;
Im(2).name='Hor.bmp';
Im(2).val=1;
Im(3).name='Vert.bmp';
Im(3).val=1;

Im(4).name='X.bmp';
Im(4).val=-1;
Im(5).name='Diag1.bmp';
Im(5).val=-1;
Im(6).name='Diag2.bmp';
Im(6).val=-1;

Im(7).name='O.bmp';
Im(7).val=0;
Im(8).name='OInvert.bmp';
Im(8).val=0;
Im(9).name='Black.bmp';
Im(9).val=0;
Im(10).name='White.bmp';
Im(10).val=0;



%% Initialize and open screen

%Screen('Preference', 'SkipSyncTests', 1 );

screens = Screen('Screens');
screenNumber = 0;


%% Stimulus information

ScaleFactor = 0.5 ; %How big the image is relative to the full screen height
TargetPosRange = 500; %Size of target box(from center-range to center+range)
FixationCrossSize = 40;
UseCross=0;
CrossLineWidth=8;
BackgCol=[127 127 127];
TargetCol=[0 0 0];
Box1Col=[40 40 40];
Box2Col=[200 200 200];
BoxHeight=350;
BoxWidth=30;
NumFramesWaitZeroSpeed = 100;

%Juice information
JuiceTime = 3;


% Window-relevant parameters
[window, windowRect] = Screen('OpenWindow', screenNumber, BackgCol);

%Get relevant screen parameters:
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

% Set the priority level that will be called
topPriorityLevel = MaxPriority(window);



%% Initialize images

NF = size(Im,2);
ImageList = cell(NF,1);
TextureList = cell(NF,1);
for k = 1 : NF
      X= double(imread(fullfile(ImageFolder, Im(k).name))/255);
      Z(:,:,1) = X(:,:,1)*(TargetCol(1)-BackgCol(1))+BackgCol(1);
      Z(:,:,2) = X(:,:,2)*(TargetCol(2)-BackgCol(2))+BackgCol(2);
      Z(:,:,3) = X(:,:,3)*(TargetCol(3)-BackgCol(3))+BackgCol(3);
      ImageList{k} = Z;
      TextureList{k} = Screen('MakeTexture',window,ImageList{k});
      clear Z;
end
[s1, s2, s3] = size(ImageList{1});

%% Timing information
ifi = Screen('GetFlipInterval', window);
waitFrames = 1;

% Divide the horizontal length into equal intervals.
% In each interval the speed is specified in SpeedArray. (each row represents
% one trial)


screenXpixels;
MoveArrayCluster=9;

SpeedArray = [200 100 200 100 200  0 200 100 200 100;
      400 0 0 100 0 100 400 100 0 100];

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
            vbl = Screen('Flip', window);
            KbStrokeWait;
      end
      
      % Initialize the position and select a texture to show
      ImxCenter = 0;
      FrameCount = 0;
      JuiceGiven = [0 0 0 0]; %Indicates whether juice has been given for the trial.
      TimeJuiceGiven = [0 0 0 0]; %Time that the juice was given. 0 means not given
      ResetGiven = [0 0 0 0];
      index = round(rand)+1;
      ShownTexture = TextureList{index};
      
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
            
            %% Reward!
            
            % Construct a list of 0 and 1 which indicates whether the juice
            % should be given for each port
            OutputDecisionList = imageRect(1)> xCenter-TargetPosRange & ...
                  JuiceGiven == 0 & DAQstruct.LickedList == 1;
            
            %When mouse licks & stimulus is in, set port to 1.            
            if sum(OutputDecisionList) ~= 0
%                   disp(OutputDecisionList);
                  % Direct the output ports
                  OutputSession.outputSingleScan(OutputDecisionList);
                  
                  %Print out a statement
                  arrayfun(@(x) fprintf('Mouse %d gets reward!\n',x),...
                        find(OutputDecisionList==1));
                  
                  %Change the JuiceGiven
                  JuiceGiven = JuiceGiven + OutputDecisionList;
                  TimeJuiceGiven = TimeJuiceGiven + OutputDecisionList * GetSecs();    
                  
            end
            
            ShouldReset = TimeJuiceGiven ~= 0 & GetSecs()-TimeJuiceGiven > JuiceTime & ResetGiven == 0;
            
            
            % After 3 secs, reset port to 0. 
            if sum(ShouldReset) ~= 0
                  disp(ShouldReset);
                  OutputResetList = TimeJuiceGiven;
                  OutputResetList(OutputResetList ~= 0 & GetSecs()-TimeJuiceGiven <JuiceTime & ResetGiven==0) = 1;
                  OutputResetList(OutputResetList ~= 1) = 0;
                  OutputSession.outputSingleScan(OutputResetList);
                  ResetGiven = ResetGiven + ShouldReset;
                  
                  arrayfun(@(x) fprintf('Resetting port %d.\n',x),...
                         find(ShouldReset == 1));
                  
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

%% Stop acquistion, clear screen and exit.
RecSession.stop();
sca;
% close all;
% clear all;