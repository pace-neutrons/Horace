function m = hlp_serialise(v)
% Convert a MATLAB data structure into a compact byte vector.
% Bytes = hlp_serialise(Data)
%
% The original data structure can be recovered from the byte vector via hlp_deserialise.
%
% In:
%   Data : some MATLAB data structure
%
% Out:
%   Bytes : a representation of the original data as a byte stream
%
% Notes:
%   The code is a rewrite of Tim Hutt's serialization code. Support has been added for correct
%   recovery of sparse, complex, single, (u)intX, function handles, anonymous functions, objects,
%   and structures with unlimited field count. Serialize/deserialize performance is ~10x higher.
%
% Limitations:
%   * Java objects cannot be serialized
%   * Arrays with more than 7 ranks have their last dimensions clamped
%   * Handles to nested/scoped functions can only be deserialized when their parent functions
%     support the BCILAB argument reporting protocol (e.g., by using arg_define).
%   * New MATLAB objects need to be reasonably friendly to serialization; either they support
%     construction from a struct, or they support saveobj/loadobj(struct), or all their important
%     properties can be set via set(obj,'name',value)
%   * In anonymous functions, accessing unreferenced variables in the workspace of the original
%     declaration is not possible
%
% See also:
%   hlp_deserialise
%
% Examples:
%   bytes = hlp_serialise(mydata);
%   ... e.g. transfer the 'bytes' array over the network ...
%   mydata = hlp_deserialise(bytes);
%
%    Jacob Wilkins, SCD, STFC RAL,
%    2020-12-24
%
%    adapted from hlp_serialize.m
%    Christian Kothe, Swartz Center for Computational Neuroscience, UCSD
%    2010-04-02
%
%    adapted from serialize.m
%    (C) 2010 Tim Hutt

if any(size(v) > intmax('uint32'))
    error("MATLAB:serialise:bad_size",...
        "Dimensions of array exceed limit of uint32, cannot serialise.")
end

type = hlp_serial_types.type_mapping(v);
switch type.name
    case {'logical', 'char', 'string', 'double', 'single', 'int8', ...
            'uint8','int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64'}
        m = serialise_simple_data(v, type);
    case {'complex_double', 'complex_single', 'complex_int8',...
            'complex_uint8', 'complex_int16', 'complex_uint16', ...
            'complex_int32', 'complex_uint32', 'complex_int64',...
            'complex_uint64'}
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
    case {'serializable'}
        m = serialize_themselves(v,type);
    otherwise
        error('MATLAB:hlp_serialise:bad_type', 'Cannot serialise type %s.', type.name);
end
end

% Simple data types
function m = serialise_simple_data(v, type)
nElem = numel(v);
comb_tag = hlp_serial_types.pack_data_tag(size(v),type);

switch type.name
    case {'string'}
        v = uint8(convertStringsToChars(v));
    case {'logical', 'char'}
        v = uint8(v);
end

if nElem == 0 % Null element
    m = comb_tag;
