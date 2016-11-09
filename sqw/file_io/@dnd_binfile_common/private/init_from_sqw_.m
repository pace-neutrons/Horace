function obj=init_from_sqw_(obj,varargin)
% Initialize the dnd strucute of sqw or dnd file for subsequent write operations
% using  data part of sqw object, stored in memory.
%
%
% $Revision$ ($Date$)
%
%
dnd_2save = varargin{1};
%
%
%warning('off','MATLAB:structOnObject')
%data = struct(dnd_2save); %TODO: necessary util dnd data do not have all accessors
% to read data from class. When they do, this should be fixed. sqw data
% already works without this crap
%warning('on','MATLAB:structOnObject')

%
if strcmp(obj.data_type_,'undefined')
    obj.data_type_ = 'b+';
end
dim = size(dnd_2save.s);
if numel(dim) == 2
    if dim(1) == 1
        dim = dim(2);
    elseif dim(2) == 1
        dim = dim(1);
    end
end
obj.dnd_dimensions_ = dim;
obj.num_dim_ = numel(obj.dnd_dimensions_);
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
