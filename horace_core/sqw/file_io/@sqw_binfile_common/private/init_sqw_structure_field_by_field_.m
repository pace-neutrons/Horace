function obj = init_sqw_structure_field_by_field_(obj,varargin)
% function to read sqw version-2 file structure to initialize binary input
% and identify the positions of various pieces of data within the binary
% file
%
%
%
[ok,mess,init_for_upgrade,upgrade] = parse_char_options(varargin,{'-update','-upgrade'});
if ~ok
    error('HORACE:sqw_binfile_common:invalid_argument',mess);
end

try
    do_fseek(obj.file_id_,obj.main_header_pos_,'bof');
catch ME
    exc = MException('HORACE:sqw_binfile_common:io_error',...
                     'Error moving to main data header position')
    throw(exc.addCause(ME))
end

template_m_header = obj.get_main_header_form();
[main_h_pos,pos,io_error] = obj.sqw_serializer_.calculate_positions(template_m_header,obj.file_id_,obj.main_header_pos_);
if io_error
    error('HORACE:sqw_binfile_common:io_error',...
        'IO error while parsing main header')
end
obj.main_head_pos_info_ = main_h_pos;

try
    do_fseek(obj.file_id_,main_h_pos.nfiles_pos_,'bof');
catch ME
    exc = MException('HORACE:sqw_binfile_common:io_error',...
                     'Error moving to the  number of contributing files position');
    throw(exc.addCause(ME))
end



n_files = fread(obj.file_id_,1,'int32');
check_and_throw_error(obj,'Error reading number of contributing files field');
%
obj.num_contrib_files_ = n_files;
%
obj.header_pos_ = zeros(1,n_files);
obj.header_pos_(1) = pos;

template_header = obj.get_header_form();
[header_pos,pos,io_error]=obj.sqw_serializer_.calculate_positions(template_header,obj.file_id_,pos);
if io_error
    error('HORACE:sqw_binfile_common:io_error',...
        'IO error while parsing positions of contributing file header N1')
end
obj.header_pos_info_ = repmat(header_pos,1,n_files);
% check if the headers information is mangled with appropriate run-id.
obj = check_header_mangilig(obj,header_pos);

for i=2:n_files
    obj.header_pos_(i) = pos;
    % [header_pos,pos] =
    [header_pos,pos,io_error]=obj.sqw_serializer_.calculate_positions(template_header,obj.file_id_,pos);
    if io_error
        error('HORACE:sqw_binfile_common:io_error',...
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
    error('HORACE:sqw_binfile_common:io_error',...
        'IO error while parsing detector information')
end

% data block
data_header = obj.get_dnd_form();
[data_pos,pos,io_error,data_header] =  obj.sqw_serializer_.calculate_positions(data_header,obj.file_id_,pos);
if io_error
    if ~isfield(data_pos,'s_pos_') || ~isfield(data_pos,'e_pos_')
        error('HORACE:sqw_binfile_common:io_error',...
            'IO error while parsing data, can not identify location of signal and error arrays')
    end
end
if ischar(obj.num_dim_) % prototype does not have dimensions in data header,
    % so need to get num dims from p-array size
    obj.num_dim_ = numel(data_header.p_size.field_value);
end
if ischar(obj.dnd_dimensions)
    obj.dnd_dimensions_ = double(data_header.p_size.field_value);
end
pix_data_header = obj.get_pix_form();
[pix_data_pos,pos,io_error] =  obj.sqw_serializer_.calculate_positions(pix_data_header,obj.file_id_,pos);


%
obj.npixels_ = [];
obj.s_pos_=data_pos.s_pos_;
obj.e_pos_=data_pos.e_pos_;
obj.eof_pix_pos_ = pos;
if ~io_error
    obj.npix_pos_=data_pos.npix_pos_;
    obj.img_db_range_pos_=pix_data_pos.img_range_pos_;
    obj.pix_pos_=pix_data_pos.pix_block_pos_+8;  % pixels are written with their size in front of the array.

    % calculate number of pixels from pixels block position and its size
    obj.npixels_  = (obj.eof_pix_pos_ - obj.pix_pos_)/(4*9);
else
    if ~isfield(data_pos,'npix_pos_')
        obj.data_type_ = 'b';
        obj=set_filepath(obj);
        obj.dnd_eof_pos_ = pos;
        return
    else
        obj.npix_pos_=data_pos.npix_pos_;
    end
    obj.data_type_ = 'b+';
    if ~isfield(data_pos,'pix_pos_')
        obj.data_type_ = 'a-';
        obj.dnd_eof_pos_ = pos;
        obj=set_filepath(obj);
        return;
    else
        obj.img_db_range_pos_=data_pos.img_db_range_pos_;
        obj.pix_pos_=data_pos.pix_pos_+8;

        try
            do_fseek(obj.file_id_,data_pos.pix_pos_,'bof');
        catch ME
            exc = MException('HORACE:sqw_binfile_common:io_error',...
                             'unable to move to npix position in file');
            throw(exc.addCause(ME))
        end
        obj.npixels_ = fread(obj.file_id_,1,'*uint64');
        check_and_throw_error(obj,'unable to read npix field');
    end
end
% subsequent methods read pixels directly, so here we shift pixel
% position by the array length
obj.data_type_ = 'a';
obj.dnd_eof_pos_ = pix_data_pos.img_range_pos_;

obj.data_fields_locations_ = data_pos;
%
obj=set_filepath(obj);



function obj=set_filepath(obj)

file = fopen(obj.file_id_);
obj.full_filename = file;

function check_and_throw_error(obj,mess_pos)
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('HORACE:sqw_binfile_common:io_error',...
        '%s: Reason: %s',mess_pos,mess)
end
