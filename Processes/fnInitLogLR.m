function [TrialOutcomes, PictureTypeList] = fnInitLogLR(num_mice,mouse_name_list)

%Trial Outcomes is a struct that has 1 entry for each mouse.
%In each entry, there is a record of: mouse name, outcome for each trial
%(outcome_list), lick times.
TrialOutcomes = struct();
for i = 1:num_mice/2
        TrialOutcomes(i).mouse_name = mouse_name_list(i); 
        TrialOutcomes(i).outcome_list = [];
        TrialOutcomes(i).lick_times = [];
end


%Stores all the values of all trials. 1 for target, 0 and -1 for
%distractors. For example: [1 1 0 0 -1] indicates 5 trials, first 2 trials
%show targets...
PictureTypeList = [];