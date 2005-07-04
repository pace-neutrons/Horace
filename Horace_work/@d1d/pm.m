function pm(w)
% PM Draws a marker plot of a 1D dataset on an existing plot
%
%   pm(w)
%

% Check spectrum is not an array
if length(w)>1
    error ('This function only plots a single 1D dataset - check length of spectrum array')
end

pm(d1d_to_spectrum(w))