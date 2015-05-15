function renameimages(path, newname, deleteold)
if nargin<3
    deleteold=0;
end;
[folder, name, ext, versn] = fileparts(path);
if isempty(folder)
    folder='.';
end;
names = dir(path);
for i=1:length(names)
    oldfullname = sprintf('%s\\%s', folder, names(i).name);
    newfullname = sprintf('%s\\%s%04d.png', folder, newname,i-1);
    disp(sprintf('Copying %s into %s\n',oldfullname,newfullname));
    if strcmp(oldfullname(end-2:end),newfullname(end-2:end))
        copyfile(oldfullname,newfullname);
    else
        imwrite(imread(oldfullname), newfullname);
    end
    if deleteold==1
        delete(oldfullname);
    end
end;