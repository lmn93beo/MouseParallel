function [RecSession, OutputSession] = InitDAQ(recports,outputports)

global MainStruct DAQstruct
global LickLog

DAQstruct.LickedList = [0 0 0 0];
MainStruct.numLicks = [0 0 0 0];

disp('Getting devices...');
daq.getDevices();

% Create two sessions - one for continuous background recording and
% one for output and then set parameters for each of them.
RecSession = daq.createSession('ni');
RecSession.Rate = 10; %rate of sampling per second
OutputSession = daq.createSession('ni');

%Add channels
disp('Adding channels...');
RecSession.addAnalogInputChannel('Dev1',recports,'Voltage');
OutputSession.addDigitalChannel('Dev2',outputports,'OutputOnly');

%Initialize port statesstop to be all 0.
OutputSession.outputSingleScan([0 0 0 0]);
MainStruct.CurrentPortState = [0 0 0 0];

%Add listener for background listening
lh = RecSession.addlistener('DataAvailable', @plotData);
RecSession.NotifyWhenDataAvailableExceeds = 5;

% RecSession will run forever until it is told to stop
RecSession.IsContinuous = true;

% Start the acquisition
disp('Starting background acquisition...');
RecSession.startBackground();
MainStruct.InitTime = GetSecs();

% Initiate LickLog - struct which records time of licks
LickLog = struct();
LickLog(numel(MainStruct.numLicks)).licks = [];

end