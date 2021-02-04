function nodes = expand_box(min_value,max_value)
% Build 3D or 4D box based on its minimal and maximal points
% inputs:
% min_point -- the vector of minimal coordinates values
% max_point -- the vector of maximal coordinates values
% Output:
% nodes     -- 2x4, 3x8 or 4x16 nodes of the box, defined by min/max values
%
persistent perm2D;
persistent perm3D;
persistent perm4D;
if isempty(perm2D)
    perm2D= {[1,1];[1,2];[2,1];[2,2]};
    
    perm3D= {[1,1,1]; [1,1,2]; [1,2,1]; [1,2,2];...
        [2,1,1]; [2,1,2]; [2,2,1]; [2,2,2]};
    
    perm4D= {...
        [1,1,1,1]; [1,1,1,2]; [1,1,2,1]; [1,1,2,2];...
        [2,1,1,1]; [2,1,1,2]; [2,1,2,1]; [2,1,2,2];...
        [1,2,1,1]; [1,2,1,2]; [1,2,2,1]; [1,2,2,2];...
        [2,2,1,1]; [2,2,1,2]; [2,2,2,1]; [2,2,2,2]};
end

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

source = [min_value,max_value];
ndims = size(min_value,1);
switch ndims
    case(2)
        sp = cellfun(@(sel)[source(1,sel(1));source(2,sel(2))],perm2D,...
            'UniformOutput',false);
    case(3)
        sp = cellfun(@(sel)[source(1,sel(1));source(2,sel(2));...
            source(3,sel(3))],perm3D,'UniformOutput',false);
    case(4)
        sp = cellfun(@(sel)[source(1,sel(1));source(2,sel(2));...
            source(3,sel(3));source(4,sel(4))],perm4D,'UniformOutput',false);
    otherwise
        error('EXPAND_BOX:invalid_argument',...
            'The routine accepts from 2 to 4 dimensions only, Got: %d',...
            numel(min_value))
end
nodes = [sp{:}]';