function [ellipses,area,imsize] = detectellipses_v2(fname,THRESH)
% ellipses = detectellipses_v2(fname,THRESH)
if nargin<2
    THRESH = 50;
end

if size(fname,1)==1
    I = imread(fname);
    I = double(rgb2gray(I));
else
    I = fname;
end;
imsize = size(I);
MIN_ELLIP_SIZE = floor(prod(size(I))/80^2);
MAX_ELLIP_SIZE = floor(prod(size(I))/8^2);

[L,nlabels] = bwlabel(I<THRESH);
STATS = regionprops(L,'Area','Centroid','MajorAxisLength','MinorAxisLength','Orientation');

ellipses = [cell2mat({STATS.Area}') cell2mat({STATS.Centroid}') cell2mat({STATS.MajorAxisLength}')/2 cell2mat({STATS.MinorAxisLength}')/2 -cell2mat({STATS.Orientation}')*pi/180];

b = ellipses(:,1)>MIN_ELLIP_SIZE & ellipses(:,1)<MAX_ELLIP_SIZE & abs(log(ellipses(:,4))-log(ellipses(:,5)))<log(3);


ellipses = ellipses(b,:);
area = ellipses(:,1);
ellipses = ellipses(:,2:end);


% figure;imshow(uint8(I));hold;
% for k=1:size(ellipses,1)
%     drawellip_std(ellipses(k,:),'g-',3);
% end;