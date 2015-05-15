% Camera Calibration. Tool box source: http://george-vogiatzis.org/calib/
% which utilizes http://www.vision.caltech.edu/bouguetj/calib_doc/
close all; clear clc;
addpath patterncalib/TOOLBOX_calib/;
addpath patterncalib/;
image_dir = fullfile(fileparts(mfilename('fullpath')), 'patterncalib/CALIMAGES/cal*.jpg');
C = calibseq(image_dir);

% Setup dirs for images
fgimage_dir = fullfile(fileparts(mfilename('fullpath')), 'FGIMAGES');
bgimage_dir = fullfile(fileparts(mfilename('fullpath')), 'BGIMAGES');


% Setup Camera struct to hold decomposition of the projection matricies as
%  well as the original images and silhouettes 
camstruct = model_setup(fgimage_dir, bgimage_dir, C, 28);

% Get bounding box based on space contained by all cameras (performs a
% low resolution carving to get better limits)
[xb, yb, zb] = getBoundingView(camstruct);

% Make a pointcloud using tight bounds found from bounding box above.
% Inputs: bounding box limits, and number of voxels to use. Larger number
% makes for a better and smoother moodle, however, this quickly uses a
% massive amount of RAM. (be careful in running on a machine with low RAM
% as this number of points will freeze an average computer).
pointcloud = getModelBB(xb, yb, zb, 120000000);

% Perform space carving across all the camera views!
for i = 1:numel(camstruct)
    pointcloud = cut_from_silhouette(pointcloud,camstruct(i)); 
end

% Show resulting model
figure('Position',[100 100 600 300]);
subplot(1,1,1)
plotmodel( pointcloud )
title( 'Result after full carving' )

% Display and color/texture the model
figure('Position',[100 100 600 700]);
ptch = plotmodel( pointcloud );
% Map texture back onto the model
texture_map(ptch, camstruct);

set(gca,'Position',[-0.2 0 1.4 0.95])
axis off
title( 'Result after coloring' )





