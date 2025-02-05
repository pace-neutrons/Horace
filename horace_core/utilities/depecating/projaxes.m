function obj = projaxes(varargin)
% deprecated projaxes function -- adapter to line_proj
warning('HORACE:line_proj:deprecated',...
    '"projaxes" class is deprecated. Use "line_proj" class instead')

obj = line_proj(varargin{:});

end
