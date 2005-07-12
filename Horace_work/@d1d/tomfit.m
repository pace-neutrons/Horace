function tomfit (w, xrange, p, fixed)
% This function is used to send data contained in 1D dataset to Mfit
% to be be fitted interactively.
%
% Syntax:
%   >> tomfit (w)
%
%   >> tomfit (w, xrange)
%
%   >> tomfit (w, xrange, p)
%
%   >> tomfit (w, xrange, p, fixed)
%
% where:
%   w       1D dataset to be fitted
%
%   xrange  Array giving a values to be retained for fitting:
%           e.g. [12.3,14.5]            keep data in the range 12.3 =< x =< 14.5
%           e.g. [4.1,5.6;11.2,14.5]    keep 4.1=<x=<5.6 & 11.2=<x=<14.5
%
%   p       Starting parameter values
% 
%   fixed   Array of length(p), the fixed parameters (0: free, 1: fixed)
%           e.g. if 5 parameters, [0,1,1,0,1]  fix 2nd, 3rd, 5th.
%
% If you want to pass parameter values and/or fixed values, but not limit the
% x range, then call as
%
%   >> tomfit (w, [], p, fixed)
% or
%   >> tomfit (w, '', p, fixed)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if (nargin==1)
    tomfit (d1d_to_spectrum(w));
elseif (nargin==2)
    tomfit (d1d_to_spectrum(w), xrange);
elseif (nargin==3)
    tomfit (d1d_to_spectrum(w), xrange, p);
elseif (nargin==4)
    tomfit (d1d_to_spectrum(w), xrange, p, fixed);          
else
    error ('Check number of input arguments')
end
