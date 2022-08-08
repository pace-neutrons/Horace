function proj =  build_from_old_data_struct_(data_struct,header_av)

if isfield(data_struct,'alatt')
    alatt=data_struct.alatt;
    angdeg=data_struct.angdeg;
else % old binary file format (prototype)
    alatt = [2*pi,2*pi,2*pi];
    angdeg= [90,90,90];
end
if ~isempty(header_av)
    bmat_inv_ext  =  header_av.u_to_rlu;
else
    bmat_inv_ext   = [];
    %bmat =     bmatrix(alatt,angdeg);
end
if isfield(data_struct,'ulabel')
    data_struct.label = data_struct.ulabel;
end

proj=ortho_proj('alatt',alatt,'angdeg',angdeg,'label',data_struct.label);
%

proj = proj.set_from_data_mat(data_struct.u_to_rlu(1:3,1:3),data_struct.ulen(1:3));
if isfield(data_struct,'offset')
    proj.offset = data_struct.offset;
elseif isfield(data_struct,'uoffset')
    proj.offset = data_struct.uoffset;
end

%--------------------------------------------------------------------------
% TODO: this is compatibility function to support alignment.
% This will change when alginment matrix is attached to pixels
if ~isempty(bmat_inv_ext)
    proj = proj.set_ub_inv_compat(bmat_inv_ext(1:3,1:3));
end


