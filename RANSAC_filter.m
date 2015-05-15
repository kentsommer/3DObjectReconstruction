function [in1, in2] = RANSAC_filter( P1, P2, n, thresh )
N = size(P1, 2);

in1 = [];
in2 = [];


for i = 1:n
    p1 = zeros(3, 4);
    p2 = zeros(3, 4);
    for j=1:4
        r = round(rand() * (N-1) + 1);
        p1(:, j) = P1(:, r);
        p2(:, j) = P2(:, r);
    end
    
    h = homography(p1,p2);
    
    c_inliers1 = [];
    c_inliers2 = [];
    for j=1:N
        p = h * P1(:, j);
        p = p / p(3);
        q = h \ P2(:, j);
        q = q / q(3);
        
        d = norm(P2(:, j) - p)^2 + norm(P1(:, j) - q)^2;
        
        if d < thresh 
            c_inliers1 = [c_inliers1, P1(:, j)];
            c_inliers2 = [c_inliers2, P2(:, j)];
        end
    end
    if size(c_inliers1, 2) > size(in1, 2)
        in1 = c_inliers1;
        in2 = c_inliers2;
    end
end

end

