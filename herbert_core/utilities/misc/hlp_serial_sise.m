function siz = hlp_serial_sise(v)
% Calculate the size (in bytes) of Matlab structure, which would be produced by
% hlp_serialise routine. Deduced from hlp_serialise/
%
% See also:
%   hlp_serialise
%   hlp_deserialise
%
% Examples:
%   >>num_bytes = hlp_serial_sise(mydata);
%   >>bytes = hlp_serialise(mydata)
%   >>numel(bytes) == num_bytes
%   >>True
%
%   dispatch according to type
%

    type = hlp_serial_types.type_mapping(v);
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

        % Tag; 0
        siz = hlp_serial_types.tag_size + hlp_serial_types.dim_size;
    elseif nElem == 1 % Scalar

        % Tag; data
        siz = hlp_serial_types.tag_size + type.size;
    elseif nDims == 2 && size(v,1) == 1 % List

        siz = hlp_serial_types.tag_size + ... Tag
              hlp_serial_types.dim_size + ... nElem
              type.size*nElem; % Data
    else % General array

        siz = hlp_serial_types.tag_size + ... Tag
              hlp_serial_types.dim_size * nDims +... Dims
              type.size*nElem; % Data
    end

end

% Sparse data types
function siz = serial_sise_sparse_data(v, type)

    nElem = nnz(v);

    % Sparse data use uint64 indices and dims
    siz = hlp_serial_types.tag_size + ... Tag
          2*hlp_serial_types.dim_size + ... Dims
          hlp_serial_types.dim_size +... Num non-zero
          2 * nElem * hlp_serial_types.get_size('uint64') + ... Ir/Jc
          nElem*type.size; % Data
end

% Struct array
function siz = serial_sise_struct(v, type)
    % Tag, Field Count, Field name lengths, Field name char data, #dimensions, dimensions
    fieldNames = fieldnames(v);
    nFields = numel(fieldNames);

    % Field names sizes.
    fn_siz = hlp_serial_types.dim_size*(nFields+1) + ... Lengths of each field, +1 for nFields
             sum(cellfun('length', fieldNames)); % Each fieldname string

    if ~isempty(fieldNames)
        % Convert to cell, and calculate its size
        data_siz = serial_sise_cell(struct2cell(v), hlp_serial_types.get_details('cell'));
    else
        % Otherwise, no data
        data_siz = 0;
    end

    nElem = numel(v);
    nDims = ndims(v);

    if nElem == 0 % Null element

        % Tag; 0
        siz = hlp_serial_types.tag_size + hlp_serial_types.dim_size;
    elseif nElem == 1 % Scalar

        % Tag; FieldName block size; data size
        siz = hlp_serial_types.tag_size + fn_siz + data_siz;
    elseif nDims == 2 && size(v,1) == 1 % List

        % Tag; nElem; FieldName block size; data size
        siz = hlp_serial_types.tag_size + hlp_serial_types.dim_size + fn_siz + data_siz;
    else % General array

        % Tag; dims; FieldName block size; data size
        siz = hlp_serial_types.tag_size + hlp_serial_types.dim_size*nDims + fn_siz + data_siz;
    end
end

function siz = serial_sise_cell(v, type)
% Cell array of heterogenous contents
    data_siz = cellfun(@hlp_serial_sise,v,'UniformOutput',false);
    data_siz = sum([data_siz{:}]);
    nElem = numel(v);
    nDims = ndims(v);

    if nElem == 0 % Null element

        % Tag; 0
        siz = hlp_serial_types.tag_size + hlp_serial_types.dim_size;
    elseif nElem == 1 % Scalar

        % Tag; data
        siz = hlp_serial_types.tag_size + data_siz;
    elseif nDims == 2 && size(v,1) == 1 % List

        % Tag; nElem; data
        siz = hlp_serial_types.tag_size + hlp_serial_types.dim_size + data_siz;
    else % General array

        % Tag; dims; data
        siz = hlp_serial_types.tag_size + hlp_serial_types.dim_size*nDims + data_siz;
    end
end

function siz = serial_sise_object(v, type)
    nElem = numel(v);
    nDims = ndims(v);

    % Serialise class name as char string
    class_name_siz = hlp_serial_types.tag_size + hlp_serial_types.dim_size + numel(class(v));
       
    if any(strcmp(methods(v), 'serial_size'))    % can object calculate its size itself?    
        nElem = 1;
        nDims = 2;
        conts_siz = v.serial_size();        
    elseif any(strcmp(methods(v), 'serialize'))    % can object serialise/deserialise itself?
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

        % Tag; 0; name
        siz = hlp_serial_types.tag_size + hlp_serial_types.dim_size + class_name_siz;
    elseif nElem == 1 % Scalar

        % Tag; name; ser_tag; contents
        siz = hlp_serial_types.tag_size + class_name_siz + hlp_serial_types.tag_size + conts_siz;
    elseif nDims == 2 && size(v,1) == 1 % List

        % Tag; nElem; name; ser_tag; contents
        siz = hlp_serial_types.tag_size + hlp_serial_types.dim_size + class_name_siz + hlp_serial_types.tag_size + conts_siz;
    else % General array

        % Tag; dims; name; ser_tag; contents
        siz = hlp_serial_types.tag_size + hlp_serial_types.dim_size*nDims + class_name_siz + hlp_serial_types.tag_size + conts_siz;
    end

end

% Function handle
function siz = serial_sise_function_handle(v, type)
    % get the representation
    rep = functions(v);
    switch rep.type
      case {'simple', 'classsimple'}
        % simple function: Tag & name

        siz = hlp_serial_types.tag_size +...
              hlp_serial_types.tag_size + hlp_serial_types.dim_size + numel(rep.function); % String of name
      case 'anonymous'

        % anonymous function: Tag, Code, and reduced workspace
        siz = hlp_serial_types.tag_size +...
              hlp_serial_types.tag_size + hlp_serial_types.dim_size + numel(char(v)); % Code as string
        if ~isempty(rep.workspace)

            % If workspace, serialise it
            siz = siz + serial_sise_struct(rep.workspace{1}, hlp_serial_types.get_details('struct'));
        else

            % If workspace, else serialise an empty struct
            siz = siz + serial_sise_struct(struct(), hlp_serial_types.get_details('struct'));
        end
      case {'scopedfunction','nested'}

        % scoped function: Tag and Parentage
        siz = hlp_serial_types.tag_size + ...
              serial_sise_cell(rep.parentage, hlp_serial_types.get_details('cell'));

      otherwise
        error('hlp_serial_sise:unknown_handle_type','A function handle with unsupported type "%s" was encountered; using a placeholder instead.',rep.type);
    end
end
