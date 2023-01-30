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
    init=init.move_to_first_page();
    obj.data_ = init.data;
    while init.has_more()
        init = init.advance();
        obj.data_ = horzcat(obj.data_, init.data);
    end

    obj.full_filename = init.full_filename;
    obj=obj.reset_changed_coord_range();
else
    error('HORACE:PixelDataMemory:invalid_argument', ...
        'Cannot construct PixelDataMemory from class (%s)', class(init))
end
