function [wout_s, wout_e] = rebin_hist(iax,x, s, e, xout, use_mex, force_mex)
% Rebins histogram data along specific axis.
if iax ~=1
    error('IX_data_1d:invalid_argument',...
        'rebinning along axis number=%d but for 1D dataset it can be only 1',iax);
end
[wout_s,wout_e] = rebin_hist_(x, s, e, xout, use_mex, force_mex);

