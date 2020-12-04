function siz = hlp_serial_sise(v)
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
      case {'logical', 'char', 'string', 'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64', 'complex_double', 'complex_single', 'complex_int8', 'complex_uint8', 'complex_int16', 'complex_uint16', 'complex_int32', 'complex_uint32', 'complex_int64', 'complex_uint64'}
        siz = serial_sise_simple_data(v, type);
      case {'sparse_logical', 'sparse_double', 'sparse_complex_double'}
        siz = serial_sise_sparse_data(v, type);
      case 'struct'
        siz = serial_sise_struct(v, type);
      case 'cell'
        siz = serial_sise_cell(v, type);
      case {'value_object', 'handle_object_ref'}
        siz = serial_sise_object(v, type);
      case 'function_handle'
        siz = serial_sise_function_handle(v, type);
      otherwise
        error(['Cannot serial_sise ', type.name]);
    end

end

function siz = serial_sise_simple_data(v, type)
    nElem = numel(v);
    nDims = ndims(v);

    if nElem == 0 % Null element
        siz = 1 + 4; % Tag, 0
        % m = [uint8(32 + type.tag); typecast(uint32(0), 'uint8').'];
    elseif nElem == 1 % Scalar
        siz = 1 + type.size;
        % m = [uint8(type.tag); typecast(v, 'uint8').'];
    elseif nDims == 2 && size(v,1) == 1 % List
        siz = 1 + 4 + type.size*nElem;
        % m = [uint8(32 + type.tag); typecast(uint32(nElem), 'uint8').'; typecast(v, 'uint8').'];
    else % General array
        siz = 1 + 4 * nDims + type.size*nElem;
        % m = [uint8(bitshift(nDims, 5) + type.tag); typecast(uint32(size(v)), 'uint8').'; typecast(v(:).', 'uint8').'];
    end

end

% Sparse data types
function siz = serial_sise_sparse_data(v, type)

    nElem = nnz(v);

    siz = 1 + 2*4 + 4 + 2 * nElem * 8 + nElem*type.size;

    % m = [uint8(64 + type.tag); typecast(uint32(dims), 'uint8').'; typecast(uint32(nElem), 'uint8').'; typecast(i(:).', 'uint8').'; typecast(j(:).', 'uint8').'; typecast(data(:).', 'uint8').'];
end

% Struct array
function siz = serial_sise_struct(v, type)
    % Tag, Field Count, Field name lengths, Field name char data, #dimensions, dimensions
    fieldNames = fieldnames(v);
    nFields = numel(fieldNames);

    % Content.
    fn_siz = 4*(nFields+1) + sum(cellfun('length', fieldNames));

    if numel(v) > length(fieldNames)
        % more records than field names; serialise each field as a cell array to expose homogenous content
        data_siz = cellfun(@(f)serial_sise_cell({v.(f)}, type_mapping({})),fieldNames,'UniformOutput',false);
        data_siz = sum([data_siz{:}]) + 1;
        % data = cellfun(@(f)serialise_cell({v.(f)}, type_mapping({})),fieldNames,'UniformOutput',false);
        % data = [uint8(0); vertcat(data{:})];
    else
        % more field names (or equal) than records; use struct2cell
        data_siz = 1 + serial_sise_cell(struct2cell(v), type_mapping({}));
        % data = [uint8(1); serialise_cell(struct2cell(v), type_mapping({}))];
    end

    nElem = numel(v);
    nDims = ndims(v);

    if nElem == 0 % Null element
        siz = 1 + 4;
        % m = [uint8(32 + type.tag); typecast(uint32(0), 'uint8').'];
    elseif nElem == 1 % Scalar
        siz = 1 + fn_siz + data_siz;
        % m = [uint8(type.tag); fnInfo; data];
    elseif nDims == 2 && size(v,1) == 1 % List
        siz = 1 + 4 + fn_siz + data_siz;
        % m = [uint8(32 + type.tag); typecast(uint32(nElem), 'uint8').'; fnInfo; data];
    else % General array
        siz = 1 + 4*nDims + fn_siz + data_siz;
        % m = [uint8(bitshift(nDims, 5) + type.tag); typecast(uint32(size(v)), 'uint8'); fnInfo; data];
    end
end

function siz = serial_sise_cell(v, type)
% Cell array of heterogenous contents
    data_siz = cellfun(@hlp_serial_sise,v,'UniformOutput',false);
    data_siz = sum([data_siz{:}]);
    nElem = numel(v);
    nDims = ndims(v);

    if nElem == 0 % Null element
        siz = 1 + 4;
        % m = [uint8(32 + type.tag); typecast(uint32(0), 'uint8').'];
    elseif nElem == 1 % Scalar
        siz = 1 + data_siz;
        % m = [uint8(type.tag); data];
    elseif nDims == 2 && size(v,1) == 1 % List
        siz = 1 + 4 + data_siz;
        % m = [uint8(32 + type.tag); typecast(uint32(nElem), 'uint8').'; data];
    else % General array
        siz = 1 + 4*nDims + data_siz;
        % m = [uint8(bitshift(nDims, 5) + type.tag); typecast(uint32(size(v)), 'uint8').'; data];
    end
end

function siz = serial_sise_object(v, type)
    global type_details;
    nElem = numel(v);
    nDims = ndims(v);

    class_name_siz = 1 + 4 + numel(class(v));
    % can object serialise/deserialise itself?
    if any(strcmp(methods(v), 'serialize'))
            conts_siz = hlp_serial_sise(arrayfun(@(x) (x.serialize()), v));
    else
        try
            % try to use the saveobj method first to get the contents
            conts = arrayfun(@saveobj, v);
        catch
            conts = arrayfun(@struct, v);
        end
        if isstruct(conts) || iscell(conts) || isnumeric(conts) || ischar(conts) || islogical(conts) || isa(conts,'function_handle')
            % contents is something that we can readily serialize
            conts_siz = hlp_serial_sise(conts);
        else
            % contents is still an object: turn into a struct now
            conts_siz = serial_sise_struct(struct(conts));
        end
    end

    if nElem == 0 % Null element
        siz = 1 + 4 + class_name_siz;
        % m = [uint8(32 + type.tag); typecast(uint32(0), 'uint8').'; class_name];
    elseif nElem == 1 % Scalar
        siz = 1 + class_name_siz + 1 + conts_siz;
        % m = [uint8(type.tag); class_name; ser_tag; conts];
    elseif nDims == 2 && size(v,1) == 1 % List
        siz = 1 + 4 + class_name_siz + 1 + conts_siz;
        % m = [uint8(32 + type.tag); typecast(uint32(nElem), 'uint8').'; class_name; ser_tag; conts];
    else % General array
        siz = 1 + 4*nDims + class_name_siz + 1 + conts_siz;
        % m = [uint8(bitshift(nDims, 5) + type.tag); typecast(uint32(size(v)), 'uint8').'; class_name; ser_tag; conts];
    end

end

% Function handle
function siz = serial_sise_function_handle(v, type)
    global type_details;


    % get the representation
    rep = functions(v);
    switch rep.type
      case 'simple'
        % simple function: Tag & name

        siz = 1 + 1 + 4 + numel(rep.function);
        % m = [uint8(32+type.tag); serialise_simple_data(rep.function, type_details(2))];
      case 'anonymous'
        % anonymous function: Tag, Code, and reduced workspace

        siz = 1 + 1 + 4 + numel(char(v));
        if ~isempty(rep.workspace)
            siz = siz + serial_sise_struct(rep.workspace{1}, type_details(25));
            % m = [uint8(64+type.tag); serialise_simple_data(char(v), type_details(2)); serialise_struct(rep.workspace{1}, type_details(25))];
        else
            siz = siz + serial_sise_struct(struct(), type_details(25));
            % m = [uint8(64+type.tag); serialise_simple_data(char(v), type_details(2)); serialise_struct(struct(), type_details(25))];
        end
      case {'scopedfunction','nested'}
        % scoped function: Tag and Parentage

        siz = 1 + serial_sise_cell(rep.parentage, type_details(24));
        % m = [uint8(96+type.tag); serialise_cell(rep.parentage, type_details(24))];
      otherwise
        error('hlp_serial_sise:unknown_handle_type','A function handle with unsupported type "%s" was encountered; using a placeholder instead.',rep.type);
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