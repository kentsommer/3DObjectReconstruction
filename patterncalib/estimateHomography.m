function H = estimateHomography(u1, v1, u2, v2);
e=ones(size(u1));
z=zeros(size(u1));

M=[u1 v1 e z z z -u1.*u2 -v1.*u2 -u2
   z z z u1 v1 e -u1.*v2 -v1.*v2 -v2];
[U,S,V] = svd(M);
h = V(:,size(V,2));
H = reshape(h, [3,3])';