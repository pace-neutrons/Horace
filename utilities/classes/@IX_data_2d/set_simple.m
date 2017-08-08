function w = set_simple(w, varargin)
% Set fields in an IX_dataset_1d without checking consistency - for fast setting. Use carefully!
%
%   >> w = set_simple (w, varargin)
%
% e.g.
%   >> w = set_simple (w, 'x', [13,14], 'error', 2.1)

m = floor(numel(varargin)/2);
if (numel(varargin)-2*m == 1)  % must have even number of arguments
    error ('Check number of arguments to set')
end

for i = 1:m
    prop_name = varargin{2*i-1};
    switch prop_name
        case 'title'
            w.title = varargin{2*i};
        case 'signal'
            w.signal = varargin{2*i};
        case 'error'
            w.error = varargin{2*i};
        case 's_axis'
            w.s_axis = varargin{2*i};
        case 'x'
            w.x = varargin{2*i};
        case 'x_axis'
            w.x_axis = varargin{2*i};
        case 'x_distribution'
            w.x_distribution = varargin{2*i};
        case 'y'
            w.y = varargin{2*i};
        case 'y_axis'
            w.y_axis = varargin{2*i};
        case 'y_distribution'
            w.y_distribution = varargin{2*i};
        otherwise
            error ([prop_name ' is not a valid property of a tofpar'])
    end
end
