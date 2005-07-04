function [] = p (w, col)
% Plot of a 1D dataset, with the given colour, on an existing plot
%
% Syntax:
%   >> d (w1)
%   >> d (w1, col)

if nargin==1
    p(d1d_to_spectrum(w));
elseif nargin==2
    p(d1d_to_spectrum(w),col);
else
    error('ERROR: Check number of arguments')
end
