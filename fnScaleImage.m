function newrect = fnScaleImage(height,width,scalefactor,centerpos,ScreenYpixels)
%Given a rect, scale factor (fraction of the screen height),
%and center position, compute the new rect.

aspectRatio = height / width;

% We will set the height of each drawn image to a fraction of the screens
% height
imageHeight = ScreenYpixels * scalefactor;
imageWidth = imageHeight / aspectRatio;
scaledrect = [0 0 imageWidth imageHeight];

% Make the destination rectangles for our image. We will draw the image
% multiple times over getting smaller on each iteration. So we need the big
% dstRects first followed by the progressively smaller ones

newrect = CenterRectOnPointd(scaledrect, centerpos(1), centerpos(2));

end