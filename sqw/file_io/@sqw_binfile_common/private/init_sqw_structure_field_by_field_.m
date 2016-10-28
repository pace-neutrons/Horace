function obj = init_sqw_structure_field_by_field_(obj)
% function to read sqw version-2 file structure to initialize binary input
% and identify the positions of various pieces of data within the binary
% file
%
%
% $Revision$ ($Date$)
%
fseek(obj.file_id_,obj.main_header_pos_,'bof');
check_and_throw_error(obj,'Error moving to main data header position');

template_m_header = obj.get_main_header_form();
[main_h_pos,pos,io_error] = obj.sqw_serializer_.calculate_positions(template_m_header,obj.file_id_,obj.main_header_pos_);
if io_error
    error('SQW_BINFILE_COMMON:io_error',...
        'IO error while parsing main header')
end

%
fseek(obj.file_id_,main_h_pos.nfiles_pos_,'bof');
check_and_throw_error(obj,'Error moving to the  number of contributing files fiels position');

n_files = fread(obj.file_id_,1,'int32');
check_and_throw_error(obj,'Error reading number of contributiong files field');
%
obj.num_contrib_files_ = n_files;
%
obj.header_pos_ = zeros(1,n_files);
obj.header_pos_(1) = pos;

template_header = obj.get_header_form();
[header_pos,pos,io_error]=obj.sqw_serializer_.calculate_positions(template_header,obj.file_id_,pos);
if io_error
    error('SQW_BINFILE_COMMON:io_error',...
        'IO error while parsing contributing file firds header')
end
obj.header_pos_info_ = repmat(header_pos,1,n_files);

for i=2:n_files
    obj.header_pos_(i) = pos;
    % [header_pos,pos] =
    [header_pos,pos,io_error]=obj.sqw_serializer_.calculate_positions(template_header,obj.file_id_,pos);
    if io_error
        error('SQW_BINFILE_COMMON:io_error',...
            'IO error while parsing contributing file N%d header',i)
    end
    obj.header_pos_info_(i) = header_pos;
end
obj.detpar_pos_ = pos;
%
detpar_header = obj.get_detpar_form();
% [detpar_pos,pos]
[detpar_pos_info,pos,io_error] = obj.sqw_serializer_.calculate_positions(detpar_header,obj.file_id_,pos);
obj.data_pos_ = pos;
obj.detpar_pos_info_ = detpar_pos_info;
if io_error
    error('SQW_BINFILE_COMMON:io_error','IO error while parsing detector information')
end

% data block
data_header = obj.get_data_form();
[data_pos,pos,io_error,data_header] =  obj.sqw_serializer_.calculate_positions(data_header,obj.file_id_,pos);
if io_error
    if ~isfield(data_pos,'s_pos_') || ~isfield(data_pos,'e_pos_')
        error('SQW_BINFILE_COMMON:io_error',...
            'IO error while parsing data, can not indetify location of signal and error arrays')
    end
end
if obj.num_dim == 'uninitiated' % prototype does not have dimensions in data header,
    % so need to get num dims from p-array size
    obj.num_dim_ = numel(data_header.p_size.field_value);
end
if ischar(obj.dnd_dimensions)
    obj.dnd_dimensions_ = double(data_header.p_size.field_value);
end
%
obj.npixels_ = [];
obj.s_pos_=data_pos.s_pos_;
obj.e_pos_=data_pos.e_pos_;
obj.eof_pix_pos_ = pos;
if ~io_error
    obj.npix_pos_=data_pos.npix_pos_;
    obj.urange_pos_=data_pos.urange_pos_;
    obj.pix_pos_=data_pos.pix_pos_+8;  % pixels are written with their size in front of the array.
    % subsequent methods read pixes directrly, so here we shift pixel
    % position by the array length
    obj.data_type_ = 'a';
else
    if ~isfield(data_pos,'npix_pos_')
        obj.data_type_ = 'b';
        obj=set_filepath(obj);
        return
    end
    obj.data_type_ = 'b+';
    if ~isfield(data_pos,'pix_pos_')
        obj.data_type_ = 'a-';
        obj=set_filepath(obj);
        return;
    end
    obj.data_type_ = 'a';
end
obj.data_fields_locations_ = data_pos;
%
% caclulate number of pixels from pixels block position and its size

obj.npixels_  = (obj.eof_pix_pos_ - obj.pix_pos_)/(4*9);

obj=set_filepath(obj);


function obj=set_filepath(obj)

[path,name,ext]=fileparts(fopen(obj.file_id_));
obj.filename_=[name,ext];
obj.filepath_=[path,filesep];

function check_and_throw_error(obj,mess_pos)
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('SQW_BINFILE_COMMON:io_error',...
        '%s: Reason %s',mess_pos,mess)
end
