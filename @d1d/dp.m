function dp(w,xlo,xhi,ylo,yhi)
% DP Draws a plot of markers and error bars for a 1D dataset
%
%   >> dp(w)
%   >> dp(w,xlo,xhi)
%   >> dp(w,xlo,xhi,ylo,yhi)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

% Check spectrum is not an array
if length(w)>1
    error ('This function only plots a single 1D dataset - check length of spectrum array')
end

if (nargin==1)
    dp (d1d_to_spectrum(w));
elseif (nargin==3)
    dp (d1d_to_spectrum(w),xlo,xhi);
elseif (nargin==5)
    dp (d1d_to_spectrum(w),xlo,xhi,ylo,yhi);
else
    error ('Wrong number of arguments to DP')
end