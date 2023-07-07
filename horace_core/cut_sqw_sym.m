function varargout = cut_sqw_sym(varargin)
%% DEPRECATED USE CUT
%
% Take a cut from an sqw object, with symmetrisation, by integrating over one or more axes.
%
% Simple alias to cut

warning('HORACE:cut_sqw_sym:deprecated', ...
        '`cut_sqw_sym` is deprecated in favour of `cut`');

varargout = cut(varargin{:});

end
