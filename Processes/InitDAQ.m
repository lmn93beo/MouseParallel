function [RecSession, OutputSession, PunishSession] = InitDAQ(recports,juiceports,punishports)

global MainStruct DAQstruct
global LickLog

num_mice = length(recports);
DAQstruct.LickedList = zeros(1,num_mice);
MainStruct.numLicks = zeros(1,num_mice);

disp('Getting devices...');
daq.getDevices();

% Create two sessions - one for continuous background recording and
% one for output and then set parameters for each of them.
RecSession = daq.createSession('ni');
RecSession.Rate = 10; %rate of sampling per second
OutputSession = daq.createSession('ni');
PunishSession = daq.createSession('ni');

%Add channels
disp('Adding channels...');
RecSession.addAnalogInputChannel('Dev1',recports,'Voltage');
OutputSession.addDigitalChannel('Dev2',juiceports,'OutputOnly');
PunishSession.addDigitalChannel('Dev2',punishports,'OutputOnly');

%Initialize port states to be all 0.
OutputSession.outputSingleScan(zeros(1,num_mice));
MainStruct.CurrentPortState = zeros(1,num_mice);
PunishSession.outputSingleScan(zeros(1,num_mice));
MainStruct.CurrentPunishState = zeros(1,num_mice);

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