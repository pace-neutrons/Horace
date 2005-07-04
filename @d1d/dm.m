function dm(w,xlo,xhi,ylo,yhi)
% DM Draws a marker plot of a 1D dataset
%
%   dm(w)
%   dm(w,xlo,xhi)
%   dm(w,xlo,xhi,ylo,yhi)

% Check spectrum is not an array
if length(w)>1
    error ('This function only plots a single 1D dataset - check length of spectrum array')
end

if (nargin==1)
    dm (d1d_to_spectrum(w));
elseif (nargin==3)
    dm (d1d_to_spectrum(w),xlo,xhi);
elseif (nargin==5)
    dm (d1d_to_spectrum(w),xlo,xhi,ylo,yhi);
else
    error ('Wrong number of arguments to DM')
end