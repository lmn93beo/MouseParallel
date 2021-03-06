function [ImxCenter, FrameCount] = fnUpdatePosition(PositionArray,...
ImxCenter,SpeedArray,trial,ifi,screenXpixels,numIntervals,FrameCount, NumFramesWaitZeroSpeed)

global MainStruct

% Static mode:
if SpeedArray == 0
      if ImxCenter == -2000 && GetSecs() - MainStruct.init_time > 1
              ImxCenter = screenXpixels/2;
      elseif ImxCenter == screenXpixels/2 && GetSecs() -MainStruct.init_time > 3
              ImxCenter = 2000;
      end
                      

        
else % Moving mode
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


end