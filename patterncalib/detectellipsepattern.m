function [H, pts2d, matches] = detectellipsepattern(img_fname,EDGETHRESH,draw,thresh_wide,thresh_tight)
pattern_fname = 'pattern.txt';
R=0.092;
centers = load(pattern_fname);
if nargin<3
    draw=1;
end;
if nargin<2
    EDGETHRESH=50;
end;

[ellipses,area,imsize] = detectellipses(img_fname, EDGETHRESH);
if length(ellipses)<10
    H=-1;pts2d=-1;matches=-1;
    return;
end

C={};
Ci={};
for k=1:length(ellipses)
    C{k} = ellipse2conic(ellipses(k,:));
    Ci{k} = C{k}^-1;
end


D = zeros(size(ellipses,1),size(ellipses,1));
for i=1:size(ellipses,1)
    for j=1:size(ellipses,1)
        M = Ci{i}*C{j};
        d =det(M);
        d =sign(d)*abs(d)^(1/3);
        MM = M/d;
        D(i,j) = sqrt(abs(3-trace(MM)));
    end;
end;

%%
xy = centers(:,1:2);
Dp = sum(xy.*xy,2)*ones(1,size(xy,1))+ones(size(xy,1),1)*sum(xy.*xy,2)'-2*xy*xy';
Dp = sqrt(Dp)/R;

%%
best_matches=[];

c=5;

[m,idx]=sort(D,2,'ascend');idx1=idx;
d1=D(sub2ind(size(D),(1:size(D,1))',idx(:,2)));
d2=D(sub2ind(size(D),(1:size(D,1))',idx(:,3)));
d3=D(sub2ind(size(D),(1:size(D,1))',idx(:,4)));
d12=D(sub2ind(size(D),idx(:,2),idx(:,3)));
d13=D(sub2ind(size(D),idx(:,2),idx(:,4)));
d23=D(sub2ind(size(D),idx(:,3),idx(:,4)));
t12 = (d1.^2+d2.^2-d12.^2)./(2*d1.*d2);
t13 = (d1.^2+d3.^2-d13.^2)./(2*d1.*d3);
t23 = (d2.^2+d3.^2-d23.^2)./(2*d2.*d3);
T = [t12 t23 t13] ./(sqrt(t12.^2+t13.^2+t23.^2)*[1 1 1]);


[m,idx]=sort(Dp,2,'ascend');idx2=idx;
d1=Dp(sub2ind(size(Dp),(1:size(Dp,1))',idx(:,2)));
d2=Dp(sub2ind(size(Dp),(1:size(Dp,1))',idx(:,3)));
d3=Dp(sub2ind(size(Dp),(1:size(Dp,1))',idx(:,4)));
d12=Dp(sub2ind(size(Dp),idx(:,2),idx(:,3)));
d13=Dp(sub2ind(size(Dp),idx(:,2),idx(:,4)));
d23=Dp(sub2ind(size(Dp),idx(:,3),idx(:,4)));
t12 = (d1.^2+d2.^2-d12.^2)./(2*d1.*d2);
t13 = (d1.^2+d3.^2-d13.^2)./(2*d1.*d3);
t23 = (d2.^2+d3.^2-d23.^2)./(2*d2.*d3);
Tp = [t12 t23 t13] ./(sqrt(t12.^2+t13.^2+t23.^2)*[1 1 1]);

M = Tp*T';
[m,idx]=sort(M(:),'descend');
[i_c,i_e]=ind2sub(size(M),idx(1:50));

% H = estimateHomographyRANSAC(centers(i_c,1),centers(i_c,2),ellipses(i_e,1),ellipses(i_e,2),0.10,5);

thresh = sqrt(median(area)/pi)*thresh_wide;
for i=1:length(i_e)
    H = estimateHomography(centers(idx2(i_c(i),1:c),1),centers(idx2(i_c(i),1:c),2),ellipses(idx1(i_e(i),1:c),1),ellipses(idx1(i_e(i),1:c),2));
    matches = testHomography(H, centers(:,1), centers(:,2),ellipses(:,1),ellipses(:,2),thresh);
    if size(matches,1)>size(best_matches,1);
        best_matches = matches;
        size(best_matches,1);
        if size(best_matches,1)==64
            break;
        end;
    end;    
end;
H = estimateHomography(centers(best_matches(:,2),1), centers(best_matches(:,2),2),ellipses(best_matches(:,1),1),ellipses(best_matches(:,1),2));

thresh = sqrt(median(area(best_matches(:,1)))/pi)*thresh_tight;
% thresh = sqrt(mean(area)/pi)/10;

for m=1:5
    matches = testHomography(H, centers(:,1), centers(:,2),ellipses(:,1),ellipses(:,2),thresh);
    H = estimateHomography(centers(matches(:,2),1), centers(matches(:,2),2),ellipses(matches(:,1),1),ellipses(matches(:,1),2));
%     thresh = sqrt(mean(area(matches(:,1)))/pi)/10;
end

disp(sprintf('Final matches = %d\n', length(matches)));


xy = centers(matches(:,2),1:2);
XY = ellipses(matches(:,1),1:2);

H = estimateHomography(xy(:,1),xy(:,2),XY(:,1),XY(:,2));

pts2d = ellipses(:,1:2);

if draw 
    for i=1:size(ellipses,1);
        drawellip_std(ellipses(i,:),'r-',1);
        a = ellipses(i,1:2);
        plot(a(1),a(2),'wo');
    end;

    for i=1:size(centers,1);
        a = centers(i,1:2);
        a = H*[a(:);1];
        a = a(1:2)/a(3);
        plot(a(1),a(2),'w+');
        if ismember(i,matches(:,2))
            text(a(1),a(2),sprintf('%d',i),'Color','green');
        else
            text(a(1),a(2),sprintf('%d',i),'Color','red');
        end;
    end
end;