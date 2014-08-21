function plotData(src,event)
global all_scans all_TimeStamps DAQstruct MainStruct

all_scans = [all_scans;event.Data];
all_TimeStamps = [all_TimeStamps;event.TimeStamps];

maxReadings = max(event.Data);

LickedList = maxReadings>0.07;
disp('LickedList: ');
disp(LickedList);
DAQstruct.LickedList = LickedList;

fprintf('%f: Acquired %d scans...\n',GetSecs()-MainStruct.InitTime,size(event.TimeStamps,1));%datestr(now)
plot(all_TimeStamps,all_scans);
leg = legend('ai0','ai1','ai2','ai3');


end