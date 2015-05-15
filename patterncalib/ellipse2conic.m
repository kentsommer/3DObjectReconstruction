function C = ellipse2conic(a)
a=a(:);
R = [cos(a(5)) -sin(a(5));sin(a(5)) cos(a(5))];
M = R*diag(a(3:4).^(-2))*R';
m = a(1:2);
C = [M -M*m;-m'*M m'*M*m-1];