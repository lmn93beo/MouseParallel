function [ImxCenter, FrameCount] = fnUpdatePosition(PositionArray,...
ImxCenter,SpeedArray,trial,ifi,screenXpixels,numIntervals,FrameCount, NumFramesWaitZeroSpeed)

%Find the corresponding speed and update center accordingly
[~, n] = size(find(PositionArray <= ImxCenter));

if SpeedArray(trial,n) == 0
        FrameCount = FrameCount + 1;
end

if FrameCount == NumFramesWaitZeroSpeed;
        ImxCenter = ImxCenter + screenXpixels/numIntervals;
        FrameCount = 0;
end

ImxCenter = ImxCenter + ifi*SpeedArray(trial,n);
end