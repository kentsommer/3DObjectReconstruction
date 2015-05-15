function texture_map(ptch, images)

% Get the optical axis for each image
n = size(images, 2);
optical_axes = zeros(3, n);
for i=1:n
    optical_axes(:,i) = getOpticalAxisDirection(images(i));
end

% Find the best image using surface normal of the point and optical axes
vertices = get(ptch, 'Vertices');
v = size(vertices, 1);

% Initialize colors
colors = zeros( v, 3 );

% Get surface normals for each vertex
normals = get(ptch, 'VertexNormals');

for i=1:v
    % Calculate the angles between optical axes and the surface normal
    % using the dot product
    angles = zeros(1, n);
    for j=1:n
        angles(1, j) = dot(normals(i,:)/norm(normals(i,:)), optical_axes(:, j));
    end
    % Find the minimal angle
    [~,index] = min( angles );
    
    % project back to image coordinates
    [x,y] = projectToCamera(images(index), vertices(i,1), vertices(i,2), vertices(i,3));
    colors(i,:) = im2double(images(index).IM(y, x, :));
end

% Set ptch to use the new colors
set(ptch, 'FaceVertexCData', colors, 'FaceColor', 'interp');

end

