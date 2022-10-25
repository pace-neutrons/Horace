function obj = check_combo_arg_(obj)
% verify if interdependent properties of the object are consistent

nd = obj.dimensions;
if numel(obj.dax)~=nd
    error('HORACE:axes_block:invalid_argument',...
        'number of display axes elements (%d) have to be equal to the number of projection axes (%d)',...
        numel(obj.dax),nd);
end
if max(obj.dax)>numel(obj.pax)
    error('HORACE:axes_block:invalid_argument',...
        'The maximal number of display axis can not exceed the number of projection axes');
end
