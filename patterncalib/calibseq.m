function calibration = calibseq(fname_pattern, varargin)
% CALIBSEQ calibrates a sequence of images containing black dot pattern.
%     C = CALIBSEQ(filenames, 'param1',value1,'param2',value2,...) reads a
%     file sequence described by the 'filenames' string. This string is
%     used as input to the DIR command so the method will operate on
%     whatever images are returned by a call to
%           DIR(filenames)
%
%     This can then be followed by optional parameter values from the 
%     following list: 
%
%     black - An intensity threshold [0-255] used to binarize each image. 
%       Anything bellow that value becomes black, anything above, white.
%       Default=50.
%
%     bundle - A binary parameter [0, 1] that determines if a bundle
%       adjustment step will follow the linear estimate of intrinsics and
%       camera pose. Default=1.
%
%     bundlesteps - A positive integer that determines the number of bundle
%       adjustment steps (Only used if bundle=1). Default=100.
%
%     draw - A binary parameter [0, 1] that determines if CALIBSEQ produces
%       a graphical output (rendering images & detected pattern as well as
%       3d scene structure). Default=1.
%
%     thresh1 - A distance threshold that determines the initial inliers to
%       each homography. It is expressed in terms of the mean radius of the
%       ellipses present in the image. Default=1/2.
%
%     thresh2 - A more conservative distance threshold that determines the 
%       final inliers to each homography. It is expressed in terms of the 
%       mean radius of the inlier ellipses present in the image. 
%       Default=1/8.
%     
%     The result C is a structure that contains camera pose per image 
%     and intrinsic parameters as well as the refined 3d structure of the
%     pattern, image file names the 2d positions of the dots etc. Use
%     CREATE_CALIB_FILES(C) to generate text files for each P matrix in the
%     sequence. CREATE_CALIB_FILESPMVS(C) will create files that can be
%     read by Y. Furukawa's PMVS software.
%     
%     The current version of this method assumes all images have been
%     obtained with constant focal length. This will be relaxed in future
%     versions.
%
%     
%   Copyright (2010) George Vogiatzis & Carlos Hernández

OPT=[];
OPT.black=70;
OPT.bundle=1;
OPT.bundlesteps=300;
OPT.draw=1;
OPT.thresh1=1/2;
OPT.thresh2=1/8;

OPT = options2cell(OPT,varargin{:});
EDGETHRESH = OPT.black;
bundle_adjust=OPT.bundle;
draw = OPT.draw;

c = mydir(fname_pattern);
if isempty(c)
    disp('No image was found.');
end;
pts3d = load('pattern.txt');
Hs={};
matches={};
pts2d={};
if draw
    figure;
end;

nfo=imfinfo(c(1).name);
sz = [nfo.Height,nfo.Width];

%% process each image
for k=1:length(c);
    if draw
        [qqq,justname,www] = fileparts(c(k).name);
        I = imread(c(k).name);I=rgb2gray(I);
        imshow(I);title(justname);hold on;
        [H, p, m] = detectellipsepattern(I,EDGETHRESH,draw,OPT.thresh1,OPT.thresh2);
        hold off;drawnow;
    else
        [H, p, m] = detectellipsepattern(c(k).name,EDGETHRESH,draw,OPT.thresh1,OPT.thresh2);
    end;
    
    pts2d{k} = p;
    matches{k} = m;
    Hs{k}=H;
end;

%% Using J.-Y. Bouguet's toolbox for optimizing camera parameters (intrinsic &
%% extrinsic)
for i=1:length(Hs)
    p = pts2d{i};
    m = matches{i};
    eval(sprintf('x_%d = p(m(:,1),:)'';',i));
    eval(sprintf('X_%d = pts3d(m(:,2),:)'';',i));
end;

n_ima=length(Hs);
nx = sz(2);
ny = sz(1);
two_focals_init = 0;
est_aspect_ratio = 0;
center_optim=0;
est_dist = [0;0;0;0;0];
go_calib_optim;

%% Extracting output
c=mydir(fname_pattern);
K = [fc(1) 0 cc(1);0 fc(2) cc(2); 0 0 1];
for i=1:length(Hs)
    T{i}=eval(sprintf('Tc_%d',i));
    R{i}=eval(sprintf('Rc_%d',i));
    Hs{i}=eval(sprintf('H_%d',i));
end;

pts = load('pattern.txt');

for k=1:length(Hs)
    q = R{k}*mean(pts)'+T{k};
    if(q(3)>0)
        R{k} = -R{k};
        T{k} = -T{k};
    end;
end;


%% Non-linear refinement of camera parameters AND 3d structure of pattern
%% This accounts for a non perfectly planar pattern.
Q={};
for k=1:length(R);
    Q{k} = rot2quat(R{k});
end;
[X,Nimages,Npts]=packcalibration(K,Q,T,pts3d);
r1 = mean(sqrt(bundleadjustmentcost(X,Nimages,Npts,matches,pts2d)));
if bundle_adjust==1
    JJ=[];
    II=eye(size(X,1),size(X,1));
    q0=sqrt(bundleadjustmentcost(X,Nimages,Npts,matches,pts2d));
    for i=1:length(X)
        q=sqrt(bundleadjustmentcost(X+0.00001*II(:,i),Nimages,Npts,matches,pts2d));
        JJ=[JJ abs(q-q0)];
    end;
    XX = lsqnonlin(@(X) bundleadjustmentcost(X,Nimages,Npts,matches,pts2d), X,[],[],optimset('Display','iter','LargeScale','on','JacobPattern',sparse(double(JJ>0.000001)),'MaxIter',OPT.bundlesteps));
else
    XX = X;
end;

fprintf(1, 'Mean reprojection error before structure refinement: %0.5f\n',r1);
if bundle_adjust==1
    r2 = mean(sqrt(bundleadjustmentcost(XX,Nimages,Npts,matches,pts2d)));
    fprintf(1, 'Mean reprojection error after structure refinement: %0.5f\n',r2);
end;
[K,Q,T,pts3d] = unpackcalibration(XX,Nimages,Npts);
R = cellfun(@(X) quat2rot(X), Q,'UniformOutput',0);
P = cellfun(@(R,T) K*[R T], R, T,'UniformOutput',0);

%% This draws the structure
if draw
    figure;hold;plot3(pts3d(:,1),pts3d(:,2),pts3d(:,3),'rx');
    for k=1:length(c)
        x0 = R{k}^-1*T{k};
        x1 = x0+R{k}'*[0;0;1];
        x2 = x0+R{k}'*[0;1;0];
        x3 = x0+R{k}'*[1;0;0];
        plot3(x0(1),x0(2),x0(3),'b+');
        plot3(x1(1),x1(2),x1(3),'go');
        plot3(x2(1),x2(2),x2(3),'go');
        plot3(x3(1),x3(2),x3(3),'go');
        plot3([x0(1) x1(1)],[x0(2) x1(2)],[x0(3) x1(3)],'m-');
        plot3([x0(1) x2(1)],[x0(2) x2(2)],[x0(3) x2(3)],'m-');
        plot3([x0(1) x3(1)],[x0(2) x3(2)],[x0(3) x3(3)],'m-');
    end
    axis equal;
end;

disp('Intrinsic calibration matrix:');
disp(K);

calibration.files = c;
calibration.K=K;
calibration.Q=Q;
calibration.T=T;
calibration.pts3d=pts3d;

calibration.R = R;
calibration.P = P;
calibration.Hs=Hs;
calibration.matches=matches;
calibration.pts2d=pts2d;