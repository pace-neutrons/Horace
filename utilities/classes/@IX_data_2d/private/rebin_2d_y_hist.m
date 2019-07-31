function [sout,eout] = rebin_2d_y_hist (x, s, e, xout, use_mex, force_mex)
% Rebins histogram data along axis iax=2 of an IX_dataset_nd with dimensionality ndim=2.
%
%   >> [sout,eout] = rebin_2d_y_hist (x, s, e, xout, use_mex, force_mex)
%
%   x           Rebin axis bin boundaries
%   s           Signal array
%   e           Standard deviations on signal array
%   xout        Output rebin axis bin boundaries
%   use_mex     Determine if should try mex file implementation first
%              if use_mex==true:  use mex file implementation
%              if use_mex==false: use matlab implementation
%   force_mex   If use_mex==true, determine if forces mex only, only allows matlab implementation to catch error
%              if force_mex==true: do not allow matlab implementation to catch error
%              if force_mex==false: allow matlab to catch on error condition in call to mex file
%
% Output:
% -------
%   sout        Integrated signal
%   eout        Standard deviations on integrated signal

if use_mex
    try
        [sout,eout] = rebin_2d_y_hist_mex (x, s, e, xout);
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
    [sout,eout] = rebin_2d_y_hist_matlab (x, s, e, xout);
end
