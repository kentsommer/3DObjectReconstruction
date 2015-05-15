function point_cloud_out = cut_from_silhouette(point_cloud, cam)

% Get all camera x,y indices by projecting all of the bounding box (or
% current point cloud points) into the image frame.
z = cam.P(3,1) * point_cloud.XD + ...
    cam.P(3,2) * point_cloud.YD + ...
    cam.P(3,3) * point_cloud.ZD + ...
    cam.P(3,4);
x = round((cam.P(1,1) * point_cloud.XD + ...
    cam.P(1,2) * point_cloud.YD + ...
    cam.P(1,3) * point_cloud.ZD + ...
    cam.P(1,4))./z);
y = round((cam.P(2,1) * point_cloud.XD + ...
    cam.P(2,2) * point_cloud.YD + ...
    cam.P(2,3) * point_cloud.ZD + ...
    cam.P(2,4))./z);

% Get size of image to do bounds checking.
[height, width, depth] = size(cam.SIL); %% CHANGE
% Remove any points in point_cloud not contained in the image (filters out
% a large portion of points quickly).
to_keep = find( (x>=1) & (x<=width) & (y>=1) & (y<=height));
x = x(to_keep);
y = y(to_keep);

% Remove points outside silhouette (don't have a pixel value of 1). 
indices = sub2ind([height,width], round(y), round(x));
result = to_keep(cam.SIL(indices) >= 1);

% Output pointcloud with only the remaining consistent points.
point_cloud_out.XD = point_cloud.XD(result);
point_cloud_out.YD = point_cloud.YD(result);
point_cloud_out.ZD = point_cloud.ZD(result);
point_cloud_out.Val = point_cloud.Val(result);
point_cloud_out.Step = point_cloud.Step;



end

