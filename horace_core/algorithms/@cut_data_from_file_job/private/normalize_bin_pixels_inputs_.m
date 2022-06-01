function [npix,s,e,argi] = normalize_bin_pixels_inputs_(axes,varargin)
% Take inputs of bin_pixels of cut_data_from_file_job in any acceptable
% form and return standard form of the input, namely, extract from the
% input the requested accumulator arrays or initialize such arrays if the
% input do not conatin these accumulators
%

grid_size = axes.dims_as_ssize();
if nargin<2 || nargin>=2 && iskey(varargin{1})
    npix = zeros(grid_size);
    s = zeros(grid_size);
    e = zeros(grid_size);
    argi = varargin;
elseif nargin ==2 && isnumeric(varargin{1}) || ...
        (nargin>2 && isnumeric(varargin{1}) && iskey(varargin{2}))
    npix = varargin{1};
    s = zeros(size(npix));
    e = zeros(size(npix));
    if numel(varargin)==1
        argi= {};
    else
        argi = varargin(2:end);
    end
elseif nargin>=4
    npix = varargin{1};
    s = varargin{2};
    e = varargin{3};
    argi = varargin(4:end);
else
    error('HORACE:cut_data_from_file_job:invalid_argument', ...
        "This method may have 3 or 6 numerical input arguments and optional keys (character arguments)")
end

function is = iskey(val)
is = ischar(val)||isstring(val);
