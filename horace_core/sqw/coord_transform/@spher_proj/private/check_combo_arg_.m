function obj = check_combo_arg_(obj)
% Check validity of interdependent fields and construct proper transformation matrix
% for spherical coordinates conversion
%
%   >> obj = check_combo_arg(w)
%
% Throws HORACE:spher_proj:invalid_argument with the message
% suggesting the reason for failure if the inputs are incorrect
% w.r.t. each other.
%
% Normalizes input vectors to unity and constructs the
% transformation to new coordinate system when operation is
% successful
%
% first axis (z in spherical coordinate system) goes first
% and second axis (x in spherical coordinate system) goes second
e12 = [obj.ez_(:),obj.ex_(:)];
if obj.alatt_defined && obj.angdeg_defined
    bm = obj.bmatrix();
else
    bm = eye(3);
end
uv_cc = bm*e12;
uv_norm(:,1) = uv_cc(:,1)/norm(uv_cc(:,1));
uv_norm(:,2) = uv_cc(:,2)/norm(uv_cc(:,2));
e3 = cross(uv_norm(:,1),uv_norm(:,2));
ne3 = norm(e3);
if ne3 < obj.tol_
    error('HORACE:spher_proj:invalid_argument', ...
        'Input vectors ez(%s) and ex(%s) are parallel or almost parallel to each other', ...
        mat2str(e12(:,2)),mat2str(e12(:,1)));
end
e3 = e3/ne3; % should be 1 anyway, just in case to reduce round-off errors
e2 = cross(e3,uv_norm(:,1));

transf_mat = [uv_norm(:,1),e2/norm(e2),e3];
%TODO:  #954 scientific validation needed
obj.pix_to_matlab_transf_ = obj.hor2matlab_transf_*transf_mat';