else %
    m = [comb_tag; typecast(v(:)', 'uint8')'];
end
end

% Complex data types
function m = serialise_complex_data(v, type)
nElem = numel(v);
comb_tag = hlp_serial_types.pack_data_tag(size(v),type);

if nElem == 0 % Null element
    m = comb_tag;
elseif nElem == 1 % Scalar
    m = [comb_tag; ...
        typecast(real(v), 'uint8').'; ...
        typecast(imag(v), 'uint8').'];
else% General array
    m = [comb_tag; ...
        typecast(real(v(:)), 'uint8'); ...
        typecast(imag(v(:)), 'uint8')];
end
end

% Sparse data types
function m = serialise_sparse_data(v, type)

[i,j,data] = find(v);
%nElem = nzmax(v); % beware that we may serialize matrix with preallocated
%elements but will deserialize the matrix without these elements
nElem = nnz(v);
%
comb_tag = hlp_serial_types.pack_data_tag(size(v),type,1);

switch type.name
    case 'sparse_logical'
        data = uint8(data);
    case 'sparse_complex_double'
        data = [real(data(:)); imag(data(:))];
end

m = [comb_tag; ...
    typecast(uint32(nElem), 'uint8')'; ... % is 32 bytes enough for all elements?
    typecast(uint64(i(:))', 'uint8')'; ...
    typecast(uint64(j(:))', 'uint8')'; ...
    typecast(data(:)', 'uint8')'];
end

% Struct array
function m = serialise_struct(v, type)

nElem = numel(v);
if nElem>0
    fieldNames = fieldnames(v);
    %fnInfo = serialize_cell(fieldNames',hlp_serial_types.get_details('cell'));
    fnLengths = [length(fieldNames); cellfun('length',fieldNames)];
    fnChars = [fieldNames{:}];

    %Content.
    fnInfo = [typecast(uint32(fnLengths)','uint8')'; uint8(fnChars')];
else
    fieldNames ={};
end
if isempty(fieldNames)
    data = [];
else
    data = serialise_cell(struct2cell(v), hlp_serial_types.get_details('cell'));
end

comb_tag = hlp_serial_types.pack_data_tag(size(v),type);
if nElem == 0 % Null element
    m = comb_tag;
else
    m = [comb_tag; fnInfo; data];
end
end

function m = serialise_cell(v, type)
% Cell array of heterogenous contents
data = cellfun(@hlp_serialise,v,'UniformOutput',false);
data = vertcat(data{:});

comb_tag = hlp_serial_types.pack_data_tag(size(v),type);
nElem = numel(v);

if nElem == 0 % Null element
    m = comb_tag ;
else
    m = [comb_tag;data];
end
end

function m = serialize_themselves(v, type)
% serializable type serializes itself
m = [type.tag;v.serialize()];
end

function m = serialise_object(v, type)
%
comb_tag = hlp_serial_types.pack_data_tag(size(v),type);
nElem = numel(v);

class_name = serialise_simple_data(class(v), hlp_serial_types.get_details('char'));
% can object serialise/deserialise itself?
if ismethod(v, 'serialize')
    conts = arrayfun(@(x) (x.serialize()), v);
    ser_tag = uint8(0);
else
    try
        % try to use the saveobj method first to get the contents
        conts = arrayfun(@saveobj, v);
        if isobject(conts) % object has native saveobj, which has not been overloaded
            conts =arrayfun(@struct, v);
            ser_tag = uint8(2);
        else
            ser_tag = uint8(1);
        end
    catch
        conts = arrayfun(@struct, v);
        ser_tag = uint8(2);
    end
    conts = hlp_serialise(conts);
end
if nElem == 0 % Null element
    m = [comb_tag; class_name];
else
    m = [comb_tag; class_name; ser_tag; conts];
end
end

% Function handle
function m = serialise_function_handle(v, type)
% get the representation
rep = functions(v);

%Possible types are:
%  switch rep.type
%     % Tag is used to distinguish function type
%     case {'simple', 'classsimple'}
%         % simple function
%     case 'anonymous'
%         % anonymous function
%     case {'scopedfunction','nested'}
%         % scoped function
% end
comb_tag = hlp_serial_types.pack_data_tag(size(rep),type,rep.type);

switch rep.type
    % Tag is used to distinguish function type
    case {'simple', 'classsimple'}
        % simple function
        m = [comb_tag; ... Tag
            serialise_simple_data(rep.function, hlp_serial_types.get_details('char'))]; % Name of function
    case 'anonymous'
        % anonymous function
        m = [comb_tag; ... Tag
            serialise_simple_data(char(v), hlp_serial_types.get_details('char')); ... % Code
            serialise_struct(rep.workspace{1}, hlp_serial_types.get_details('struct'))]; % Workspace

    case {'scopedfunction','nested'}
        % scoped function
        m = [comb_tag; ... Tag
            serialise_cell(rep.parentage, hlp_serial_types.get_details('cell'))]; % Parentage
    otherwise
        warn_once('hlp_serialise:unknown_handle_type','A function handle with unsupported type "%s" was encountered; using a placeholder instead.',rep.type);
        m = serialise_string(['<<hlp_serialise: function handle of type ' rep.type ' unsupported>>']);
end
end
