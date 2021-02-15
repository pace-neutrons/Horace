function nodes = expand_box(min_value,max_value)
% Build array of nodes of 2D, 3D or 4D box based on its minimal and maximal 
% points. The node is the column vector with n-rows (N-dimensions)
%
% Inputs:
% min_point -- the vector of minimal coordinates values
% max_point -- the vector of maximal coordinates values
% Output:
% nodes     -- 2x4, 3x8 or 4x16 nodes of the box, defined by min/max values
%
if size(min_value,2)>1
    min_value = min_value';
    max_value = max_value';
end
if size(min_value,2) ~= 1
    error('EXPAND_BOX:invalid_argument',...
        'The expansion routine accepts only vectors. Actual size is:\n %s',...
        evalc('disp(size(min_value))'));
end
if any(size(min_value) ~=size(max_value))
    error('EXPAND_BOX:invalid_argument',...
        'The size on vector of min values:\n %s and max values:\n %s have to be the same',...
        evalc('disp(size(min_value))'),evalc('disp(size(max_value))'));
end
if ~any(min_value<max_value)
    error('EXPAND_BOX:invalid_argument',...
        'all min values of the input:\n %s have to be smaller then all max values of the input:\n%s ',...
        evalc('disp(min_value)'),evalc('disp(max_value)'));
end

ndims = size(min_value,1);
perm = get_geometry(ndims);

source = [min_value,max_value];
switch ndims
    case(2)
        shape_fun = @(sel)[source(1,sel(1));source(2,sel(2))];
    case(3)
        shape_fun = @(sel)[source(1,sel(1));source(2,sel(2));...
            source(3,sel(3))];
    case(4)
        shape_fun = @(sel)[source(1,sel(1));source(2,sel(2));...
            source(3,sel(3));source(4,sel(4))];
    otherwise
        error('EXPAND_BOX:invalid_argument',...
            'The routine accepts data in 2,3 or 4 dimensions only, Got: %d',...
            numel(min_value))
end
sp = cellfun(shape_fun,perm, 'UniformOutput',false);

nodes = [sp{:}];