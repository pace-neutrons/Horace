function obj = init_(obj,varargin)
%INIT_ initialize PixelDataFileBacked object with set of any input
%parametes

% process possible update parameter
is_bool = cellfun(@(x)islogical(x),varargin);
if any(is_bool)
    log_par = [varargin{is_bool}];
    if numel(log_par) == 2
        update  = log_par(1);
        norange = log_par(2);
    else
        update = log_par(1);
        norange = false;
    end

    argi = varargin(~is_bool);
else
    update = false;
    norange = false;
    argi = varargin;
end

if numel(argi) > 1
    % build from data/metadata pair
    flds = obj.saveableFields();
    obj = obj.set_positional_and_key_val_arguments(...
        flds,false,argi);
    return
else
    init = varargin{1};
end

if isstruct(init)
    obj = obj.loadobj(init);
elseif isa(init, 'PixelDataFileBacked')
    obj.offset_       = init.offset;
    obj.full_filename = init.full_filename;
    obj.num_pixels_   = init.num_pixels;
    obj.data_range    = init.data_range;
    obj.f_accessor_   = memmapfile(obj.full_filename,'format', ...
        {'single',[9,init.num_pixels_],'data'}, ...
        'writable', update, 'offset', obj.offset_ );
elseif ischar(init) || isstring(init)
    if ~is_file(init)
        error('HORACE:PixelDataFileBacked:invalid_argument', ...
            'Cannot find file to load (%s)', init)
    end

    init = sqw_formats_factory.instance().get_loader(init);
    obj = init_from_file_accessor_(obj,init,update,norange);

elseif isa(init, 'sqw_file_interface')
    obj = init_from_file_accessor_(obj,init,update,norange);

elseif isnumeric(init)
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
        'filebacked pixels can not be initialized by data')
    %
    %                     if obj.base_page_size < size(init, 2)
    %                         error('HORACE:PixelDataFileBacked:invalid_argument', ...
    %                             'Cannot create file-backed with data larger than a page')
    %                     end
    %                     obj=obj.set_data(init);
    %                     obj.data_ = init;
    %                     obj.num_pixels_ = size(init, 2);
    %                     if ~obj.cache_is_empty_()
    %                         obj=obj.reset_changed_coord_range('coordinates');
    %                     end
else
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
        'Cannot construct PixelDataFileBacked from class (%s)', class(init))
end
