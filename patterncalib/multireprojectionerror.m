function r = multireprojectionerror(K,Q,T,matches,pts2d,pts3d)
% Q=mat2cell(Q,4,ones(1,size(Q,2)));
% T=mat2cell(T,3,ones(1,size(T,2)));
% r = sum(cellfun(@(Q,T,matches,pts2d) reprojectionerror(K,quat2rot(Q),T,matches,pts2d,pts3d), Q,T,matches,pts2d));
qq=cellfun(@(Q,T,matches,pts2d) reprojectionerror(K,quat2rot(Q),T,matches,pts2d,pts3d), Q,T,matches,pts2d, 'UniformOutput',0);
r = cell2mat(qq(:));