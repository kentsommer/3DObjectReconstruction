function [point_cloud] = getModelBB(xlim, ylim, zlim, num_points)
% Output should be a box given the input limits

% Get box
box = diff(xlim) * diff(ylim) * diff(zlim);
% Set resolution or step here. 1/3 seems to be giving the best results,
% however, there is not a lot of rational behind this number. More
% investigation should probably be done to see if this is truely the most
% effecient way to set the step. 
point_cloud.Step = (box/num_points)^(1/3);
% Get x,y,z data points.
x = xlim(1) : point_cloud.Step : xlim(2);
y = ylim(1) : point_cloud.Step : ylim(2);
z = zlim(1) : point_cloud.Step : zlim(2);

% Set to grid
[X,Y,Z] = meshgrid(x,y,z);
% Set pointcloud data points
point_cloud.XD = X(:);
point_cloud.YD = Y(:);
point_cloud.ZD = Z(:);
point_cloud.Val = ones(numel(X),1);
end

