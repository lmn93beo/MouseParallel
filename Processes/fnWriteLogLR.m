function fnWriteLogLR(PictureTypeList,TrialOutcomes,recports)
global all_scans all_TimeStamps
global LickLog

%% Calculate statistics of missed and Correct Rejection
numtrials = numel(PictureTypeList);

%% Write
currenttime = datestr(clock(),'mmdd-HHMM');
filename = sprintf('.\\Logs\\LR%s.txt',currenttime);
file = fopen(filename,'at');

summary_struct = struct;
for i=1:length(TrialOutcomes)
        summary_struct(i).target_rewards = 0;
        summary_struct(i).distractor_rewards = 0;
end        


disp('Summary for this run:');
fprintf('Number of trials = %d. \n',numtrials);
fprintf(file,'Trial,PictureType,Mouse37,Mouse38\n'); %Need to add licktimes somewhere?...
for i= 1:numtrials
        % Other statistics added CT 8/26/14         
        fprintf(file,'%i,%i,%i,%i\n',i,PictureTypeList(i),TrialOutcomes(1).outcome_list(i),TrialOutcomes(2).outcome_list(i));
        for j=1:length(TrialOutcomes)
                if PictureTypeList(i) == 1 && TrialOutcomes(j).outcome_list(i) == 1
                        summary_struct(j).target_rewards = summary_struct(j).target_rewards + 1;
                elseif PictureTypeList(i) ~= 1 && TrialOutcomes(j).outcome_list(i) == 1
                        summary_struct(j).distractor_rewards = summary_struct(j).distractor_rewards + 1;
                end
        end
               
end
fclose(file);

for i=1:length(TrialOutcomes)
        fprintf('Mouse %i got %i rewards for targets and %i rewards for distractors\n',...
                TrialOutcomes(i).mouse_name, summary_struct(i).target_rewards,summary_struct(i).distractor_rewards);
end

% Write recordings summary to output file
filename = sprintf('.\\ScanHistory\\%s.csv',currenttime);
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