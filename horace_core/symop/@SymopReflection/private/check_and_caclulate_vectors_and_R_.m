function obj = check_and_caclulate_vectors_and_R_(obj)
%
Bmat = obj.b_matrix_;
use_bmat = ~isempty(Bmat);
if ~use_bmat
    obj.nrmv_in_rlu_ = true; % no choice,but have it in rlu
    Bmat = eye(3);
end

if obj.set_from_normvec_
    [obj.u_,obj.v_,obj.normvec_] = Symop.get_uv_from_normvec(obj.normvec_,obj.nrmv_in_rlu,Bmat);
else
    if use_bmat % if set from uv and bmat available, normvec is always cc
        obj.nrmv_in_rlu_ = false;
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
