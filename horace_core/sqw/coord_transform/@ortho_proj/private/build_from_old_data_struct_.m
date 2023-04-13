function proj =  build_from_old_data_struct_(proj,data_struct,varargin)

% if ~isempty(header_av)
%     bmat_inv_ext  =  header_av.u_to_rlu;
% else
%     bmat_inv_ext   = [];
%     %bmat =     bmatrix(alatt,angdeg);
% end
if isfield(data_struct,'ulabel')
    data_struct.label = data_struct.ulabel;
end
if isfield(data_struct,'uoffset')
    data_struct.offset = data_struct.uoffset;
end
use_u_to_rlu_transitional = isfield(data_struct,'u_to_rlu');

proj.do_check_combo_arg = false;
proj = proj.from_bare_struct(data_struct);

%--------------------------------------------------------------------------
% recover from old data, where u_to_rlu matrix is stored instead of
% projection itself
if use_u_to_rlu_transitional
    proj = proj.set_from_data_mat(data_struct.u_to_rlu(1:3,1:3),data_struct.ulen(1:3));
end
% if ~isempty(bmat_inv_ext)
%     proj = proj.set_ub_inv_compat(bmat_inv_ext(1:3,1:3));
% end
proj.do_check_combo_arg = true;
proj = proj.check_combo_arg();

