function fnWriteLog(PictureTypeList,StopTimes,FalsePos,recports)
global all_scans all_TimeStamps
global LickLog

%% Calculate statistics of missed and Correct Rejection
Missed = sum(PictureTypeList==1) - StopTimes;
CorrectRejection = sum(PictureTypeList~=1) - FalsePos;
numtrials = numel(PictureTypeList);

%% Write
currenttime = datestr(clock(),'mmdd-HHMM');
filename = sprintf('.\\Logs\\%s.txt',currenttime);
file = fopen(filename,'at');

disp('Summary for this run:');
fprintf('Number of trials = %d. \n',numtrials);
fprintf(file,'Mouse,Rewards,False.Positives,Misses,Correct.Rejections,Lick.Times\n');
for i= 1:4
        % Other statistics added CT 8/26/14         
        fprintf(file,'%i,%i,%i,%i,%i,',...
                i, StopTimes(i), FalsePos(i), Missed(i), CorrectRejection(i));
        
        fprintf(file, '%s\n', list2string(LickLog(i).licks, ','));
        
        fprintf('Mouse %i got %i rewards, %i false positives, %i misses, %i correct rejection \n',...
                i, StopTimes(i), FalsePos(i), Missed(i), CorrectRejection(i));
end
fclose(file);


% Write recordings summary to output file
filename = sprintf('.\\ScanHistory\\%s.txt',currenttime);
file = fopen(filename,'at');
fprintf(file, 'Time,');
for i = 1:numel(recports)
        fprintf(file,'%s,',recports{i});
end

fprintf(file,'\n');

for i = 1:numel(all_TimeStamps)
        fprintf(file,'%d,',all_TimeStamps(i));
        for j = 1:numel(recports)
                fprintf(file, '%d,',all_scans(i,j));
        end
        fprintf(file,'\n');
end

fclose(file);
%clear all;

end