function plotData(src,event)

global all_scans all_TimeStamps DAQstruct MainStruct
global LickLog

all_scans = [all_scans;event.Data];
all_TimeStamps = [all_TimeStamps;event.TimeStamps];

maxReadings = max(event.Data);

%disp('LickedList: ');
%disp(LickedList);
DAQstruct.LickedList = maxReadings > 0.2;
if sum(DAQstruct.LickedList) ~= 0
        miceLicked = find(DAQstruct.LickedList==1);
        for i = 1:numel(miceLicked)
                LickLog(miceLicked(i)).licks = [LickLog(miceLicked(i)).licks ...
                        GetSecs() - MainStruct.InitTime];
        end
                 
        disp('Yup!');
        MainStruct.numLicks = MainStruct.numLicks + DAQstruct.LickedList;
end

%fprintf('%f: Acquired %d scans...\n',GetSecs()-MainStruct.InitTime,size(event.TimeStamps,1));
plot(all_TimeStamps,all_scans);
leg = legend('ai0','ai1','ai2','ai3');


end