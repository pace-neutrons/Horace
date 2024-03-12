function proj =  build_from_old_data_struct_(proj,data_struct,varargin)
% build projection from a structure, stored by previous version(s) of Horace
%
if isfield(data_struct,'ulabel')
    data_struct.label = data_struct.ulabel;
end
if isfield(data_struct,'u_to_rlu_legacy')
    data_struct.u_to_rlu  = data_struct.u_to_rlu_legacy;
end
use_u_to_rlu_transitional =  isfield(data_struct,'u_to_rlu');
if use_u_to_rlu_transitional 
    proj = ubmat_proj(data_struct);
else
    proj = proj.from_bare_struct(data_struct);
end

