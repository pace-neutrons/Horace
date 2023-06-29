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
exz = [obj.ex_(:),obj.ez_(:)];
if obj.alatt_defined && obj.angdeg_defined
    bm = obj.bmatrix();
else
    bm = eye(3);        
end
uv_cc = bm*exz;
uv_norm(:,1) = uv_cc(:,1)/norm(uv_cc(:,1));
uv_norm(:,2) = uv_cc(:,2)/norm(uv_cc(:,2));
ey = cross(uv_norm(:,2),uv_norm(:,1));
ney = norm(ey);
if ney < obj.tol_
    error('HORACE:spher_proj:invalid_argument', ...
        'Input vectors ez(%s) and ex(%s) are parallel or almost parallel to each other', ...
        mat2str(exz(:,2)'),mat2str(exz(:,1)'));
end
ey = ey/ney; % should be 1 anyway, just in case to reduce round-off errors
ex = cross(ey,uv_norm(:,2));

transf_mat = [ex/norm(ex);ey;uv_norm(:,2)];
%TODO:  #954 scientific validation needed
obj.pix_to_matlab_transf_ = obj.hor2matlab_transf_*transf_mat;
