function w=IXTaxis(varargin)
% Compatibility function to construct an IX_axis in Herbert in place of the Libisis IXTaxis constructor
%
%   >> w = IXTaxis (...)

% Catch case of first argument is IXTbase

if numel(varargin)>0 && ~isnumeric(varargin{1}) && ~ischar(varargin{1}) && ~iscellstr(varargin{1})
    if numel(varargin)>1
        w=IX_axis(varargin{2:end});
    else
        w=IX_axis;
    end
else
    w=IX_axis(varargin{:});
end
