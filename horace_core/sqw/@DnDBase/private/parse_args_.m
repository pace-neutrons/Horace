function args = parse_args_(obj, varargin)
% Parse the argument passed to the DnD constructor.
%
% Return struct with the data set to the appropriate element:
% - args.filename  % string, presumed to be filename
% - args.dnd_obj   % DnD class instance
% - args.sqw_obj   % SQW class instance
% - args.data_struct % generic struct, presumed to represent DnD

input_data = varargin;
args = struct(...
    'array_numel',          1, ...
    'array_size',        [1,1], ...
    'dnd_obj',              [], ...
    'sqw_obj',              [], ...
    'set_of_fields',        [], ...
    'filename',             [], ...
    'data_struct',          [] ...
    );
keys = obj.saveableFields();
keys_present = any(cellfun(@(x)(ischar(x)||isstring(x))&&ismember(x,keys),varargin));

if isa(input_data{1}, 'SQWDnDBase')
    args.array_numel = numel(input_data);
    args.array_size = size(input_data);
    if isa(input_data{1}, class(obj))
        if args.array_numel ==1
            args.dnd_obj = input_data{1};
        else
            args.dnd_obj = input_data;
        end
    elseif isa(input_data{1}, 'sqw')
        if args.array_numel ==1
            args.sqw_obj = input_data{1};
        else
            args.sqw_obj = input_data;
        end
    else
        error(['HORACE:', class(obj),'invalid_argument'], ...
            'Class %s cannot be constructed from an instance of object %s',...
            upper(class(obj)),class(input_data{1}));
    end

elseif is_string(input_data{1}) && ~keys_present
    args.filename = input_data;
elseif (iscellstr(input_data)||isstring(input_data)) && ~keys_present% cellarray of filenames
    args.filename = input_data;
    args.array_numel = numel(input_data);
    args.array_size = size(input_data);
elseif isstruct(input_data{1}) && ~isempty(input_data{1})
    args.data_struct = input_data;
elseif numel(input_data) > 1
    args.set_of_fields = varargin;
else
    % create struct holding default instance contents
    args.data_struct.axes =   axes_block(obj.NUM_DIMS);
    args.data_struct.proj =   ortho_proj();
    sz = args.data_struct.axes.dims_as_ssize;
    args.data_struct = init_arrays_(args.data_struct,sz);
end
