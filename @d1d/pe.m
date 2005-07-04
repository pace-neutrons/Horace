function pe(w)
% PE Draws a plot of error bars for a 1D dataset on an existing plot
%
%   pe(w)
%

% Check spectrum is not an array
if length(w)>1
    error ('This function only plots a single 1D dataset - check length of spectrum array')
end

pe(d1d_to_spectrum(w))
