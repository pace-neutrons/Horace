function obj = projaxes(varargin)
% deprectated projaxes function -- adapter to ortho_proj
warning('HORACE:ortho_proj:deprecation',...
    'Call to projaxes class is deprecated. Use ortho_proj instead')

obj = ortho_proj(varargin{:});
