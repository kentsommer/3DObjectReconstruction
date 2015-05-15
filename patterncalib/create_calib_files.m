function  create_calib_files(calib)
% CREATE_CALIB_FILES(calib) creates camera-matrix textfiles with the same
% file names as the images correspondinc to those cameras.
%
%   calib - is a structure returned by CALIBSEQ that contains all
%   calibration output.
%
%   Copyright (2010) George Vogiatzis & Carlos Hernández
for i=1:length(calib.files);    
    mat_name = calib.files(i).name;
    p=calib.P{i};
    mat_name(end-2:end)='txt';
    f=fopen(mat_name,'w');
    fprintf(f,'%f %f %f %f\r\n',p'/sign(p(3,4))); 
    fclose(f);   
end;