function p = dir2path(varargin)
% Convert directory listing to a path string
%
%   >> p = dir2path     % path from directories in the current working directory
%   >> p = dir2path(d)  % path from directories found by dir(d) (if d is empty
%                       % then intepret this as meaning the current directory)
%
%   >> p = dir2path(d,'-noext') % on PC systems, use a fudge to get around
%                               % shortcuts by assuming that a directory
%                               % entry without an extension is a folder
%                               % Ignored on unix systems
%
% e.g.
%   p = dir2path
%   p = dir2path('')
%   p = dir2path('c:\tgp\data')
%   p = dir2path('z:\cycle*','-noext')
%
% Only includes directories allowed on the matlab path


if nargin>2
    error('Check number of input arguments')
end

% Get folder name
if nargin==0 || isempty(varargin{1})
    d=pwd;
    pathname=d;
else
    d=varargin{1};
    if exist(d,'dir')
        pathname=d;
    else
        pathname=fileparts(d);
    end
end

% Determine if need to do fudge search on Windows to catch shortcuts
noext=false;
if numel(varargin)==2
    if is_string(varargin{2}) && strcmpi(varargin{2},'-noext')
        if ispc
            noext=true;
        end
    else
        error('Invalid optional argument')
    end
end

% Get list of folders
files=dir(d);
if ~noext
    dirs=files(cat(1,files.isdir));
else
    curr_dir=pwd;
    ok=cat(1,files.isdir);
    for i=1:numel(ok)
        if ~ok(i)
            [path,name,ext]=fileparts(files(i).name);
            if isempty(ext)     % could be a shortcut (isdir doesn't indicate correctly)
                ok(i)=true;
%                 try
%                     fullfile(pathname,files(i).name)
%                     cd(fullfile(pathname,files(i).name));
%                     ok(i)=true;
%                 catch
%                 end
%                 cd(curr_dir);
            end
        end
    end
    dirs=files(ok);
end

% Create pathstring
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
