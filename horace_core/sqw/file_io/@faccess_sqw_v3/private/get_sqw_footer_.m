function  obj= get_sqw_footer_(obj,varargin)
% Read sqw object v3 structure to initialize sqw-v3 file reader
%
%
%
%
%
[ok,mess,init_for_upgrade] = parse_char_options(varargin,{'-upgrade'});
if ~ok
    error('HORACE:faccess_sqw_v3:invalid_argument',mess);
end

obj = get_sqw_file_footer(obj);
%
if ~init_for_upgrade
    obj.full_filename = fopen(obj.file_id_);
end

% read the number of files contributing into this sqw file
%obj.num_contrib_files_ = get_num_contrib_files(obj);

% Read the number of pixels from pixels block position and its size
if ~obj.sqw_type
    obj.npixels_  = [];
    return;
end

%
function obj = get_sqw_file_footer(obj)
% Read final entry to sqw file: location of position information in the file and data_type
%
%   >> [mess, position_info_location, data_type, position] = get_sqw_file_footer (fid)
%
% It is assumed that on entry that the pointer is just after the end of this block,
% which should in fact be the end of the file.
%
% Input:
% ------
%   fid                     File pointer to (already open) binary file
%
% Output:
% -------
%   mess                    Message if there was a problem writing; otherwise mess=''
%   position_info_location  Position of the position information block
%   data_type               Type of sqw data contained in the file: will be one of
%                               type 'b'    fields: filename,...,uoffset,...,dax,s,e
%                               type 'b+'   fields: filename,...,uoffset,...,dax,s,e,npix
%                               type 'a'    fields: filename,...,uoffset,...,dax,s,e,npix,pix_range,pix
%                               type 'a-'   fields: filename,...,uoffset,...,dax,s,e,npix,pix_range
%   position                Position of the file footer in the file


% Read data from file:

fseek(obj.file_id_,-4,'eof');  % move to the end of the file minus 4 bytes
test_error(obj.file_id_,'Unable to move to the position of the sqw_v3 file descriptor size. ErrorMessave: %s')
%

foot_sz = fread(obj.file_id_,1,'int32');
test_error(obj.file_id_,'Unable to read the location of the sqw_v3 file descriptor. ErrorMessave: %s')
eof_pos  = ftell(obj.file_id_);

fseek(obj.file_id_,-foot_sz-4,'eof');   % move to start of the block of data (8-byte position + n-byte string + 4-byte string length)
test_error(obj.file_id_,'Unable to move to the location of the sqw_v3 file descriptor. ErrorMessave: %s')
%

pos_info_location = ftell(obj.file_id_);
%fseek(obj.file_id_,pos_info_location,'bof');  % move to the start of the
%descriptor (which should already be there)
%test_error(obj.file_id_,'Unable to move to the start of the sqw_v3 file descriptor');

bytes = fread(obj.file_id_,foot_sz,'*uint8');
test_error(obj.file_id_,'Unable to read sqw_v3 file descriptor');

%
descr_format = obj.get_si_form();
fd_struct = obj.sqw_serializer_.deserialize_bytes(bytes,descr_format,1);
% old style urange corresponds now to img_db_range
if isfield(fd_struct,'urange_pos_')
    fd_struct.img_db_range_pos_ = fd_struct.urange_pos_;
    fd_struct = rmfield(fd_struct,'urange_pos_');
elseif isfield(fd_struct,'img_range_pos_') % intermediate format
    fd_struct.img_db_range_pos_ = fd_struct.img_range_pos_;
    fd_struct = rmfield(fd_struct,'img_range_pos_');
end

% special and calculated fields
obj.position_info_pos_ = pos_info_location;
obj.eof_pos_  = eof_pos;
obj.real_eof_pos_ = eof_pos;

obj = obj.from_bare_struct(fd_struct);
obj.data_type_ = char(obj.data_type_);

% debug and sanity options@
% caclulate number of pixels from pixels block position and its size
npixels_  = (obj.instrument_head_pos_-obj.pix_pos_)/(9*4);
if npixels_ ~= obj.npixels
    error('HORACE:faccess_sqw_v3:runtime_error',...
        'number of pixels stored in the records %d not equal to the calculated pixels size %d ',...
        obj.npixels,npixels_);
end



function test_error(fid,error_header)
[mess,res] = ferror(fid);
if res ~= 0
    error('HORACE:faccess_sqw_v3:io_error',...
        error_header,mess);
end



