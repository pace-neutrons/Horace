function obj = projaxes(varargin)
% deprecated projaxes function -- adapter to line_proj
warning('HORACE:line_proj:deprecation',...
    'Call to projaxes class is deprecated. Use line_proj instead')

obj = line_proj(varargin{:});
