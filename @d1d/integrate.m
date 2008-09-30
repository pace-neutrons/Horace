function wout = integrate(w, xlo, xhi)
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

if (nargin==1)
    wout = integrate(d1d_to_spectrum(w));
elseif (nargin==3)
    if (~isa(xlo,'double') | ~isa(xhi,'double'))
        error ('integration limits must be real')
    end
    wout = integrate(d1d_to_spectrum(w), xlo, xhi);
else
    error ('wrong number of arguments')
end
