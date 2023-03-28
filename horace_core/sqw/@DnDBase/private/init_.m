function obj = init_(obj,varargin)
% Initialization procedure for empty DnD-type object or reinitialize one
% defined previously.


args = parse_args_(obj,varargin{:});
%
if args.array_numel>1
    obj_in = cell(args.array_size);
    %obj = repmat(obj,);
elseif args.array_numel==0
    obj = obj.from_bare_struct(args.data_struct);
    return;
end
for i=1:args.array_numel
    % i) copy
    if ~isempty(args.dnd_obj)
        if args.dnd_obj.dimensions == obj.dimensions
            obj_in{i} = copy(args.dnd_obj(i));
        else % rebin the input object to the object
            %  with the dimensionality, smaller then the
            %  dimensionality of the input object.
            %  Bigger dimensionality will be rejected.
            %
            obj_in{i} = rebin(obj(i),args.dnd_obj(i));
        end
        % ii) struct
    elseif ~isempty(args.data_struct)
        obj_in{i} = obj(i).from_bare_struct(args.data_struct{i});
    elseif ~isempty(args.set_of_fields)
        if isempty(args.keys)
            keys = obj.saveableFields();
            obj_in{i} = set_positional_and_key_val_arguments(obj,...
                keys,false,args.set_of_fields{:});
            % copy label from projection to axes block in case it
            % has been redefined on projection
            is_proj = cellfun(@(x)isa(x,'aProjectionBase'),args.set_of_fields);
            if any(is_proj)
                obj_in{i}.axes.label = args.set_of_fields{is_proj}.label;
            end
        else
            obj_in{i} = set_positional_and_key_val_arguments(obj,...
                args.keys,false,args.set_of_fields{:});
        end
    elseif ~isempty(args.sqw_obj)
        obj_in{i} = args.sqw_obj(i).data;
    end
end
obj = [obj_in{:}];
obj = reshape(obj,args.array_size);

function args = parse_args_(obj, varargin)
% Parse the argument passed to the DnD constructor.
%
% Return struct with the data set to the appropriate element:
% - args.filename  % string, presumed to be filename -- Redundant; will
%                    throw
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
    'data_struct',          [], ...
    'keys',                 [] ...
    );

if isempty(input_data)
    % create struct holding default instance contents
    args.data_struct.axes =   ortho_axes(obj.NUM_DIMS);
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
    elseif input_data{1}.dimensions() >= obj.dimensions
        args.dnd_obj = input_data{1};
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
    if numel(input_data) == 2
        if isa(input_data{1},'AxesBlockBase') && isa(input_data{2},'aProjectionBase')
            sz = input_data{1}.dims_as_ssize;
            strc = init_arrays_(struct(),sz);
            args.set_of_fields = [varargin(:);struct2cell(strc)];
        elseif isa(varargin{1},'dnd_metadata') && isa(varargin{2},'dnd_data')
            args.set_of_fields = varargin;
            args.keys = {'metadata','nd_data'};
        else
            error(['HORACE:', class(obj),':invalid_argument'], ...
                'Class constructor invoked with two unrecognised input arguments')
        end
    elseif numel(input_data) >= 5
        args.set_of_fields = input_data;
    else
        error(['HORACE:', class(obj),':invalid_argument'], ...
            'Unrecognised number or type of the input arguments')
    end

else
    error(['HORACE:', class(obj),':invalid_argument'], ...
        'unknown input for %s constructor',class(obj));
end
