function [StopTimes, FalsePos, PictureTypeList] = fnInitLog(num_mice)

%Keeps track of number of stop times for each mouse
StopTimes = zeros(1,num_mice); 

% Keep track of other performance statistics CT 8/26/14
FalsePos = zeros(1,num_mice); % Lick but not target

%Stores all the values of all trials. 1 for target, 0 and -1 for
%distractors. For example: [1 1 0 0 -1] indicates 5 trials, first 2 trials
%show targets...
PictureTypeList = [];