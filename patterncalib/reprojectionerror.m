function r = reprojectionerror(K,R,T,matches,pts2d,pts3d)
% r = reprojectionerror(K,R,T,matches,pts2d,pts3d)
a = matches(:,1);
b = matches(:,2);
XY1=pts2d(a,:);
XY2=([1 0 0;0 1 0]*K*[R T]*[pts3d(b,:) ones(length(b),1)]')' ./ ([0 0 1;0 0 1]*K*[R T]*[pts3d(b,:) ones(length(b),1)]')';
% r = sum(sum((XY1-XY2).^2,2));
r = sum((XY1-XY2).^2,2);