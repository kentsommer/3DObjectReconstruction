function [camstruct] = model_setup(fgimage_dir, bgimage_dir, cal_struct, num_images) %mat_dir, num_images)
% Model_step takes in calibration structure, forground and background
% images, as well as the number of images to be processed (specific naming
% is required for function to work properly: fg01.jpg, bg01.jpg, etc. 

% Overview: Addes all images to a new structure that holds the decomposed
% K, R, and T matrices from calibration (Projection matrix as a whole is 
% also included, as well as the silhouette image and the color image for 
% each view.
camstruct = struct('P', {}, 'K', {}, 'R', {}, 'T', {}, 'IM', {}, 'SIL', {});

% Get Projection matrices mat
full_P = cal_struct.P;

% Loop over all images and add their respective values to the struct
for i = 1:num_images
    % Get images from respective folders.
    current_IM = imread(fullfile(fgimage_dir, sprintf('fg%02d.jpg', i)));
    current_BG = imread(fullfile(bgimage_dir, sprintf('bg%02d.jpg', i)));   
    current_P = full_P{i};
    
    % Extract silhouette using simple background subtraction. (Very
    % sensitive to noise). 
    current_silhouette = extract_Silhouette(current_IM, current_BG);
    figure, imshow(current_silhouette);
    drawnow;
        
    % Uses QR decomposition to get K, R, and T from a given projection
    % matrix. Technically this step was not necessary as camera calibration
    % already gives the decomposed matrices, however, I wanted to
    % understand how this process worked and decided it was a more robust
    % solution to allow for simply passing projection matrices (also saves
    % space depending on how many images are used). 
    [K, R, T] = decompose_projection(current_P);
    
    % Add data to camera struct
    camstruct(i).P = current_P;
    camstruct(i).K = K/K(3,3); % Get homogeneous (scale last element to 1)
    camstruct(i).R = R;
    camstruct(i).T = -R'*T;
    camstruct(i).IM = current_IM;
    camstruct(i).SIL = current_silhouette;

end

