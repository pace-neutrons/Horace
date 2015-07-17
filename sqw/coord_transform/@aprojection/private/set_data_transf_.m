function proj = set_data_transf_(proj,data)

proj.alatt_=data.alatt;
proj.angdeg_=data.angdeg;
%
proj.data_u_to_rlu_    = data.u_to_rlu; %(4x4)
proj.data_uoffset_     = data.uoffset;  %(4x1)
proj.data_upix_to_rlu_ = data.upix_to_rlu;
proj.data_upix_offset_ = data.upix_offset;
proj.data_lab_         = data.ulabel;
proj.data_ulen_        = data.ulen;


