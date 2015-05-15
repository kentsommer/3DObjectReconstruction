function [K, R, T] = decompose_projection(P)
% Performs QR decomposition to get the camera intrinsics and extrinsics
% from a given projection matrix. 

% Follows QR algorithm outline described in this paper: 
% http://www.daesik80.com/sn/2006-SN-003-EN_Camera%20Calibration.pdf

% Get QR decomposition values from first 3,3 of P (M).
[q,r] = qr(inv(P(1:3,1:3)));

% Get inverse of K and correct R.
k_inv = r(1:3,1:3);
R = inv(q);

% Fix signs if necessary
if(det(R) < 0)
    R = -R;
    k_inv = -k_inv;
end

K = inv(k_inv);
T = k_inv*P(:,4);

end

