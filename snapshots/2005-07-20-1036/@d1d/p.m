function [] = p (w, col)
% Plot of a 1D dataset, with the given colour, on an existing plot
%
% Syntax:
%   >> p (w1)
%   >> p (w1, col)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if nargin==1
    p(d1d_to_spectrum(w));
elseif nargin==2
    p(d1d_to_spectrum(w),col);
else
    error('ERROR: Check number of arguments')
end
