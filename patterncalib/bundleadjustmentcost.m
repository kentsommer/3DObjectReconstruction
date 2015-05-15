function r = bundleadjustmentcost(X,Nimages,Npts,matches,pts2d)
[K,Q,T,pts3d] = unpackcalibration(X,Nimages,Npts);
r = multireprojectionerror(K,Q,T,matches,pts2d,pts3d);