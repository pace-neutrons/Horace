function obj = init_(obj, varargin)
%INIT_ Main part of the initialisation algorithm, usually performed by
% constructor, but may be applied to existing object (normally empty) fully
% deleting its old contents and replacing it with initialization information
%
% Initializes the object using any permitted initialization information.

% process possible update parameter, which opens file in write mode
is_bool = cellfun(@islogical,varargin);
log_par = [varargin{is_bool} false(1,2)]; % Pad with false
update  = log_par(1);
norange = log_par(2);
argi = varargin(~is_bool);

if isscalar(argi)
    init_data = argi{1};
else
    % build from data/metadata pair
    init_data = argi;
end

if iscell(init_data)
    flds = obj.saveableFields();
    obj = obj.set_positional_and_key_val_arguments(flds,false,argi);

elseif isstruct(init_data)
    obj = obj.loadobj(init_data);

elseif isa(init_data, 'PixelDataFileBacked')
    obj.offset_       = init_data.offset_;
    obj.full_filename = init_data.full_filename;
    obj.num_pixels_   = init_data.num_pixels;
    obj.data_range    = init_data.data_range;
    obj.tmp_file_holder_ = ...
        init_data.tmp_file_holder_;
    obj.f_accessor_   = memmapfile(obj.full_filename, ...
        'Format', init_data.get_memmap_format(), ...
        'Repeat', 1, ...
        'Writable', update, ...
        'Offset'  , obj.offset_ );
elseif isa(init_data, 'PixelDataMemory')

    obj.metadata = init_data.metadata;
    if isempty(obj.full_filename_)
        obj.full_filename = 'from_mem';
    end
    obj = set_raw_data_(obj,init_data.data);

elseif istext(init_data)
    if ~is_file(init_data)
        error('HORACE:PixelDataFileBacked:invalid_argument', ...
            'Cannot find file to load (%s)', init_data)
    end

    ldr = sqw_formats_factory.instance().get_loader(init_data);
    obj = init_from_file_accessor_(obj,ldr,update,norange);
    ldr.delete();
elseif isa(init_data, 'sqw_file_interface')
    obj = init_from_file_accessor_(obj,init_data,update,norange);
elseif isa(init_data,'memmapfile')
    obj.f_accessor_    = init_data;
    % should this all be rewired through?
    obj.full_filename_ = init_data.Filename;
    obj.num_pixels_    = obj.f_accessor_.Format{2}(2);
    obj.offset_        = init_data.Offset;
elseif isnumeric(init_data)
    % this is usually option for testing filebacked operations
    if isscalar(init_data)
        init_data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,abs(floor(init_data)));
    end

    if isempty(obj.full_filename_)
        obj.full_filename = 'from_mem';
    end
    obj = set_raw_data_(obj,init_data);
    range = obj.pix_minmax_ranges(init_data);
    obj = obj.set_data_range(range);
else
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
        'Cannot construct PixelDataFileBacked from class (%s)', class(init_data))
end

obj.page_num = 1;
