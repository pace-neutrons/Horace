function [s_empty,err_empty,dat_empty,det_empty] = data_empty_(obj)
% helper method checks which data fields are empty
%
%
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


