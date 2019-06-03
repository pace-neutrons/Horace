function obj=init_from_sqw_(obj,varargin)
% Initialize the dnd strucute of sqw or dnd file for subsequent write operations
% using  data part of sqw object, stored in memory.
%
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
%
%
dnd_2save = varargin{1};
%
if strcmp(obj.data_type_,'undefined')
    obj.data_type_ = 'b+';
end
%
[dim,ndim] = calc_proper_ndim_(dnd_2save);
obj.dnd_dimensions_ = dim;
obj.num_dim_ = ndim;
%
%
format = obj.get_dnd_form();
[data_pos,pos] = obj.sqw_serializer_.calculate_positions(format,dnd_2save,obj.data_pos_);


obj.s_pos_=data_pos.s_pos_;
obj.e_pos_=data_pos.e_pos_;
obj.npix_pos_=data_pos.npix_pos_;
%
if isfield(data_pos,'urange_pos_')
    obj.dnd_eof_pos_ = data_pos.urange_pos_;
    if  isfield(data_pos,'pix_pos_')
        data_pos.eof_pix_pos_ = pos;
    end
else
    obj.dnd_eof_pos_ = pos;
end
obj.data_fields_locations_=data_pos;

