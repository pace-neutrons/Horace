function qk_mat =  qk_matrix_DGfermi (wi, wf, d_mat, spec_to_rlu, k_to_e)

npix = numel(wi);

% Matrix to convert deviations in ki and kf into deviations in Q and eps
% ----------------------------------------------------------------------
qk_mat = zeros(4,6,npix);
qk_mat(1:3,1:3,:) = spec_to_rlu;
qk_mat(1:3,4:6,:) = -mtimesx_horace(spec_to_rlu,permute(d_mat,[2,1,3]));  % inverse of d_mat(:,:,i) is transpose of same
qk_mat(4,1,:) = (2*k_to_e)*wi;
qk_mat(4,4,:) =-(2*k_to_e)*wf;

