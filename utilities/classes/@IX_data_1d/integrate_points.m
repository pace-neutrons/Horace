function  [wout_s,wout_e] = integrate_points(iax,x, s, e, xout, use_mex, force_mex)
%Integrates point data along along specific axis.
if iax ~=1
    error('IX_data_1d:invalid_argument',...
        'integrating along axis number=%d but for 1D dataset it can be only 1',iax);
end
[wout_s,wout_e] = integrate_1d_points (x, s, e, xout, use_mex, force_mex) ;

