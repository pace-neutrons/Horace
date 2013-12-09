function p = dir2path(d)
% Convert directory listing to a path string
%
%   >> p = dir2path     % path from directories in the current working directory
%   >> p = dir2path(d)  % path from directories found by dir(d)
%
% e.g.
%   p = dir2path('c:\tgp\data')
%   p = dir2path('c:\tgp\data\cycle*')
%
% Only includes directories allowed ont he matlab path

files=dir(d);
dirs=files(cat(1,files.isdir));
if exist(d,'dir')
    pathname=d;
else
    pathname=fileparts(d);
end
    

classsep = '@';     % qualifier for overloaded class directories
packagesep = '+';   % qualifier for overloaded package directories

p='';
for i=1:numel(dirs)
    dirname=dirs(i).name;
    if ~strcmp(dirname,'.')             && ...
            ~strcmp(dirname,'..')            && ...
            ~strncmp(dirname,classsep,1)     && ...
            ~strncmp(dirname,packagesep,1)   && ...
            ~strcmp(dirname,'private')
        p=[p,fullfile(pathname,dirname),pathsep];
    end
end
