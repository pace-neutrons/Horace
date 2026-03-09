function obj = check_and_caclulate_vectors_and_R_(obj)
% part of check_combo_par method.
%
% Checks units of normvec and u,v vectors as function of class state
%
Bmat = obj.b_matrix_;
use_bmat = ~isempty(Bmat);
if ~use_bmat
    Bmat = eye(3);
end

if obj.set_from_normvec_
    [obj.u_,obj.v_,obj.normvec_,input_nrmv_in_rlu] = ...
        SymopSetPlaneInterface.get_uv_from_normvec(obj.normvec_,obj.input_nrmv_in_rlu_,Bmat);
    if use_bmat % b-mat was defined so we can now rely on u,v plane for further operations
        obj.set_from_normvec_ = false;
        obj.input_nrmv_in_rlu_ = input_nrmv_in_rlu;
    end
else
    if use_bmat % if set from uv and bmat available, normvec is always cc
        obj.input_nrmv_in_rlu_ = false;
    end
    obj = set_normvec_from_uv(obj,use_bmat,Bmat);
end
obj.R_ = obj.calculate_transform();

end

%
function obj = set_normvec_from_uv(obj,use_bmat,Bmat)
% given u/v vectors, define normal vector to them
%
if norm(cross(obj.u_, obj.v_)) < 1e-6
    error('HORACE:SymopReflection:invalid_argument', ...
        'Vectors u=%s and v=%s are collinear', ...
        disp2str(obj.u_'),disp2str(obj.v_'));
end

if ~use_bmat
    e1 = obj.u_;
    e2 = obj.v_;
else
    e1 = Bmat * obj.u_;
    e2 = Bmat * obj.v_;
end
n = cross(e1,e2);
obj.normvec_ = n / norm(n);
end
