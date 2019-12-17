function [s_empty,err_empty,dat_empty,det_empty] = data_empty(this)
% helper method checks which data fields are empty
%
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
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


