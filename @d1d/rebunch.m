function wout = rebunch(w, v1)
% REBUNCH - rebunch data points into groups of nbin points.
%
% Syntax:
%
%   >> w_out = rebunch(w_in, nbin)   rebunches the data of W_IN in groups of nbin
%
%   >> w_out = rebunch(w_in)         same as NBIN=1 i.e. W_OUT is just a copy of W_IN
%

% The help section above should be identical to that for spectrum/rebunch

if (nargin==1)
    wout = w;
elseif (nargin == 2)
    wtemp = rebunch (d1d_to_spectrum(w), v1);
    wout = combine_d1d_spectrum (w, wtemp);
else
    error ('Check number of arguments')
end
