function [str,cellstr,log]=Ssplit(S)
% Split structure into structures according to field content types
%
%   >> [substr,subcell,block]=Ssplit(S)
%
% Input:
% ------
%   S       Structure whose fields are the names of variables and their
%          values.
%           The format of the definitions block constrains variables to have
%          values that are one of:
%               - logical 0 or 1,
%               - a string
%               - a cell array of strings
%
% Output:
% -------
%   substr  Structure whose fields contain strings.
%   subcell Structure whose fields contain cellarrays of strings.
%   block   Structure with logical scalars

Snam=fieldnames(S);
istr=false(size(Snam));
icell=false(size(Snam));
ilog=false(size(Snam));

for i=1:numel(Snam)
    val=S.(Snam{i});
    if islogical(val)
        ilog(i)=true;
    elseif ischar(val)
        istr(i)=true;
    elseif iscellstr(val)
        icell(i)=true;
    else
        error('Logic problem somewhere in docify functions')
    end
end

str=rmfield(S,Snam(~istr));
cellstr=rmfield(S,Snam(~icell));
log=rmfield(S,Snam(~ilog));
