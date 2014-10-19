function [ImxCenter, FrameCount, soundplayed, JuiceGiven, FPCount, TimeJuiceGiven,...
         ResetGiven, index, PictureTypeList, ShownTexture] = fnInitTrial(num_mice,PictureTypeList,TextureList,Im)

ImxCenter = 0;
FrameCount = 0;
soundplayed = 0; %Makes sure that the sound is played once.
JuiceGiven = zeros(1,num_mice); %Indicates whether juice has been given for the trial.

% FPCount counts how many licks on distractors in a trial (similar
% to JuiceGiven). Count as a false positive only when FPCount = 0.
FPCount = zeros(1,num_mice);

TimeJuiceGiven = zeros(1,num_mice); %Time that the juice was given. 0 means not given
ResetGiven = zeros(1,num_mice);
index = round(rand*4)+1;
PictureTypeList = [PictureTypeList Im(index).val];
ShownTexture = TextureList{index};