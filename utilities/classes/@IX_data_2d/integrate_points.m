function  [wout_s,wout_e] = integrate_points(iax,x, s, e, xout, use_mex, force_mex)
%Integrates point data along along specific axis.
switch iax
    case(1)
        [wout_s,wout_e] = integrate_2d_x_points (x, s, e, xout, use_mex, force_mex);
    case(2)
        [wout_s,wout_e] = integrate_2d_y_points(x, s, e, xout, use_mex, force_mex);
    otherwise
        error('IX_data_2d:invalid_argument',...
            'integration axis number=%d but for 2D dataset it can be only 1 or 2',iax);
end
