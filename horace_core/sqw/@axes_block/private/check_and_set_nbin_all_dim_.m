function obj = check_and_set_nbin_all_dim_(obj,val)
% Check if the bining along each direction attempted to set are correct and
% set requested number of bins in each direction
%
if ~isnumeric(val)
    error('HORACE:axes_block:invalid_argument',...
        'nbin have to be numeric vector consisting of 4 elements. Attempting to set type: %s',...
        class(val));
end
if numel(val) ~= 4
    error('HORACE:axes_block:invalid_argument',...
        'Correct nbin_all_dim value have to be 4-element vector. Getting: %s',...
        evalc('disp(val)'));
elseif size(val,1) == 4
    val = val';
end
val = floor(val);
if any(val<1)
    mess = sprintf(...
        'each element nbin_all_dim have to positive value larger or equal to 1. Got : [%g, %g, %g, %g]',...
        val);
    error('HORACE:axes_block:invalid_argument',mess);
end
obj.nbin_all_dim_ = val;

