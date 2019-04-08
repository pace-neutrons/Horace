function [s_empty,err_empty,dat_empty,det_empty] = data_empty(this)
% helper method checks which data fields are empty
%
%
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)
%
if isempty(this.S_)
    s_empty=true;
else
    s_empty=false;
end

if isempty(this.ERR_)
    err_empty = true;
else
    err_empty = false;
end

dat_empty = s_empty||err_empty;

if isempty(this.det_par_)
    det_empty=true;
else
    det_empty=false;
end

