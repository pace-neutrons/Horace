function [wcalc, p, dp, fixed]= fromfit (win)
% Returns a 1D dataset with the y values calculated at the x-values of an
% input 1D dataset using the latest parameters and function in Mfit.
%
% Syntax:
%   >> wcalc = fromfit (w)                    % most common use
%
%   >> [wcalc, p, dp, fixed] = fromfit (w)    % to recover parameter values etc.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if numel(w)>1
    error('Mfit only able to compute for a single D1D - array input not possible')
end

if nargout==1
    [wtemp]= fromfit (d1d_to_spectrum(win));
elseif nargout==2
    [wtemp, p]= fromfit (d1d_to_spectrum(win));
elseif nargout==3
    [wtemp, p, dp]= fromfit (d1d_to_spectrum(win));
elseif nargout==4
    [wtemp, p, dp, fixed]= fromfit (d1d_to_spectrum(win));
else
    error ('Check number of output arguments')
end
wcalc = combine_d1d_spectrum (win, wtemp);
