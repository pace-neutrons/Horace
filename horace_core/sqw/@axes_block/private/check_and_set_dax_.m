function obj = check_and_set_dax_(obj,val)
% verify display axes setting and set appropriate display axes sequence
nd = obj.n_dims;
if numel(val)~=nd
    error('HORACE:axes_block:invalid_argument',...
        'number of display axes elements (%d) have to be equal to the number of projection axes (%d)',...
        numel(val),nd)
end

obj.dax_ = val(:)';