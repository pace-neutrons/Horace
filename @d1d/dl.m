function dl(w,xlo,xhi,ylo,yhi)
% DL Draws a plot of a 1D dataset
%
%   >> dl(w)
%   >> dl(w,xlo,xhi)
%   >> dl(w,xlo,xhi,ylo,yhi)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if (nargin==1)
    dl (d1d_to_spectrum(w));
elseif (nargin==3)
    dl (d1d_to_spectrum(w),xlo,xhi);
elseif (nargin==5)
    dl (d1d_to_spectrum(w),xlo,xhi,ylo,yhi);
else
    error ('Wrong number of arguments to DL')
end