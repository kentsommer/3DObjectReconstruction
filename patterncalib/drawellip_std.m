function drawellip_std(a,mark,th)
if nargin<3
    th=1;
end;
if nargin<2
    mark = 'r-';
end;
N=100;
t = 0:(2*pi/N):(2*pi-2*pi/N);
U = [cos(t);sin(t)]';

R = [cos(a(5)) sin(a(5));-sin(a(5)) cos(a(5))];
XX=U*diag(a(3:4))*R + ones(N,1)*a(1:2);
plot(XX(:,1),XX(:,2),mark,'linewidth',th);
