function [wout_s, wout_e] = rebin_hist(iax,x, s, e, xout, use_mex, force_mex)
% Rebins histogram data along specific axis.
%
% Overcomplicated but follows minimal change rules
switch iax
    case(1)
        [wout_s,wout_e] = rebin_3d_x_hist (x, s, e, xout, use_mex, force_mex);
    case(2)
        [wout_s,wout_e] = rebin_3d_y_hist (x, s, e, xout, use_mex, force_mex);
    case(3)
        [wout_s,wout_e] = rebin_3d_z_hist (x, s, e, xout, use_mex, force_mex);
    otherwise
        error('IX_data_3d:invalid_argument',...
            'rebin axis number=%d but for 3D dataset it can be ony 1,2 or 3',iax);
end
