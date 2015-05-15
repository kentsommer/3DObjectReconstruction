function R = quat2rot(X)
X=X/norm(X);
a=X(4);
b=X(1);
c=X(2);
d=X(3);

R = -[a^2+b^2-c^2-d^2 2*b*c-2*a*d 2*a*c+2*b*d;
2*a*d+2*b*c a^2-b^2+c^2-d^2 2*c*d-2*a*b;
2*b*d-2*a*c 2*a*b+2*c*d a^2-b^2-c^2+d^2];

