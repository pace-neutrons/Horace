function w = set_simple(w, varargin)
% Set fields in a tofpar without checking consistency - for fast setting. Use carefully!
%
%   >> w = set_simple (w, varargin)
%
% e.g.
%   >> w = set_simple (w, 'emode', 1, 'efix', ei)

m = floor(numel(varargin)/2);
if (numel(varargin)-2*m == 1)  % must have even number of arguments
    error ('Check number of arguments to set')
end

for i = 1:m
    prop_name = varargin{2*i-1};
    switch prop_name
        case 'emode'
            w.emode = varargin{2*i};
        case 'delta'
            w.delta = varargin{2*i};
        case 'x1'
            w.x1 = varargin{2*i};
        case 'x2'
            w.x2 = varargin{2*i};
        case 'twotheta'
            w.twotheta = varargin{2*i};
        case 'azimuth'
            w.azimuth = varargin{2*i};
        case 'efix'
            w.efix = varargin{2*i};
        otherwise
            error ([prop_name ' is not a valid property of a tofpar'])
    end
end
