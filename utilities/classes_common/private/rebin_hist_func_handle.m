function handle=rebin_hist_func_handle(ndim,iax)
% Get function handle for rebinning histogram data along axis iax of ndim array

if ndim==1
    if iax==1
        handle=@rebin_1d_hist;
    else
        error(['Rebin along axis iax=',num2str(iax),' for dimensionality ndim=',num2str(ndim),' is not supported'])
    end
elseif ndim==2
    if iax==1
        handle=@rebin_2d_x_hist;
    elseif iax==2
        handle=@rebin_2d_y_hist;
    else
        error(['Rebin along axis iax=',num2str(iax),' for dimensionality ndim=',num2str(ndim),' is not supported'])
    end
elseif ndim==3
    if iax==1
        handle=@rebin_3d_x_hist;
    elseif iax==2
        handle=@rebin_3d_y_hist;
    elseif iax==3
        handle=@rebin_3d_z_hist;
    else
        error(['Rebin along axis iax=',num2str(iax),' for dimensionality ndim=',num2str(ndim),' is not supported'])
    end
else
    error(['Dimensionality ndim=',num2str(ndim),' is not currently supported'])
end
