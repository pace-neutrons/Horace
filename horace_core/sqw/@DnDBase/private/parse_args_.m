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
    'data_struct',          [] ...
    );

if isempty(input_data)
    % create struct holding default instance contents
    args.data_struct.axes =   axes_block(obj.NUM_DIMS);
    args.data_struct.proj =   ortho_proj();
    sz = args.data_struct.axes.dims_as_ssize;
    args.data_struct = init_arrays_(args.data_struct,sz);
elseif isa(input_data{1}, 'SQWDnDBase')
    args.array_numel = numel(input_data{1});
    args.array_size = size(input_data{1});
    if isa(input_data{1}, class(obj))
        if args.array_numel ==1
            args.dnd_obj = input_data{1};
        else
            args.dnd_obj = input_data;
        end
    elseif isa(input_data{1}, 'sqw')
        if args.array_numel ==1
            args.sqw_obj = input_data{1};
            if ~isa(args.sqw_obj.data,class(obj))
                error(['HORACE:', class(obj),':invalid_argument'], ...
                    'The source sqw object contains invalid shape dnd object')
            end
        else
            cl_name = class(obj);
            is_valid = arrayfun(@(x)isa(x.data,cl_name),input_data{1});
            if ~all(is_valid)
                error(['HORACE:', class(obj),':invalid_argument'], ...
                    'The source sqw object contains different shapes dnd object(s)')
            end
            args.sqw_obj = input_data{1};
        end
    else
        error(['HORACE:', class(obj),':invalid_argument'], ...
            'Class %s cannot be constructed from an instance of object %s',...
            upper(class(obj)),class(input_data{1}));
    end

elseif iscellstr(input_data)||isstring(input_data)
    error(['HORACE:', class(obj),':invalid_argument'],...
        '%s object can not be constructed from string. Use read_dnd (or read/load) operation to get it from file', ...
        class(obj))
elseif isstruct(input_data{1}) && ~isempty(input_data{1})
    args.data_struct = input_data;
elseif numel(input_data) > 1
    if numel(input_data) == 2 && isa(input_data{1},'axes_block') && isa(input_data{2},'aProjection')
        sz = input_data{1}.dims_as_ssize;
        strc = init_arrays_(struct(),sz);
        args.set_of_fields = [varargin(:);struct2cell(strc)];
    elseif numel(input_data) >= 5
        args.set_of_fields = input_data;
    else
        error(['HORACE:', class(obj),':invalid_argument'], ...
            'Unrecognized number or type of the input arguments')
    end

else
    error(['HORACE:', class(obj),':invalid_argument'], ...
        'unknown input for %s constructor',class(obj));
end
