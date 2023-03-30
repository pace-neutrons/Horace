function obj = init_(obj, varargin)
%INIT_ Main part of the initialiation structure, usually performed by
%constructor, but may be applied to existing object (empty) fully deleting
% its old contents and replacing it with initialization information

% process possible update parameter, which opens file in write mode
is_bool = cellfun(@islogical,varargin);
log_par = [varargin{is_bool} false(1,2)]; % Pad with false
update  = log_par(1);
norange = log_par(2);
argi = varargin(~is_bool);

if isscalar(argi)
    init = argi{1};
else
    % build from data/metadata pair
    init = argi;
end

if iscell(init)
    flds = obj.saveableFields();
    obj = obj.set_positional_and_key_val_arguments(flds,false,argi);

elseif isstruct(init)
    obj = obj.loadobj(init);

elseif isa(init, 'PixelDataFileBacked')
    obj.offset_       = init.offset_;
    obj.full_filename = init.full_filename;
    obj.num_pixels_   = init.num_pixels;
    obj.data_range    = init.data_range;
    obj.tmp_pix_obj   = init.tmp_pix_obj;
    obj.f_accessor_   = memmapfile(obj.full_filename, ...
        'Format', obj.get_memmap_format(), ...
        'Repeat', 1, ...
        'Writable', update, ...
        'Offset', obj.offset_ );

elseif isa(init, 'PixelDataMemory')

    if isempty(obj.full_filename_)
        obj.full_filename = 'from_mem';
    end

    obj = set_raw_data_(obj,init.data);

elseif istext(init)
    if ~is_file(init)
        error('HORACE:PixelDataFileBacked:invalid_argument', ...
            'Cannot find file to load (%s)', init)
    end

    init = sqw_formats_factory.instance().get_loader(init);
    obj = init_from_file_accessor_(obj,init,update,norange);

elseif isa(init, 'sqw_file_interface')
    obj = init_from_file_accessor_(obj,init,update,norange);

elseif isnumeric(init)
    % this is usually option for testing filebacked operations
    if isscalar(init)
        init = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,abs(floor(init)));
    end

    if isempty(obj.full_filename_)
        obj.full_filename = 'from_mem';
    end

    obj = set_raw_data_(obj,init);
else
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
        'Cannot construct PixelDataFileBacked from class (%s)', class(init))
end

obj.page_num = 1;
