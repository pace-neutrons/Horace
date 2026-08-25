function obj = init_from_file_accessor_(obj, faccessor,update,norange)
% Initialise a PixelDataFileBased object from a file accessor

if ~faccessor.sqw_type
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
        'f_accessor for file: %s is not a sqw-file accessor', faccessor.full_filename);
end

obj.offset_   = faccessor.pix_position;
sqw_obj = faccessor.get_sqw('-nopix');
if isa(faccessor,'faccess_sqw_v4')
    disp('argh');
end

if isa(faccessor,'faccess_sqw_v4_1')
    myfileid =fopen(faccessor.full_filename,'r');
    fseek(myfileid,faccessor.pix_position,'bof');
    AAA = fread(myfileid,[1,1],'single');
end

obj.page_num_ = 1;
obj.num_pixels_ = double(faccessor.npixels);
tail = faccessor.eof_position-faccessor.pixel_data_end;
obj.f_accessor_ = []; % necessary as otherwise it may use the
% previous instance of file_accessor and become invalid
%sqw1 = faccessor.get_sqw();
format = obj.get_memmap_format(faccessor,tail);
if isa(faccessor,'faccess_sqw_v4_1')
    %%{
    format0 = {'single' ,  [    1], 'total_nonzero_signals'; ...
              };
    format = {'single'   [9 100337],   'data'; ...
             };
    format2 = {
              'single'   [3 11919],   'data2'; ...
              };
    format2a = {'single' ,  [    1], 'end_marker'; ...
              };
    format3 = {
              'uint8',   [    3240],   'tail'};
    %%}
    format = obj.get_memmap_format(faccessor,tail);
else
    format = obj.get_memmap_format(faccessor,tail);
end
fmt = cell(7,3);
fmt{1,1} = 'single'; fmt{1,2} = 1;         fmt{1,3} = 'n_nonzero';
fmt{2,1} = 'single'; fmt{2,2} = [9 obj.num_pixels];fmt{2,3} = 'data';
fmt{3,1} = 'single'; fmt{3,2} = 1;         fmt{3,3} = 'separator';
fmt{4,1} = 'single'; fmt{4,2} = [3 1]; fmt{4,3} = 'data2';
fmt{5,1} = 'single'; fmt{5,2} = 1;         fmt{5,3} = 'nnpixpages';
fmt{6,1} = 'single'; fmt{6,2} = 101;       fmt{6,3} = 'nnzpix';
fmt{7,1} = 'single'; fmt{7,2} = 1;         fmt{7,3} = 'endflag2';
if isa(faccessor,'faccess_sqw_v4_1')
    %{
    mmf0 = memmapfile(faccessor.full_filename, ...
        'Format', format0, ... %obj.get_memmap_format(tail), ...
        'Repeat', 1, ...
        'Writable', update, ...
        'Offset', obj.offset_);
    mmf1 = memmapfile(faccessor.full_filename, ...
        'Format', fmt, ... %obj.get_memmap_format(tail), ...
        'Repeat', 1, ...
        'Writable', update, ...
        'Offset', obj.offset_);
    %}
    fmt = cell(1,3);
    fmt{1,1} = 'single'; fmt{1,2} = 1;         fmt{1,3} = 'n_nonzero';
    mmf = memmapfile(faccessor.full_filename, ...
        'Format', fmt, ... %obj.get_memmap_format(tail), ...
        'Repeat', 1, ...
        'Writable', update, ...
        'Offset', obj.offset_);
    n_nonzero = double(mmf.Data.n_nonzero);
    npx = double(obj.num_pixels);
    fmt = cell(5,3);
    fmt{1,1} = 'single'; fmt{1,2} = 1;         fmt{1,3} = 'n_nonzero';
    fmt{2,1} = 'single'; fmt{2,2} = [9 npx];fmt{2,3} = 'data';
    fmt{3,1} = 'single'; fmt{3,2} = 1;         fmt{3,3} = 'separator';
    fmt{4,1} = 'single'; fmt{4,2} = [3 n_nonzero]; fmt{4,3} = 'data2';
    fmt{5,1} = 'single'; fmt{5,2} = 1;         fmt{5,3} = 'nnpixpages';
    mmf = memmapfile(faccessor.full_filename, ...
        'Format', fmt, ... %obj.get_memmap_format(tail), ...
        'Repeat', 1, ...
        'Writable', update, ...
        'Offset', obj.offset_);
    n_filepages = double(mmf.Data.nnpixpages);
    fmt = cell(7,3);
    fmt{1,1} = 'single'; fmt{1,2} = 1;         fmt{1,3} = 'n_nonzero';
    fmt{2,1} = 'single'; fmt{2,2} = [9 npx];fmt{2,3} = 'data';
    fmt{3,1} = 'single'; fmt{3,2} = 1;         fmt{3,3} = 'separator';
    fmt{4,1} = 'single'; fmt{4,2} = [3 n_nonzero]; fmt{4,3} = 'data2';
    fmt{5,1} = 'single'; fmt{5,2} = 1;         fmt{5,3} = 'nnpixpages';
    fmt{6,1} = 'single'; fmt{6,2} = n_filepages;       fmt{6,3} = 'nnzpix';
    fmt{7,1} = 'single'; fmt{7,2} = 1;         fmt{7,3} = 'endflag2';
    mmf = memmapfile(faccessor.full_filename, ...
        'Format', fmt, ... %obj.get_memmap_format(tail), ...
        'Repeat', 1, ...
        'Writable', update, ...
        'Offset', obj.offset_);
    obj.f_accessor_ = mmf;
    if isempty(obj.pix_page_chunks_)
        npages = ceil(obj.num_pixels/obj.default_page_size);        
        ps = obj.default_page_size*ones(1,npages);
        snpages = sum(ps(1:npages));
        delta = snpages - obj.num_pixels;
        ps(npages) = ps(npages) - delta;
    else
        ps = obj.pix_page_chunks_;
    end
    nn = repage_nonzero_signals(ps,obj.f_accessor_.Data.data2(1,:));
    obj.nonzerosignal_pix = nn;
else
    mmf = memmapfile(faccessor.full_filename, ...
        'Format', format, ... %obj.get_memmap_format(tail), ...
        'Repeat', 1, ...
        'Writable', update, ...
        'Offset', obj.offset_);
end
obj.f_accessor_ = mmf;
np = obj.num_pages;
ps = obj.page_size;
mydata = obj.data(:,1);
meta = faccessor.get_pix_metadata();
% Metadata filename may differ from current filename; update filename here
obj.metadata = meta;
% Let's force PixelFildBacked always have filenane of the file, it was
% loaded from
obj.full_filename = faccessor.full_filename;

ver = faccessor.faccess_version;
if ver< sqw_formats_factory.instance().last_version()
    obj.old_file_format_ = true;
else
    obj.old_file_format_ = false;
end

if norange
    return;
end

if ~obj.is_range_valid()
    ll = config_store.instance().get_value('hor_config','log_level');
    if ll<2
        return;
    end
    fprintf(2,[ '\n', ...
        '*** SQW file does not contain correct pixel data ranges.\n', ...
        '*** This may be because file quickly upgraded from old-format file or it is sqw quick-realigned file.\n', ...
        '*** Averages will be calculated when needed which may take substantial time for large files\n', ...
        '*** Upgrade your saved sqw object to not have to recalculate these each time you ask for data averages\n', ...
        '*** To upgrade this file run:\n' ...
        '*** >> upgrade_file_format(''%s'',"-upgrade_range")\n'], ...
        obj.full_filename);
end
