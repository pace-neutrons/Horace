function varargout = fake_sqw(varargin)
% DEPRECATED; USE dummy_sqw
% Create an output sqw file with dummy data using array(s) of energy bins instead spe file(s).

% Original author: T.G.Perring

warning('HORACE:fake_sqw:deprecated', ...
        'fake_sqw has been deprecated in favour of `dummy_sqw`');

varargout = dummy_sqw(varargin{:});

end
