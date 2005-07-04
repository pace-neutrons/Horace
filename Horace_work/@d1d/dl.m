function dl(w,xlo,xhi,ylo,yhi)
% DL Draws a plot of a 1D dataset
%
%   dl(w)
%   dl(w,xlo,xhi)
%   dl(w,xlo,xhi,ylo,yhi)

% Check spectrum is not an array
if length(w)>1
    error ('This function only plots a single 1D dataset - check length of spectrum array')
end

if (nargin==1)
    dl (d1d_to_spectrum(w));
elseif (nargin==3)
    dl (d1d_to_spectrum(w),xlo,xhi);
elseif (nargin==5)
    dl (d1d_to_spectrum(w),xlo,xhi,ylo,yhi);
else
    error ('Wrong number of arguments to DL')
end