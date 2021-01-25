function obj = init_dnd_structure_field_by_field_(obj,varargin)
% function to read dnd version-2 file structure to initialize binary input
% and identify the positions of various pieces of data within the binary
% file
%
% To overload, host should correctly set the obj.data_pos_ field.
%
%
%
%

% all necessary checks have been done in common_init_logic
pos = obj.data_pos_;
%
fseek(obj.file_id_,pos,'bof');
check_and_throw_error(obj,'error moving to data start position');


% data format
data_header = obj.get_dnd_form();
[data_pos,pos,io_error,data_header] =  obj.sqw_serializer_.calculate_positions(data_header,obj.file_id_,pos);
if io_error
    if ~isfield(data_pos,'s_pos_') || ~isfield(data_pos,'e_pos_')
        error('SQW_FILE_IO:io_error',...
            'DND_BINFILE_COMMON: IO error while parsing data, can not indetify location of signal and error arrays')
    end
end
%
obj.dnd_dimensions_ = double(data_header.p_size.field_value);
if ischar(obj.num_dim_) % un-initialized as prototype format does not have dimensions in header
    obj.num_dim_ = double(numel(data_header.p_size.field_value));
end
obj.data_fields_locations_ = data_pos;
%
obj.s_pos_=data_pos.s_pos_;
obj.e_pos_=data_pos.e_pos_;
obj.dnd_eof_pos_ = pos;
if ~io_error
    obj.npix_pos_=data_pos.npix_pos_;
    obj.data_type_ = 'b+';
else
    if ~isfield(data_pos,'npix_pos_')
        obj.data_type_ = 'b';
        obj=set_filepath(obj);
        return
    end
    obj.data_type_ = 'b+';
end

obj=set_filepath(obj);
% Check it
obj.real_eof_pos_ = pos;


function obj=set_filepath(obj)

[path,name,ext]=fileparts(fopen(obj.file_id_));
obj.filename_=[name,ext];
obj.filepath_=[path,filesep];

function check_and_throw_error(obj,mess_pos)
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('SQW_FILE_IO:io_error',...
        '%s: Reason %s',mess_pos,mess)
end

