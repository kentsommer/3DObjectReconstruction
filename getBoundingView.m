function [xb, yb, zb] = getBoundingView(camstruct)

% Get number of views
views = numel(camstruct);

% Get all possible cam positions / cat vertically
possible_positions = cat(2, camstruct.T);

% Get limits from T (translation matrix) from all views.
xbmax = max(possible_positions(1,:));
xbmin = min(possible_positions(1,:));
ybmax = max(possible_positions(2,:));
ybmin = min(possible_positions(2,:));
zbmin = min(possible_positions(3,:));
zbmax = max(possible_positions(3,:));

% Set distance with slight bounds tightening
distance = 0.6 * sqrt(diff([xbmin, xbmax]).^2 + diff([ybmin, ybmax]).^2);

% Adjust z values to proper 
for i = 1:views
    % Get Camera Center
    x = [size(camstruct(i).IM, 2) / 2; size(camstruct(i).IM, 1); 1];
    % Divide Intrisics by cam center then multiply by rotation transpose
    X = camstruct(i).K\x;
    X = camstruct(i).R'*X;
    % Divide by norm to get direction
    direction = X./norm(X);
    % Get the current view from direction
    current_view = camstruct(i).T - (distance * direction);
    % Finally, adjust the min and max of Z
    zbmin = min(zbmin, current_view(3));
    zbmax = max(zbmax, current_view(3));
end

% Get the bounding box
boundingbox_pointcloud = getModelBB([xbmin, xbmax], [ybmin, ybmax], [zbmin, zbmax], 100000);

% Carve away with low resolution to find better limits
for i = 1:views
    pointcloud = cut_from_silhouette(boundingbox_pointcloud, camstruct(i));
end

% Check that there is data still - if calibration was bad, you might have 
% nothing left after carving. (check projection matrices)
if(isempty(pointcloud.XD))
    error('No data returned... Verify Calibration integrity');
end

% Expand limits by Step 
xb = [min(pointcloud.XD), max(pointcloud.XD)] + 2*pointcloud.Step*[-1, 1];
yb = [min(pointcloud.YD), max(pointcloud.YD)] + 2*pointcloud.Step*[-1, 1];
zb = [min(pointcloud.ZD), max(pointcloud.ZD)] + 2*pointcloud.Step*[-1, 1];

end

