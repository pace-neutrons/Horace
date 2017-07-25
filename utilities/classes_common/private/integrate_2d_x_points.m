function [sout,eout] = integrate_2d_x_points (x, s, e, xout, use_mex, force_mex)
% Integrates point data along axis iax=1 of an IX_dataset_nd with dimensionality ndim=2.
%
%   >> [sout,eout] = integrate_2d_x_points (x, s, e, xout, use_mex, force_mex)
%
% Input:
% ------
%   x           Integration axis coordinates of points
%   s           Signal array
%   e           Standard deviations on signal array
%   xout        Array of integration axis coordinates between which to integrate
%              e.g. [x1,x2,x3,x4] outputs integrals in the range x1 to x2, x2 to x3, and x3 to x4
%               resulting in an array of integrals in output array sout (below) of length 3
%   use_mex     Determine if should try mex file implementation first
%              if use_mex==true:  use mex file implementation
%              if use_mex==false: use matlab implementation
%   force_mex   If use_mex==true, determine if forces mex only, only allows matlab implementation to catch error
%              if force_mex==true: do not allow matlab implementation to catch error
%              if force_mex==false: allow matlab to catch on error condition in call to mex file
%
% Output:
% -------
%   sout    Integrated signal
%   eout    Standard deviations on integrated signal

if use_mex
    try
        [sout,eout] = integrate_2d_x_points_mex (x, s, e, xout);
    catch ERR
        if ~force_mex
            fprintf('Error %s calling mex function %s_mex. Calling matlab equivalent',ERR.message,mfilename)
            use_mex=false;
        else
            rethrow(ERR)
        end
    end
end

if ~use_mex
    [sout,eout] = integrate_2d_x_points_matlab (x, s, e, xout);
end
