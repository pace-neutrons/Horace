function m = hlp_serialise(v)
    global type_details;
    global lookup;
    if isempty(type_details)
        classes = {'logical', 'char', 'string', 'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64', 'complex_double', 'complex_single', 'complex_int8', 'complex_uint8', 'complex_int16', 'complex_uint16', 'complex_int32', 'complex_uint32', 'complex_int64', 'complex_uint64', 'cell', 'struct', 'function_handle', 'value_object', 'handle_object_ref', 'enum', 'sparse_logical', 'sparse_double', 'sparse_complex_double'};

        lookup = containers.Map(classes, 1:32);
        type_details = struct('name',...
                              {'logical', 'char', 'string', 'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64', 'complex_double', 'complex_single', 'complex_int8', 'complex_uint8', 'complex_int16', 'complex_uint16', 'complex_int32', 'complex_uint32', 'complex_int64', 'complex_uint64', 'cell', 'struct', 'function_handle', 'value_object', 'handle_object_ref', 'enum', 'sparse_logical', 'sparse_double', 'sparse_complex_double'},...
                              'size',...
                              {1, 1, 2, 8, 4, 1, 1, 2, 2, 4, 4, 8, 8, 16, 8, 2, 2, 4, 4, 8, 8, 16, 16, 0, 0, 0, 0, 0, 0, 1, 8, 16},...
                              'tag',...
                              {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31});

    end

    type = type_mapping(v);
    switch type.name
      case {'logical', 'char', 'string', 'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64'}
        m = serialise_simple_data(v, type);
      case {'complex_double', 'complex_single', 'complex_int8', 'complex_uint8', 'complex_int16', 'complex_uint16', 'complex_int32', 'complex_uint32', 'complex_int64', 'complex_uint64'}
        m = serialise_complex_data(v, type);
      case {'sparse_logical', 'sparse_double', 'sparse_complex_double'}
        m = serialise_sparse_data(v, type);
      case 'struct'
        m = serialise_struct(v, type);
      case 'cell'
        m = serialise_cell(v, type);
      case {'value_object', 'handle_object_ref'}
        m = serialise_object(v, type);
      case 'function_handle'
        m = serialise_function_handle(v, type);
      otherwise
        error(['Cannot serialise ', type.name]);
    end
end

