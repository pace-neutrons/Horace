function  [wout_s,wout_e] = integrate_points(iax,x, s, e, xout, use_mex, force_mex)
%Integrates point data along along specific axis.
switch iax
    case(1)
        [wout_s,wout_e] = integrate_3d_x_points (x, s, e, xout, use_mex, force_mex);
    case(2)
        [wout_s,wout_e] = integrate_3d_y_points(x, s, e, xout, use_mex, force_mex);
    case(3)
        [wout_s,wout_e] = integrate_3d_z_points(x, s, e, xout, use_mex, force_mex);
    otherwise
        error('IX_data_3d:invalid_argument',...
            'integration axis number=%d but for 3D dataset it can be ony 1,2 or 3',iax);
end
