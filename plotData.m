function plotData(src,event)
global all_scans all_TimeStamps

all_scans = [all_scans;event.Data];
all_TimeStamps = [all_TimeStamps;event.TimeStamps];

fprintf('%s: Acquired %d scans...\n',datestr(now),size(event.TimeStamps,1));
plot(all_TimeStamps,all_scans)

end