% Simple data types
function m = serialise_simple_data(v, type)
    nElem = numel(v);
    nDims = uint8(ndims(v));

    switch type.name
      case {'string'}
        v = uint8(convertStringsToChars(v));
      case {'logical', 'char'}
        v = uint8(v);
    end

    if nElem == 0 % Null element
        m = [uint8(32 + type.tag); typecast(uint32(0), 'uint8').'];
    elseif nElem == 1 % Scalar
        m = [uint8(type.tag); typecast(v, 'uint8').'];
    elseif nDims == 2 && size(v,1) == 1 % List
        m = [uint8(32 + type.tag); typecast(uint32(nElem), 'uint8').'; typecast(v, 'uint8').'];
    else % General array
        m = [uint8(bitshift(nDims, 5) + type.tag); typecast(uint32(size(v)), 'uint8').'; typecast(v(:).', 'uint8').'];
    end
end

% Complex data types
function m = serialise_complex_data(v, type)
    nElem = numel(v);
    nDims = uint8(ndims(v));
    if nElem == 0 % Null element
        m = [uint8(32 + type.tag); typecast(uint32(0), 'uint8')];
    elseif nElem == 1 % Scalar
        m = [uint8(type.tag); typecast(real(v), 'uint8').'; typecast(imag(v), 'uint8').'];
    elseif nDims == 2 && size(v,1) == 1 % List
        m = [uint8(32 + type.tag); typecast(uint32(nElem), 'uint8').'; typecast(real(v), 'uint8').'; typecast(imag(v), 'uint8').'];
    else % General array
        m = [uint8(bitshift(nDims, 5) + type.tag); typecast(uint32(size(v)), 'uint8').'; typecast(real(v(:)), 'uint8'); typecast(imag(v(:)), 'uint8')];
    end
end

% Sparse data types
function m = serialise_sparse_data(v, type)

    [i,j,data] = find(v);

    switch type.name
      case 'sparse_logical'
        data = uint8(data);
      case 'sparse_complex_double'
        data = [real(data(:)); imag(data(:))];
    end

    dims = size(v);
    nElem = nnz(v);

    m = [uint8(64 + type.tag); typecast(uint32(dims), 'uint8').'; typecast(uint32(nElem), 'uint8').'; typecast(uint64(i(:)-1).', 'uint8').'; typecast(uint64(j(:)-1).', 'uint8').'; typecast(data(:).', 'uint8').'];
end


% Struct array
function m = serialise_struct(v, type)
% Tag, Field Count, Field name lengths, Field name char data, #dimensions, dimensions
    fieldNames = fieldnames(v);
    fnLengths = [length(fieldNames); cellfun('length',fieldNames)];
    fnChars = [fieldNames{:}];
    % dims = [ndims(v) size(v)];

    % Content.
    fnInfo = [typecast(uint32(fnLengths(:)).','uint8').'; uint8(fnChars(:))];

    if ~isempty(fieldNames)
        data = serialise_cell(struct2cell(v), type_mapping({}));
    else
        data = [];
    end

    nElem = numel(v);
    nDims = uint8(ndims(v));

    if nElem == 0 % Null element
        m = [uint8(32 + type.tag); typecast(uint32(0), 'uint8').'];
    elseif nElem == 1 % Scalar
        m = [uint8(type.tag); fnInfo; data];
    elseif nDims == 2 && size(v,1) == 1 % List
        m = [uint8(32 + type.tag); typecast(uint32(nElem), 'uint8').'; fnInfo; data];
    else % General array
        m = [uint8(bitshift(nDims, 5) + type.tag); typecast(uint32(size(v)), 'uint8').'; fnInfo; data];
    end
end

function m = serialise_cell(v, type)
% Cell array of heterogenous contents
    data = cellfun(@hlp_serialise,v,'UniformOutput',false);
    data = vertcat(data{:});
    nElem = numel(v);
    nDims = uint8(ndims(v));

    if nElem == 0 % Null element
        m = [uint8(32 + type.tag); typecast(uint32(0), 'uint8').'];
    elseif nElem == 1 % Scalar
        m = [uint8(type.tag); data];
    elseif nDims == 2 && size(v,1) == 1 % List
        m = [uint8(32 + type.tag); typecast(uint32(nElem), 'uint8').'; data];
    else % General array
        m = [uint8(bitshift(nDims, 5) + type.tag); typecast(uint32(size(v)), 'uint8').'; data];
    end
end

function m = serialise_object(v, type)
    global type_details;
    nElem = numel(v);
    nDims = uint8(ndims(v));

    class_name = serialise_simple_data(class(v), type_details(2));
    % can object serialise/deserialise itself?
    if any(strcmp(methods(v), 'serialize'))
            conts = arrayfun(@(x) (x.serialize()), v);
            ser_tag = uint8(0);
    else
        try
            % try to use the saveobj method first to get the contents
            conts = arrayfun(@saveobj, v);
            ser_tag = uint8(1);
        catch
            conts = arrayfun(@struct, v);
            ser_tag = uint8(2);
        end
        if isstruct(conts) || iscell(conts) || isnumeric(conts) || ischar(conts) || islogical(conts) || isa(conts,'function_handle')
            % contents is something that we can readily serialize
            conts = hlp_serialise(conts);
        else
            % contents is still an object: turn into a struct now
            conts = serialise_struct(struct(conts));
        end
    end
    if nElem == 0 % Null element
        m = [uint8(32 + type.tag); typecast(uint32(0), 'uint8').'; class_name];
    elseif nElem == 1 % Scalar
        m = [uint8(type.tag); class_name; ser_tag; conts];
    elseif nDims == 2 && size(v,1) == 1 % List
        m = [uint8(32 + type.tag); typecast(uint32(nElem), 'uint8').'; class_name; ser_tag; conts];
    else % General array
        m = [uint8(bitshift(nDims, 5) + type.tag); typecast(uint32(size(v)), 'uint8').'; class_name; ser_tag; conts];
    end

end

% Function handle
function m = serialise_function_handle(v, type)
    global type_details;

    % get the representation
    rep = functions(v);
    switch rep.type
      case {'simple', 'classsimple'}
        % simple function: Tag & name
        m = [uint8(32+type.tag); serialise_simple_data(rep.function, type_details(2))];
      case 'anonymous'
        % anonymous function: Tag, Code, and reduced workspace
        m = [uint8(64+type.tag); serialise_simple_data(char(v), type_details(2)); serialise_struct(rep.workspace{1}, type_details(25))];

      case {'scopedfunction','nested'}
        % scoped function: Tag and Parentage
        m = [uint8(96+type.tag); serialise_cell(rep.parentage, type_details(24))];
      otherwise
        warn_once('hlp_serialise:unknown_handle_type','A function handle with unsupported type "%s" was encountered; using a placeholder instead.',rep.type);
        m = serialise_string(['<<hlp_serialise: function handle of type ' rep.type ' unsupported>>']);
    end
end

function obj = type_mapping(v)
    global type_details;
    global lookup;
    type = class(v);

    if isnumeric(v) && ~isreal(v)
        type = ['complex_' type];
    end
    if issparse(v)
        type = ['sparse_' type];
    end

    if isKey(lookup, type)
        obj = type_details(lookup(type));
    elseif ishandle(v)
        obj = type_details(lookup('handle_object'));
    else
        obj = type_details(lookup('value_object'));
    end

end