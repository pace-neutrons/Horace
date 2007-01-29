function de(w,xlo,xhi,ylo,yhi)
% DE Draws a plot of error bars for a 1D dataset
%
%   >> de(w)
%   >> de(w,xlo,xhi)
%   >> de(w,xlo,xhi,ylo,yhi)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if (nargin==1)
    de (d1d_to_spectrum(w));
elseif (nargin==3)
    de (d1d_to_spectrum(w),xlo,xhi);
elseif (nargin==5)
    de (d1d_to_spectrum(w),xlo,xhi,ylo,yhi);
else
    error ('Wrong number of arguments to DE')
end