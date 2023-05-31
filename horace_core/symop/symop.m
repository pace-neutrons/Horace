function obj = symop (varargin)
%% Deprecated function
% use Symop.create
    warning('HORACE:symop:deprecated', 'symop is deprecated in favour of Symop.create');
    obj = Symop.create(varargin{:});
end
