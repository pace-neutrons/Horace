function w = spectrum(varargin)
% Compatibility function to construct an IX_dataset_1d in Herbert in place of the mgenie spectrum constructor
%
%   >> w = spectrum(x,y)
%   >> w = spectrum(x,y,e)
%   >> w = spectrum(x,y,e,title,xlab,ylab)
%   >> w = spectrum(x,y,e,title,xlab,ylab,xunit)
%   >> w = spectrum(x,y,e,title,xlab,ylab,distribution)         % not one of the mgenie possibilities, but added for completeness
%   >> w = spectrum(x,y,e,title,xlab,ylab,xunit,distribution)
%
%   x               Array of x values
%   y               Array of y values
%   e               Array of standard errors
%       [If length(x) = length(y)+1, then x values are taken as histogram bin boundaries.
%        If length(x) = length(y), then (x,y) are taken as points on a curve.]
%   title           Title for graphical display
%   xlab            X-axis label (excluding any explicit units declarations, see below)
%   ylab            Y-axis label (excluding any units arising from explicit declaration
%                  of being a distribution, see below)
%   xunits          Units of x-axis. e.g. 'meV'. The units will be incorporated into
%                  x-axis label at the moment of display.
%   distribution    =0 if y values are not a distribution in the units of the x-axis
%                   =1 if y values are a distribution
%                   If distribution=1, then the inverse of units of the x-axis as
%                  given by xunits will be used in the y-axis label at the moment of
%                  display.

if nargin<7
    w=IX_dataset_1d(varargin{:});
elseif nargin==7
    if isnumeric(varargin{7})||islogical(varargin{7})
        w=IX_dataset_1d(varargin{:});
    else
        args=[varargin(1:4),{IX_axis(varargin{5},varargin{7})},varargin(6)];
        w=IX_dataset_1d(args{:});
    end
elseif nargin==8
    args=[varargin(1:4),{IX_axis(varargin{5},varargin{7})},varargin(6),varargin(8)];
    w=IX_dataset_1d(args{:});
else
    error('Check number of input arguments')
end
