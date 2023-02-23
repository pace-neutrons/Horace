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

ez = obj.ez/norm(obj.ez);
obj.ez_ = ez;

ey = obj.ey;
ex = cross(ez,ey);
nex = norm(ex);
if nex < obj.tol_
    error('HORACE:spher_proj:invalid_argument', ...
        'Input vectors ez(%s) and ex(%s) are parallel or almost parallel to each other', ...
        disp2str(ez),disp2str(ex));
end
ex = ex/nex;
ey = cross(ex,ez);
obj.ey_ = ey/norm(ey);
transf_mat = [ez;ey;ex];
obj.pix_to_matlab_transf_ = obj.hor2matlab_transf_*transf_mat;
