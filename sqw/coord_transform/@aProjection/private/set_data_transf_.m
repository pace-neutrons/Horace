function proj = set_data_transf_(proj,data,upix_to_rlu,upix_offset)
% Retrieve all parameters for transformation already
% defined over sqw data and store them in projection to
% use later with new transformation.
%
% $Revision$ ($Date$)
%

if size(upix_to_rlu) ~= [3 3]
    error('APROJECTION:invalid_argument','aProjection: set_data_transf: upix_to_rlu should be 3x3 matrix')
end
%
if size(upix_offset) ~= [4 1]
    error('APROJECTION:invalid_argument','aProjection: set_data_transf: upix_offset should be 4x1 vector')
end


proj.alatt_=data.alatt;
proj.angdeg_=data.angdeg;
%
% existing transformation -- currently can be only rectangular one 
proj.data_u_to_rlu_    = data.u_to_rlu; %(4x4)
proj.data_uoffset_     = data.uoffset;  %(4x1)
proj.data_lab_         = data.ulabel;
proj.data_ulen_        = data.ulen;

proj.data_iax_         = data.iax;
proj.data_pax_         = data.pax;
proj.data_iint_        = data.iint;
proj.data_p_           = data.p;



proj.data_upix_to_rlu_ = upix_to_rlu;
proj.data_upix_offset_ = upix_offset;



