function [TextureList, s1, s2] = fnInitImages(ImageFolder, Im, TargetCol, BackgCol, window)

NF = size(Im,2);
ImageList = cell(NF,1);
TextureList = cell(NF,1);
for k = 1 : NF
        X= double(imread(fullfile(ImageFolder, Im(k).name))/255);
        Z(:,:,1) = X(:,:,1)*(TargetCol(1)-BackgCol(1))+BackgCol(1);
        Z(:,:,2) = X(:,:,2)*(TargetCol(2)-BackgCol(2))+BackgCol(2);
        Z(:,:,3) = X(:,:,3)*(TargetCol(3)-BackgCol(3))+BackgCol(3);
        ImageList{k} = Z;
        TextureList{k} = Screen('MakeTexture',window,ImageList{k});
        clear Z;
end
[s1, s2, ~] = size(ImageList{1});