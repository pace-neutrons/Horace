function [s_empty,err_empty,dat_empty,det_empty] = data_empty_(obj)
% helper method checks which data fields are empty
%
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
%
if isempty(obj.S_)
    s_empty=true;
else
    s_empty=false;
end

if isempty(obj.ERR_)
    err_empty = true;
else
    err_empty = false;
end

dat_empty = s_empty||err_empty;

if isempty(obj.det_par)
    det_empty=true;
else
    det_empty=false;
end


