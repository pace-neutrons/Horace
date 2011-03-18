function outcell = getgpath(varargin)
% Get cell array of directories in named global path
%
%   >> namcell=getgpath             % cell array of names of all global paths
%   >> dircell=getgpath(pathname)   % cell array of directories in named path
%   >> dircell=getgpath(pathname,'full')   % cell array of directories in named path, all global paths resolved
%
% See also: mkgpath, delgpath, addgpath, rmgpath, addendgpath, addbeggpath, showgpath, existgpath

% Check global path name
if nargin==1 || nargin==2
    if ~isvarname(varargin{1})
        error('Check global path is a character string')
    end
    if nargin==2
        if ~ischar(varargin{2}) || ~size(varargin{2},1)==1 || ~strcmpi(varargin{2},'full')
            error('Only valid optional argument is ''full''')
        else
            varargin{2}='full';     % ensure lower case
        end
    end
elseif nargin>2
    error('Check number of input arguments')
end

if nargin>=1 && ~existgpath(varargin{1})
    error(['Global path ''',varargin{1},''' does not exist.'])
end

outcell = ixf_global_path ('get',varargin{:});
