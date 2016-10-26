function  obj= read_sqw_structure_(obj)
% Read sqw object v3 structure to initialize sqw-v3 file reader
%
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
%
%
[descriptor_location,descriptor_size,data_type,eof_pos] = get_sqw_file_footer(obj);
obj.data_type_ = data_type;
obj.eof_pos_  = eof_pos;

fseek(obj.file_id_,descriptor_location,'bof');  % move to the start of the descriptor
test_error(obj.file_id_,'Unable to move to the start of the sqw_v3 file descriptor');

bytes = fread(obj.file_id_,descriptor_size,'*uint8');
test_error(obj.file_id_,'Unable to read sqw_v3 file descriptor');

descr_format = field_generic_class_hv3();
fd_struct = obj.sqw_serializer_.deserialize_bytes(bytes,descr_format,1);
fields = fieldnames(fd_struct);

for i=1:numel(fields)
    fn = fields{i};
    obj.([fn,'_pos_']) = fd_struct.(fn);
end
% redefine parents (BAD OOP)
obj.dnd_eof_pos_ = fd_struct.pix-8-4+1; % points to dummy field
obj.eof_pix_pos_ = fd_struct.instrument+1;
%
[fp,fn,ext]=fileparts(fopen(obj.file_id_));
obj.filename_ =[fn,ext];
obj.filepath_ =[fp,filesep];

% read the number of files contributing into this sqw file
obj.num_contrib_files_ = get_num_contrib_files(obj);

% Read the number of pixels from pixels block position and its size
if ~obj.sqw_type
    obj.npixels_  = [];
    return;
end
% npix position is pix position - 8! BAD!    
%fseek(obj.file_id_,obj.pix_pos_-8,'bof');

% caclulate number of pixels from pixels block position and its size
obj.npixels_  = (obj.instrument_pos_-obj.pix_pos_)/(9*4);



function nfiles = get_num_contrib_files(obj)
% read the number of files contributing into this sqw file
nfiles_pos = obj.header_pos_ - 4;
fseek(obj.file_id_,nfiles_pos,'bof');
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('FACCESS_SQW_V3:io_error',...
        'IO error locating number of contributiong files field: Reason %s',mess)
end
nfiles = fread(obj.file_id_,1,'uint32');
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('FACCESS_SQW_V3:io_error',...
        'IO error reading number of contributiong files field: Reason %s',mess)
end


function [position_info_location,pos_info_size,data_type,eof_pos] = get_sqw_file_footer (obj)
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
%                               type 'a'    fields: filename,...,uoffset,...,dax,s,e,npix,urange,pix
%                               type 'a-'   fields: filename,...,uoffset,...,dax,s,e,npix,urange
%   position                Position of the file footer in the file


% Read data from file:

fseek(obj.file_id_,-4,'eof');  % move to the end of the file minus 4 bytes
test_error(obj.file_id_,'Unable to move to the position of the sqw_v3 file descriptor size. ErrorMessave: %s')
%
eof_pos = ftell(obj.file_id_)+5;

pos = fread(obj.file_id_,1,'int32');
test_error(obj.file_id_,'Unable to read the location of the sqw_v3 file descriptor. ErrorMessave: %s')

fseek(obj.file_id_,-pos-12,'eof');   % move to start of the block of data (8-byte position + n-byte string + 4-byte string length)
test_error(obj.file_id_,'Unable to move to the location of the sqw_v3 file descriptor. ErrorMessave: %s')
pos_info_end = ftell(obj.file_id_);

position_info_location = fread(obj.file_id_,1,'float64');
test_error(obj.file_id_,'Unable to read the size of the sqw_v3 file descriptor. ErrorMessave: %s')

data_type = fread(obj.file_id_,1,'*char*1');
test_error(obj.file_id_,'Unable to read sqw')

pos_info_size = pos_info_end-position_info_location;




function test_error(fid,error_header)
[mess,res] = ferror(fid);
if res ~= 0
    error('SQW_BINFILE_v3:io_error',...
        error_header,mess);
end


