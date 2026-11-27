function  obj= put_raw_pix(obj,pix_data,page_number,pix_idx,varargin)
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
% data in the binary data file or in a loop writing the pixels in a new binary file
persistent num_nonzero_pixels num_nonzero_pixels_per_chunk num_pix_to_date;

if nargin <4
    pix_idx = 1;
    page_number;
end
if size(pix_data,2) == 0
    return;
end

if ~obj.is_activated('write')
    obj = obj.activate('write');
end
if pix_idx == 1
    % this will work properly if number of pixels is known initially and
    % stored in BAT, i.e. during overwriting. If you write pages one after
    % another appending to file, this will not write correct number of
    % pixels.
    % Do not forget to update number of pixels (put_num_pixels) after using
    % this method in algorithm, which changes number of pixels.
    pdb = obj.bat_.blocks_list{end};
    pdb.put_data_header(obj.file_id_);

    num_nonzero_pixels = 0;
    num_nonzero_pixels_per_chunk = zeros(1,page_number(2));
    num_pix_to_date = 0;
end

pos = obj.pix_position + 4 ... % pos for no. of non-zero pixels
                       + (pix_idx-1)*3*4; % pixs from previous pages //%obj.get_filepix_size;

try
    do_fseek(obj.file_id_,pos,'bof');
catch ME
    exc = MException('HORACE:put_raw_pix:io_error',...
          'Error moving to the start of the main pixels block data at index: %d',pix_idx);
    throw(exc.addCause(ME))
end

try
    fwrite(obj.file_id_, single(pix_data(5:7,:)), 'float32');
    obj.check_write_error(obj.file_id_);
catch ME
    exc = MException('HORACE:put_raw_pix:io_error',...
                     'Error writing input pixels array indices: %d',pix_idx);
    throw(exc.addCause(ME))
end

pos2 = obj.pix_position + 4 + obj.npixels*3*4 + 4 ... % after all pixels and separator
       + 4*3*num_nonzero_pixels; % and after all non-zero pixels on previous pages

try
    do_fseek(obj.file_id_,pos2,'bof');
catch ME
    exc = MException('HORACE:put_raw_pix:io_error',...
          'Error moving to the end of the main pixels block data: %d',pos2);
    throw(exc.addCause(ME))
end

sig = pix_data(8,:);
possig = find(sig);
possigval = sig(possig);
posvarval = var(possig);
% now we have used possig to extract the non-zero signal/variance values,
% write the positions wrt the whole file not just this page
possig = possig + num_pix_to_date;
% check the number of non-zero values and accumulate over all pages
% (write at end of pages loop)
numpossig = numel(possigval);
num_pix_to_date = num_pix_to_date + numel(pix_data(8,:));
num_nonzero_pixels = num_nonzero_pixels + numpossig;
num_nonzero_pixels_per_chunk(page_number(1)) = numpossig;

pix_data2 = zeros(3,numpossig);
pix_data2(1,:) = possig;
pix_data2(2,:) = possigval;
pix_data2(3,:) = posvarval;
try
    fwrite(obj.file_id_, pix_data2, 'float32');
catch ME
    error("cannot write non-zero pixel values");
end

if page_number(1)==page_number(2)
    full_filename = [obj.filepath '\' obj.filename];

    try
        fwrite(obj.file_id_, single(page_number(2)), 'float32');
    catch ME
        error('cannot write num pages for nonzero pixels');
    end

    try
        fwrite(obj.file_id_, single(num_nonzero_pixels_per_chunk), 'float32');
    catch ME
        error('cannot write nonzero pixels chunk sizes');
    end

    try
        fwrite(obj.file_id_, single(666), 'float32');
    catch ME
        error("cannot write endflag");
    end
    
    try 
        fseek(obj.file_id_, obj.pix_position,'bof');
        fwrite(obj.file_id_, single(num_nonzero_pixels),'float32');
    catch ME
        error("could not write nnzpix");
    end
    try
        fseek(obj.file_id_,obj.pix_position + 4 ... % pos for no. of non-zero pixels
                       + obj.npixels*3*4,'bof');
        fwrite(obj.file_id_, single(666),'float32');
    catch ME
        error("could not write separator");
    end

    fmt = cell(7,3);
    fmt{1,1} = 'single'; fmt{1,2} = 1;         fmt{1,3} = 'n_nonzero';
    fmt{2,1} = 'single'; fmt{2,2} = [3 100337];fmt{2,3} = 'data';
    fmt{3,1} = 'single'; fmt{3,2} = 1;         fmt{3,3} = 'separator';
    fmt{4,1} = 'single'; fmt{4,2} = [3 num_nonzero_pixels]; fmt{4,3} = 'data2';
    fmt{5,1} = 'single'; fmt{5,2} = 1;         fmt{5,3} = 'nnpixpages';
    fmt{6,1} = 'single'; fmt{6,2} = [1 page_number(2)], fmt{6,3} = 'nnzz'
    fmt{7,1} = 'single'; fmt{7,2} = 1;         fmt{7,3} = 'endflag';
    mmf = memmapfile(full_filename, ...
        'Format', fmt, ... %obj.get_memmap_format(tail), ...
        'Repeat', 1, ...
        'Writable', true, ...
        'Offset', obj.pix_position);
end



