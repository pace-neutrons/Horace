function obj = init_(obj,varargin)
% INIT_ initialize PixelDataFileBacked object with set of any input
% parameters

% process possible update parameter
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
    obj.offset_       = init.offset;
    obj.full_filename = init.full_filename;
    obj.num_pixels_   = init.num_pixels;
    obj.data_range    = init.data_range;
    obj.f_accessor_   = memmapfile(obj.full_filename, ...
                                   'format', {'single',[PixelDataBase.DEFAULT_NUM_PIX_FIELDS,init.num_pixels_],'data'}, ...
                                   'Repeat', 1, ...
                                   'Writable', update, ...
                                   'offset', obj.offset_ );

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

end
