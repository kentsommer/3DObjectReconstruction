function a = conic2ellipse(C)
C= -C/(det(C)/det(C(1:2,1:2)));
[V,D] = eig(C(1:2,1:2));
if det(V) <0
    V = [V(:,2) V(:,1)];
    D = diag([D(2,2),D(1,1)]);
end;
theta = atan2(-V(1,2),V(1,1));
%theta = atan(-V(1,2)/V(1,1));
xy0 = -C(1:2,1:2)^-1*C(1:2,3);
D = sqrt(D);
a = [xy0' 1./diag(D)' theta]';