function [x2, detdcn, d_mat, f_mat] = detector_info (det, ielmts)
% Function to get properties and output of methods of IX_detector_array as
% required for Tobyfit. Collected in one function so that it can most
% efficiently be called using object_lookup/func_eval_ind
%
%   >> [x2, detdcn, d_mat, f_mat] = detector_info (det, ielmts)
%
%

% Call output only for the required number of output arguments. This could be a
% fairly expensive function to call
nout = nargout;     % number of output arguments in the caller

% Fill output arguments
x2 = det.x2(ielmts);    % get first output regardless - so argumnet 'ans' is filled

if nout>=2
    detdcn_all = det_direction (det);
    detdcn = detdcn_all(:,ielmts);
end

if nout>=3
    d_mat  = det.dmat(:,:,ielmts);
end

if nout>=4
    f_mat_all = spec_to_secondary (det);
    f_mat = f_mat_all(:,:,ielmts);
end
