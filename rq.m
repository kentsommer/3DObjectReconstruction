function [R,Q] = rq(P)
%% RQ decomposition based on Solem Janerik's RQ implementation in python
 % http://www.janeriksolem.net/2011/03/rq-factorization-of-camera-matrices.html

[Q,R] = qr(flipud(P)');
R = flipud(R');
R = fliplr(R);

Q = Q';   
Q = flipud(Q);

end

