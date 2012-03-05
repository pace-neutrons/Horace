function varargout = set_dir (dir)
% Set raw data source directory name
%
%   >> set_dir dir_name
%   >> set_dir (dir_name)
%
%   >> ok = set_dir ...
%
% E.g.
%   >> set_dir my_data\jan2005
%   >> set_dir ('my_data\jan2005')

global mgenie_globalvars

if isstring(dir)
    mgenie_globalvars.source.dir=strtrim(dir);
    ok=true;
elseif isempty(dir)
    mgenie_globalvars.source.dir='';
    ok=true;
else
    ok=false;
end

if nargout>0
    varargout{1}=ok;
else
    if ~ok, error('Directory must be a character string'), end
end
