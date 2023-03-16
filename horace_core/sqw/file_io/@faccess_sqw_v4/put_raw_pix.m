function  obj= put_raw_pix(obj,pix_data,pix_idx,varargin)
%PUT_RAW_PIX  Store pixel data in the specified position of the pixel data
%block.
%
% Inputs:
% obj -- initialized f-accessor object, containing proper block allocation
%        table with defined pixels block (containing correct number of pixels
%        to be in the target file and number of pixel rows (9, nothing else was tested))
%
% pix_data
%     -- array of pixel data. Normally 9xNpix but can be different if different
%        pixel format is selected (not tested).
% pix_idx
%     -- the position in the pixel array to put the data block in. Has to point
%        to the position after last pixel written
%        or inside the pixel array (for overwriting existing pixels on disk);
%
% Method used by file-accessor for modifying or writing new block of pixel
% data in the binary data file or in a loop writing the pixels in a new binary file.
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
                     'Error moving to the start of the pixels block data at index: %d',pix_idx);
    throw(exc.addCause(ME))
end

try
    fwrite(obj.file_id_, single(pix_data), 'float32');
    obj.check_write_error(obj.file_id_);
catch ME
    exc = MException('HORACE:put_raw_pix:io_error',...
                     'Error writing input pixels array indices: %d',pix_idx);
    throw(exc.addCause(ME))
end
