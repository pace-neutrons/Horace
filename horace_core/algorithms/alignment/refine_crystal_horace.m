function varargout = refine_crystal_horace(varargin)
% DEPRECATED; USE refine_crystal
% Refine crystal orientation and lattice parameters for an sqw object.

% Original author: T.G.Perring

warning('HORACE:refine_crystal:deprecated', ...
        'refine_crystal_horace has been deprecated in favour of `refine_crystal`');

varargout = refine_crystal(varargin{:});

end
