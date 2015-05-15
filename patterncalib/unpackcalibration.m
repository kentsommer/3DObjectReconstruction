function [K,Q,T,pts3d] = unpackcalibration(X,Nimages,Npts)
% [K,Q,T,pts3d] = unpackcalibration(X,Nimages,Npts)
k = X(1:5);
q = X(length(k)+1:length(k)+4*Nimages);
t = X(length(k)+length(q)+1:length(k)+length(q)+3*Nimages);
p = X(length(k)+length(q)+length(t)+1:length(k)+length(q)+length(t)+3*Npts);

K=zeros(3,3);
K(1,1)=k(1);
K(2,2)=k(2);
K(1,2)=k(3);
K(1,3)=k(4);
K(2,3)=k(5);
K(3,3)=1;

q = reshape(q,[4,Nimages]);
t = reshape(t,[3,Nimages]);
Q = mat2cell(q,4,ones(1,Nimages));
T = mat2cell(t,3,ones(1,Nimages));
pts3d = reshape(p,[Npts,3]);