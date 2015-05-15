function d = getOpticalAxisDirection( camera )
[h, w] = size(camera.IM);

% Get image center
c = [w/2, h/2, 1.0]';

% Get camera center and rotate it
d = camera.R'*(camera.K \ c);
% Make direction a unit vector
d = d ./ norm( d );

end

