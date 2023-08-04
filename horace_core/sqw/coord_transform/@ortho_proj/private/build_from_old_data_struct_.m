function proj =  build_from_old_data_struct_(proj,data_struct,varargin)
% build projection from a structure, stored by previous version(s) of Horace
%
proj.do_check_combo_arg = false;
if isfield(data_struct,'ulabel')
    data_struct.label = data_struct.ulabel;
end
if isfield(data_struct,'u_to_rlu_legacy')
    data_struct.u_to_rlu  = data_struct.u_to_rlu_legacy;
end
use_u_to_rlu_transitional =  isfield(data_struct,'u_to_rlu');

proj = proj.from_bare_struct(data_struct);

%--------------------------------------------------------------------------
% recover from old data, where u_to_rlu matrix is stored instead of
% projection itself
if use_u_to_rlu_transitional
    % correct transformation seems division from right. There is the difference
    u_transf = inv(data_struct.u_to_rlu(1:3,1:3))/bmatrix(proj.alatt,proj.angdeg);
    proj = proj.set_from_data_mat(u_transf,data_struct.ulen(1:3));
end
% this has to be last operation, as it needs fully defined projection class
% containing the lattice
if isfield(data_struct,'uoffset') 
    data_struct.img_offset = data_struct.uoffset;
end
if isfield(data_struct,'img_offset')
    if isequal(data_struct.img_offset(:),zeros(4,1))
        proj.offset = [];
    else
        proj.img_offset = data_struct.img_offset;
    end
end

proj.do_check_combo_arg = true;
proj = proj.check_combo_arg();
