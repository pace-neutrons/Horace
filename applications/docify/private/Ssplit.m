function [str_struct, cell_struct, log_struct] = Ssplit (S)
% Split structure into structures according to field content types
%
%   >> [str, cellstr, log] = Ssplit (S)
%
% Input:
% ------
%   S           Structure whose fields are the names of variables and their
%              values.
%               The format of the definitions block constrains variables to have
%              values that are one of:
%                   - logical 0 or 1,
%                   - a string
%                   - a cell array of strings
%
% Output:
% -------
%   str_struct  Structure whose fields contain strings.
%   cell_struct Structure whose fields contain cellarrays of strings.
%   log_struct  Structure with logical scalars

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

str_struct=rmfield(S,Snam(~istr));
cell_struct=rmfield(S,Snam(~icell));
log_struct=rmfield(S,Snam(~ilog));
