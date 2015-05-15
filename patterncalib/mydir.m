function names = mydir(path)
[folder, name, ext] = fileparts(path);
if isempty(folder)
    folder='.';
end;
names = dir(path);
for i=1:length(names)
    names(i).name = sprintf('%s//%s', folder, names(i).name);
end;