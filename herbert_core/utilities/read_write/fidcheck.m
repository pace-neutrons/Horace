function [file_full,ok,mess]=fidcheck(fid,permission)
% Robust check that a fid is an open file and with the requested permission
%
%   >> [file_full,ok,mess]=fidcheck(fid,permission)
    
if isnumeric(fid) && numel(fid)==1
    [file_full,mode]=fopen(fid);
    if isempty(file_full)||~strcmpi(mode,permission)
        ok=false; mess = ['Check file is open with requested read and/or write permission: ',permission];
    else
        ok=true; mess='';
    end
else
    ok=false; mess='Fide identifier must be a positive integer';
end

% If not given ok as output argument, fail if ~ok
if nargout==1 && ~ok
    error(mess);
end
