function [wout_s, wout_e] = rebin_hist(iax,x, s, e, xout, use_mex, force_mex)
% Rebins histogram data along specific axis.
%
% Overcomplicated but follows minimal change rules
switch iax
    case(1)
        [wout_s,wout_e] = rebin_2d_x_hist (x, s, e, xout, use_mex, force_mex);
    case(2)
        [wout_s,wout_e] = rebin_2d_y_hist (x, s, e, xout, use_mex, force_mex);
    otherwise
        error('IX_data_2d:invalid_argument',...
            'integration axis number=%d but for 2D dataset it can be only 1 or 2',iax);
end
