function ptch = plotmodel( voxels )
% Plots the model given a pointcloud (uses matlab patch and isosurface
% functions). 

% Remove all non-unique points to speed up the processing.
ux = unique(voxels.XD);
uy = unique(voxels.YD);
uz = unique(voxels.ZD);

% Expand the limits a bit (if this isn't done, I ended up cutting off a bit of the
% back of the model. If it is expanded by too much other weird artifacts start appearing). 
ux = [ux(1)-voxels.Step; ux; ux(end)+voxels.Step];
uy = [uy(1)-voxels.Step; uy; uy(end)+voxels.Step];
uz = [uz(1)-voxels.Step; uz; uz(end)+voxels.Step];

% Get the grid.
[X,Y,Z] = meshgrid( ux, uy, uz );

% fill only the points in the pointcloud (C is color, however, color gets
% overwritten by the last portion of the whole algirthm so this is more
% just a way to view the model before actual retexturing is done). 
C = zeros( size( X ) );
for i = 1:numel( voxels.XD);
    ix = (ux == voxels.XD(i));
    iy = (uy == voxels.YD(i));
    iz = (uz == voxels.ZD(i));
    C(iy,ix,iz) = voxels.Val(i);
end

% Use matlabs builtin patch and isosurface functions to get a surface view
% for the model pointcloud.
ptch = patch( isosurface( X, Y, Z, C, 0.5 ) );
isonormals( X, Y, Z, C, ptch )
set( ptch, 'FaceColor', 'r', 'EdgeColor', 'none' );

set(gca,'DataAspectRatio',[1 1 1]);
xlabel('x');
ylabel('y');
zlabel('z');
% Adding fake lights to the view helps show the model detail a little bit
% better, however, this isn't really necessary.
lighting( 'gouraud' )
camlight( 'right' )
camlight( 'left')
axis( 'tight' )
end
