function [] = d (w, col)
% Creates a new plot of a 1D dataset, with the given colour
%
% Syntax:
%   >> d (w1)
%   >> d (w1, col)

if nargin==1
    d(d1d_to_spectrum(w));
elseif nargin==2
    d(d1d_to_spectrum(w),col);
else
    error('ERROR: Check number of arguments')
end
