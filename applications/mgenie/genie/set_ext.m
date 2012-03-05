function varargout = set_ext (ext)
% Set raw data source extension name
%
%   >> set_ext ext_name
%   >> set_ext (ext_name)
%
%   >> ok = set_ext ...
%
% E.g.
%   >> set_ext raw
%   >> set_ext ('raw')

global mgenie_globalvars

if isstring(ext)
    mgenie_globalvars.source.ext=strtrim(ext);
    ok=true;
elseif isempty(ext)
    mgenie_globalvars.source.ext='';
    ok=true;
else
    ok=false;
end

if nargout>0
    varargout{1}=ok;
else
    if ~ok, error('Extension must be a character string'), end
end
