function obj = check_and_set_dax_(obj,val)
% verify display axes setting and set appropriate display axes sequence
nd = obj.n_dims;
if numel(val)~=nd
    error('HORACE:axes_block:invalid_argument',...
        'number of display axes elements (%d) have to be equal to the number of projection axes (%d)',...
        numel(val),nd)
end
if max(val(:))>numel(obj.pax)
    error('HORACE:axes_block:invalid_argument',...
        'The maximal number of display axis can not exceed the number of projection axes');
end
if min(val(:))~=1
    error('HORACE:axes_block:invalid_argument',...
        'A display axis should refer the first projextion axis')
end

obj.dax_ = val(:)';