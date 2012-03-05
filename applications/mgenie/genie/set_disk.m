function varargout = set_disk (disk)
% Set raw data source disk name
%
%   >> set_disk disk_name
%   >> set_disk (disk_name)
%
%   >> ok = set_disk ...
%
% E.g.
%   >> set_disk c:
%   >> set_disk ('c:')

global mgenie_globalvars

if isstring(disk)
    mgenie_globalvars.source.disk=strtrim(disk);
    ok=true;
elseif isempty(disk)
    mgenie_globalvars.source.disk='';
    ok=true;
else
    ok=false;
end

if nargout>0
    varargout{1}=ok;
else
    if ~ok, error('Disk must be a character string'), end
end
