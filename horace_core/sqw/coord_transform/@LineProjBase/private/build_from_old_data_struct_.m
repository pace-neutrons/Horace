function proj =  build_from_old_data_struct_(proj,data_struct,varargin)
% build projection from a structure, stored by previous version(s) of Horace
%
if isfield(data_struct,'ulabel')
    data_struct.label = data_struct.ulabel;
end
if isfield(data_struct,'u_to_rlu_legacy')
    data_struct.u_to_rlu  = data_struct.u_to_rlu_legacy;
end

if isfield(data_struct,'ulen')
    data_struct.img_scales = data_struct.ulen;
end
if isfield(data_struct,'uoffset')
    data_struct.offset = data_struct.uoffset;
    data_struct = rmfield(data_struct,'uoffset');
end
if  isfield(data_struct,'u_to_rlu')
    proj = ubmat_proj();
end
proj = proj.from_bare_struct(data_struct);
