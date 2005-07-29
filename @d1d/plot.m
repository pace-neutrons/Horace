function [wtemp] = plot (w, col)
% Creates a new plot of a 1D dataset, with the given colour.
%
% Syntax:
%   >> plot (w1)
%   >> plot (w1, col)
%
% [Note: equivalent to the plot function 'd', included for consistency
% with corresponding plot function for two and three dimensional datasets]


% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if nargin==1
    d(d1d_to_spectrum(w));
elseif nargin==2
    d(d1d_to_spectrum(w),col);
else
    error('ERROR: Check number of arguments')
end
