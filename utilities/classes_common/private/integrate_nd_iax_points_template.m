function [sout,eout] = integrate_nd_iax_points_template (x, s, e, xout, use_mex, force_mex)
% Integrate point data along axis iax=1 of an IX_dataset_nd with dimensionality ndim=1.
%
%   >> [sout,eout] = integrate_nd_iax_points_template (x, s, e, xout, use_mex, force_mex)
%
%   x       
%
if use_mex
    try
        [sout,eout] = integrate_nd_iax_points_mex (x, s, e, xout);
    catch
        if ~force_mex
            display(['Error calling mex function ',mfilename,'_mex. Calling matlab equivalent'])
            use_mex=true;
        end
    end
end

if ~use_mex
    [sout,eout] = integrate_nd_iax_points_matlab (x, s, e, xout);
end
