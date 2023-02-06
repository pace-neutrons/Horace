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
    % TODO: #928 tailed source here will not work
    obj.f_accessor_   = memmapfile(obj.full_filename,'format', ...
        {'single',[PixelDataBase.DEFAULT_NUM_PIX_FIELDS,init.num_pixels_],'data'}, ...
        'Writable', update, 'offset', obj.offset_ );
elseif ischar(init) || isstring(init)
    if ~is_file(init)
        error('HORACE:PixelDataFileBacked:invalid_argument', ...
            'Cannot find file to load (%s)', init)
    end

    init = sqw_formats_factory.instance().get_loader(init);
    obj = init_from_file_accessor_(obj,init,update,norange);

elseif isa(init, 'sqw_file_interface')
    obj = init_from_file_accessor_(obj,init,update,norange);

elseif isnumeric(init) %
    % this is usually option for testing filebacked operations
    if isscalar(init)
        init = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,abs(floor(init)));
    end
    if isempty(obj.full_filename_)
        file_name =fullfile(tmp_dir,['PixFileBacked_',str_random,'.sqw']);
        obj.full_filename = file_name;
    end
    obj = set_raw_data_(obj,init);
else
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
        'Cannot construct PixelDataFileBacked from class (%s)', class(init))
end
