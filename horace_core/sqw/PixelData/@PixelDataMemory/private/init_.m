function obj = init_(obj,varargin)
% Main part of PixelDataMemory constructor
if numel(varargin) > 1
    % build from data/metadata pair
    flds = obj.saveableFields();
    obj = obj.set_positional_and_key_val_arguments(...
        flds,false,varargin);
    return
else
    init = varargin{1};
end


if isstruct(init)
    obj = obj.loadobj(init);

elseif ischar(init) || isstring(init)
    if ~is_file(init)
        error('HORACE:PixelDataFileBacked:invalid_argument', ...
            'Cannot find file to load (%s)', init)
    end
    init = sqw_formats_factory.instance().get_loader(init);
    obj = obj.init_from_file_accessor_(init);

elseif isa(init,'PixelData')
    obj.data = init.data;

elseif isa(init, 'sqw_file_interface')
    obj = obj.init_from_file_accessor_(init);

elseif isa(init, 'PixelDataMemory')
    obj.data = init.data;

elseif isscalar(init) && isnumeric(init) && floor(init) == init
    % input is an integer
    obj.data = zeros(obj.PIXEL_BLOCK_COLS_, init);

elseif isnumeric(init)
    obj.data = init;

elseif isa(init, 'PixelDataFileBacked')

    data = zeros(obj.DEFAULT_NUM_PIX_FIELDS, init.num_pixels);

    for i=1:init.num_pages
        [sind, eind] = init.get_page_idx_(i);
        [init, data(:, sind:eind)] = init.load_page(i);
    end

    obj.data_ = data;
    init=init.move_to_first_page();
    undef = init.data_range == PixelDataBase.EMPTY_RANGE;

    if any(undef(:))
        obj=obj.recalc_data_range();
    else
        obj.data_range_ = init.data_range;
    end

    obj.full_filename = init.full_filename;

else
    error('HORACE:PixelDataMemory:invalid_argument', ...
        'Cannot construct PixelDataMemory from class (%s)', class(init))
end
