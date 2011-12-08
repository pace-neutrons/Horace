function handle=integrate_points_func_handle(ndim,iax)
% Get function handle for integrating point data along axis iax of ndim array

if ndim==1
    if iax==1
        handle=@integrate_1d_points;
    else
        error(['Integration along axis iax=',num2str(iax),' for dimensionality ndim=',num2str(ndim),' is not supported'])
    end
elseif ndim==2
    if iax==1
        handle=@integrate_2d_x_points;
    elseif iax==2
        handle=@integrate_2d_y_points;
    else
        error(['Integration along axis iax=',num2str(iax),' for dimensionality ndim=',num2str(ndim),' is not supported'])
    end
elseif ndim==3
    if iax==1
        handle=@integrate_3d_x_points;
    elseif iax==2
        handle=@integrate_3d_y_points;
    elseif iax==3
        handle=@integrate_3d_z_points;
    else
        error(['Integration along axis iax=',num2str(iax),' for dimensionality ndim=',num2str(ndim),' is not supported'])
    end
else
    error(['Dimensionality ndim=',num2str(ndim),' is not currently supported'])
end
