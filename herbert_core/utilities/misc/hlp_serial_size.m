function siz = hlp_serial_size(v)
% Calculate the size (in bytes) of Matlab structure, which would be produced by
% hlp_serialize routine. Deduced from hlp_serialize/
%
% See also:
%   hlp_serialize
%   hlp_deserialize
%
% Examples:
%   >>num_bytes = hlp_serial_size(mydata);
%   >>bytes = hlp_serialize(mydata)
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
    case 'serializable'
        siz = serial_sise_itself(v, type);
    otherwise
        error(['Cannot serial_sise ', type.name]);
end

end

function siz = serial_sise_simple_data(v, type_str)
siz = hlp_serial_types.calc_tag_size(size(v),type_str);

nElem = numel(v);
if nElem == 0 % Null element
    return;
else
    siz = siz+type_str.size*nElem; % Data
end

end

% Sparse data types
function siz = serial_sise_sparse_data(v, type_str)
nElem = nnz(v);
siz = hlp_serial_types.calc_tag_size(size(v),type_str,1)+...
    hlp_serial_types.dim_size + ... % add size for number of elements
    2*8*nElem +... % i,j of 64-bit indexes
    nElem*type_str.size; % data
%typecast(uint32(nElem), 'uint8')'; ... % is 32 bytes enough for all elements?
%typecast(uint64(i(:))', 'uint8')'; ...
%typecast(uint64(j(:))', 'uint8')'; ...
%typecast(data(:)', 'uint8')'];

end

% Struct array
function siz = serial_sise_struct(v, type_str)
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

siz = hlp_serial_types.calc_tag_size(size(v),type_str);
if nElem == 0 % Null element
    % Tag; 0
    return
else
    % Tag; FieldName block size; data size
    siz = siz + fn_siz + data_siz;
end
end

function siz = serial_sise_cell(v, type_str)
% Cell array of heterogenous contents
data_siz = cellfun(@hlp_serial_size,v,'UniformOutput',false);
data_siz = sum([data_siz{:}]);
nElem = numel(v);
siz = hlp_serial_types.calc_tag_size(size(v),type_str);
if nElem == 0 % Null element
    return;
else
    siz = siz+ data_siz;
end
end
%
function  siz = serial_sise_itself(v, ~)
% one for tag;
siz = v.serial_size()+1;
end

function siz = serial_sise_object(v, type_str)

siz = hlp_serial_types.calc_tag_size(size(v),type_str);
% Serialise class name as char string
siz =siz + serial_sise_simple_data(class(v), hlp_serial_types.get_details('char'));

nElem  = numel(v);
if nElem > 0
    siz =siz + 1; % add serialization tag size
    if ismethod(v, 'serialize')    % can object serialise/deserialise itself?
        if ismethod(v,'serial_size')
            conts = arrayfun(@(x) (x.serial_size()), v);
            conts_siz = sum(conts);
        else
            conts_siz = hlp_serial_size(arrayfun(@(x) (x.serialize()), v));
        end
    else
        try
            % try to use the saveobj method first to get the contents
            conts = arrayfun(@saveobj, v);
            if isobject(conts) % saveobj has not been overloaded
                conts = arrayfun(@struct,v);
            end
        catch
            conts = arrayfun(@struct, v);
        end
        conts_siz = hlp_serial_size(conts);
    end
    siz = siz+conts_siz;
else
    return;
end
end

% Function handle
function siz = serial_sise_function_handle(v, type_struc)
% get the representation
rep = functions(v);
%
tag_size = hlp_serial_types.calc_tag_size(size(rep),type_struc);
switch rep.type
    case {'simple', 'classsimple'}
        % simple function: Tag & name

        siz = tag_size  +...
            serial_sise_simple_data(rep.function, hlp_serial_types.get_details('char')); % String of name
    case 'anonymous'
        % anonymous function: Tag, Code, and reduced workspace
        siz = tag_size +...
            serial_sise_simple_data(char(v), hlp_serial_types.get_details('char'))+... % Code
            serial_sise_struct(rep.workspace{1}, hlp_serial_types.get_details('struct'));
    case {'scopedfunction','nested'}
        %
        % scoped function: Tag and Parentage
        siz = tag_size + ... Tag
            serial_sise_cell(rep.parentage, hlp_serial_types.get_details('cell')); % Parentage
    otherwise
        warn_once('hlp_serialize:unknown_handle_type','A function handle with unsupported type "%s" was encountered; using a placeholder instead.',rep.type);
        siz = tag_size+...
            serial_sise_simple_data(['<<hlp_serialize: function handle of type ' rep.type ' unsupported>>'],...
            hlp_serial_types.get_details('char'));
end
end
