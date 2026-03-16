function [offset,coord_system,normal_defined] = check_fold_arguments_(nfold, axis, varargin)
%CHECK_FOLD_ARGUMENT_  parse various option fold function may have
% 
% Validate possible argument values and provide default values for missing
% arguments.
%
validateattributes(nfold, {'numeric'}, {'integer'})

coord_system = 'cc';
if nargin < 3
    offset = [0; 0; 0];
else % nargin>=3
    if isnumeric(varargin{1}) && numel(varargin{1})==3
        offset = varargin{1};
    elseif istext(varargin{1})
        offset = [0; 0; 0];
        coord_system = varargin{1};
    else
        error('HORACE:SymopRotation:invalid_argument', ...
            ['Third argument of fold function can be offset or coordinate system\n' ...
            'Actually it is %s'],disp2str(varargin{1}))
    end
    if nargin == 4
        coord_system = varargin{2};
    end
end
if numel(axis) == 3
    normal_defined = true;
elseif all(size(axis) == [2,3])
    normal_defined = false;
else
    error('HORACE:SymopRotation:invalid_argument',[...
        'Rotation axis may be defined either by rotation axis (3-vector)\n' ...
        'or 2 vectors defining rotation plane [2x3] matrix\n' ...
        'Size of input dataset: %s'],disp2str(size(axis)))
end

end