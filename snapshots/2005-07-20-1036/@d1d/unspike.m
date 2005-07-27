function wout = unspike (w, v1, v2, v3, v4)
% UNSPIKE  Removes spikes from a 1D dataset
%
% There are four optional parameters: 
%
%   YMIN    If y < ymin then the point is considered a spike [Default: NaN i.e. ignored]
%   YMAX    If y > ymax then the point is considered a spike [Default: NaN i.e. ignored]
%   FAC     If a point is within a factor FAC of both of its neighbours
%          then is NOT a spike [Default: FAC = 2]
%   SFAC    If the difference of a point w.r.t. both of its neighbours is
%          less than SFAC standard deviations then the point is NOT a spike
%          [Default: 5]
%
% Use NaN to skip over an optional parameter (see examples below).
%
% Syntax:
%   >> wout = unspike (w)
%   >> wout = unspike (w, NaN, NaN, 1.5)   % to alter FAC to 1.5

% The help section above should be identical to that for spectrum/unspike

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if (nargin==1)
    wtemp = unspike (d1d_to_spectrum(w));
elseif (nargin==2)
    wtemp = unspike (d1d_to_spectrum(w), v1);
elseif (nargin==3)
    wtemp = unspike (d1d_to_spectrum(w), v1, v2);
elseif (nargin==4)
    wtemp = unspike (d1d_to_spectrum(w), v1, v2, v3);
elseif (nargin==5)
    wtemp = unspike (d1d_to_spectrum(w), v1, v2, v3, v4);            
else
    error ('Check number of arguments')
end
wout = combine_d1d_spectrum (w, wtemp);
