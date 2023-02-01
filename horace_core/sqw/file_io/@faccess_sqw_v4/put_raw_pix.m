function  obj= put_raw_pix(obj,pix_data,pix_idx,varargin)
%PUT_RAW_PIX  Store pixel data in the spefified position of the pixel data
%block.
%
% Inputs:
% obj -- intnialized f-accessor object, containign proper block allocation
%        table with
%
% Method used by file-accessor for modifying or writing new block of pixel
% data in the binary data file
if nargin <3
    pix_idx = 1;
end

if ~obj.is_activated('write')
    obj = obj.activate('write');
end
if pix_idx == 1
    pdb = obj.bat_.blocks_list{end};
    pdb.put_data_header(obj.file_id_);
end

pos = obj.pix_position + (pix_idx-1)*obj.get_filepix_size;

try
    do_fseek(obj.file_id_,pos,'bof');
catch ME
    exc = MException('HORACE:put_raw_pix:io_error',...
        sprintf('Error moving to the start of the pixels block data at inxed %d',pix_idx));
    throw(exc.addCause(ME))
end
try
    fwrite(obj.file_id_, single(pix_data), 'float32');
    obj.check_write_error(obj.file_id_);
catch ME
    exc = MException('HORACE:put_raw_pix:io_error',...
        sprintf('Error writing input pixels array inxed %d',pix_idx));
    throw(exc.addCause(ME))
end
