function dh(w,xlo,xhi,ylo,yhi)
% DH Draws a histogram of a 1D dataset
%
%   >> dh(w)
%   >> dh(w,xlo,xhi)
%   >> dh(w,xlo,xhi,ylo,yhi)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if (nargin==1)
    dh (d1d_to_spectrum(w));
elseif (nargin==3)
    dh (d1d_to_spectrum(w),xlo,xhi);
elseif (nargin==5)
    dh (d1d_to_spectrum(w),xlo,xhi,ylo,yhi);
else
    error ('Wrong number of arguments to DH')
end