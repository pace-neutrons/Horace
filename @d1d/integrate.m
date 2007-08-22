function wout = integrate(w, varargin)
% INTEGRATE  Integrate a 1D dataset between two limits
%
% Syntax:
%   >> ans = integrate (w)              % integrate over full range
%   >> ans = integrate (w, xlo, xhi)    % integrate between selected range

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

wout = dnd_data_op(win, @integrate, 'd1d' , 1, varargin{:});
