function  create_calib_filesPMVS(calib)
for i=1:length(calib.files);    
    [folder, name, ext, versn] = fileparts(calib.files(i).name);
    p=calib.P{i};
    mat_name = sprintf('%s/%08d.txt',folder,i-1);
    f=fopen(mat_name,'w');
    fprintf(f,'CONTOUR\r\n'); 
    fprintf(f,'%f %f %f %f\r\n',p'/sign(p(3,4))); 
    fclose(f);   
end;