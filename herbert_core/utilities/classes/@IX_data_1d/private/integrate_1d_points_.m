function [sout,eout] = integrate_1d_points_ (x, s, e, xout)
% Integrates point data along axis iax=1 of an IX_dataset_nd with dimensionality ndim=1.
%
%   >> [sout,eout] = integrate_1d_points_ (x, s, e, xout)
%
% Input:
% ------
%   x       Integration axis coordinates of points
%   s       Signal array
%   e       Standard deviations on signal array
%   xout    Array of integration axis coordinates between which to integrate
%          e.g. [x1,x2,x3,x4] outputs integrals in the range x1 to x2, x2 to x3, and x3 to x4
%           resulting in an array of integrals in output array sout (below) of length 3
%
% Output:
% -------
%   sout    Integrated signal
%   eout    Standard deviations on integrated signal
%

% Call the instance of integrate_1d_points in utilities/maths
[sout, eout] = integrate_1d_points(x, s, e, xout);
