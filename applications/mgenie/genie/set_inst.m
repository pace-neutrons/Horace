function varargout = set_inst (inst)
% Set raw data source instrument name
%
%   >> set_inst inst_name
%   >> set_inst (inst_name)
%
%   >> ok = set_inst ...
%
% E.g.
%   >> set_inst maps
%   >> set_inst ('maps')

global mgenie_globalvars

if isstring(inst)
    mgenie_globalvars.source.inst=strtrim(inst);
    ok=true;
elseif isempty(inst)
    mgenie_globalvars.source.inst='';
    ok=true;
else
    ok=false;
end

if nargout>0
    varargout{1}=ok;
else
    if ~ok, error('Instrument must be a character string'), end
end
