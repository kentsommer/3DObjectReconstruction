function [sil] = extract_Silhouette(fgIN, bgIN)
% Performs background subtraction given a pair of fg and bg images.

% Convert to grayscale and run a medfilt to remove some of the noise.
current_IM = im2double(rgb2gray(fgIN));
current_BG = im2double(rgb2gray(bgIN));
K1 = medfilt2(current_IM);
K2 = medfilt2(current_BG);
% Perform background subtraction.
out = abs(K2 - K1);

% Threshold value to help determine if a pixel is different enough to be
% considered part of the foreground
thresh = 0.2;

[row,col,depth] = size(out);
outsil = zeros(size(out,1), size(out,2));

% Remove pixels that have a absolute difference greater than the threshold
% value.
for i = 1:row
    for j = 1:col
        if(out(i,j,:) > thresh)
            outsil(i,j,:) = 1;
        end
    end
end

% Run another medfilter to remove noise (I found a 10,10 window was fast
% enough and removed any of the noise I had without loss of detail in the
% silhouette). 
K = medfilt2(outsil, [10 10]);
% Fill in any holes in the object silhouette. (Works well when removing
% noise given our specific object, however, if the object had holes in it
% this would cause a lot of issues and might need to be removed). 
sil = imfill(K,'holes');

end

