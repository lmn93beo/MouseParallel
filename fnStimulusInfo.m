function [ScaleFactor, TargetPosRange, FixationCrossSize, UseCross, CrossLineWidth,...
        BackgCol, TargetCol, Box1Col, Box2Col, BoxHeight, BoxWidth, ...
        NumFramesWaitZeroSpeed, SpeedArray, blankTime, flashTime, flashimage] = fnStimulusInfo

ScaleFactor = 0.5 ; %How big the image is relative to the full screen height
TargetPosRange = 500; %Size of target box(from center-range to center+range)
FixationCrossSize = 40;
UseCross=0;
CrossLineWidth=8;
BackgCol=[127 127 127];
TargetCol=[0 0 0];
Box1Col=[40 40 40];
Box2Col=[200 200 200];
BoxHeight=350;
BoxWidth=30;
NumFramesWaitZeroSpeed = 100;

SpeedArray = repmat([200 200 200 200 200  200 200 200 200 200],[300 1]);

blankTime = 1;
flashTime = 0.8;
flashimage = 'flash.bmp';

end