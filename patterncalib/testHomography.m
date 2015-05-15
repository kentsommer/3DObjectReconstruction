function match = testHomography(H, u1,v1,u2,v2,thresh)
%match = testHomography(H, u1,v1,u2,v2,thresh)

[U2,V2]=applyHomography(H,u1,v1);


% [idx1,d1]=dsearchn([u2 v2],[U2 V2]);
% [idx2,d2]=dsearchn([U2 V2],[u2 v2]);
% 
% b = (idx2(idx1)==(1:length(U2))' ) & (d1<thresh);
% 
% match = [find(b) idx1(b)];
% match = [match(:,2) match(:,1)];

xy=[u2,v2];
XY=[U2,V2];

d = sqrt(sum(xy.*xy,2)*ones(1,size(XY,1))+ones(size(xy,1),1)*sum(XY.*XY,2)'-2*xy*XY');
[m1,nearest1] = min(d,[],2);
[m2,nearest2] = min(d',[],2);

idx1 = find(nearest2(nearest1)==(1:length(nearest1))');
idx2 = nearest1(idx1);


b = d(sub2ind(size(d),idx1,idx2))<thresh;
idx1 = idx1(b);
idx2 = idx2(b);

match = [idx1 idx2];

function [U,V] = applyHomography(H, u, v);
M=H*[u(:)';v(:)';ones(size(u(:)'))];
U=M(1,:)./(M(3,:));
V=M(2,:)./(M(3,:));
U=reshape(U,size(u));
V=reshape(V,size(v));