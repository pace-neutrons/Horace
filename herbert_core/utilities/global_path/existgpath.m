function status=existgpath(varargin)
% Check if a particular global path is stored:
%
%   >> status=existgpath            % check if any global paths exist
%   >> status=existgpath(pathname)  % check if named global path exists
%
%
% See also: mkgpath, delgpath, addgpath, rmgpath, addendgpath, addbeggpath, showgpath, existgpath

% Check global path name
if nargin==1 && ~isvarname(varargin{1})
    status=false;   % return false if not character string, variable name etc.
    return
end

status = ixf_global_path ('exist',varargin{:});
