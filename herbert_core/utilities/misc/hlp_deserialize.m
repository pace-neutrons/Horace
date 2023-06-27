function [v,nbytes] = hlp_deserialise(m,pos)
% Convert a serialised byte vector back into the corresponding MATLAB data structure.
% Data = hlp_deserialise(Bytes)
%
% In:
%  m  :    a representation of the original data as a byte stream
%  pos:    if present, the initial location of the data to deserise in
%          within the byte array
% Out:
%   Data  : some MATLAB data structure deseriaised from the bytes
%  nbytes : number of bytes the structure occupies
% See also:
%   hlp_serialise
%
% Examples:
%   bytes = hlp_serialise(mydata);
%   ... e.g. transfer the 'bytes' array over the network ...
%   mydata = hlp_deserialise(bytes);
%
%   Jacob Wilkins, SCD, STFC RAL,
%   2020-12-24
%
%   adapted from hlp_deserialize.m
%   Christian Kothe, Swartz Center for Computational Neuroscience, UCSD
%   2010-04-02
%
%   adapted from deserialize.m
%   (C) 2010 Tim Hutt
if nargin==1
    pos = 1;
end
pos0 = pos;
m = m(:); % Force column vector in-place
[v,pos] = deserialise_value(m,pos);
nbytes = pos-pos0;
end

function [v,pos] = deserialise_value(m,pos)
%type = bitand(31, m(pos));
typeID = m(pos);

switch typeID
    case {0,1,2,3,4,5,6,7,8,9,10,11,12}
        [v,pos] = deserialise_simple_data(m,pos);
    case {13,14,15,16,17,18,19,20,21,22}
        [v,pos] = deserialise_complex_data(m,pos);
    case 23
        [v,pos] = deserialise_cell(m,pos);
    case {24}
        [v,pos] = deserialise_struct(m,pos);
    case {25, 25+64,25+128,25+192}
        [v,pos] = deserialise_function_handle(m,pos);
    case {26, 27}
        [v,pos] = deserialise_object(m,pos);
    case {29, 30, 31}
        [v,pos] = deserialise_sparse(m,pos);
    case 32
        [v,pos] = obj_deserialize_itself(m,pos);
    otherwise
        error('HORACE:hlp_deserialise:invalid_argument', ...
            'Cannot deserialise tag with ID: %d at position %d.',typeID,pos);
end
end

function [v,pos] = read_bytes(m, pos, type, n)
compFac = 1;
if startsWith(type, 'complex')
    type = type(9:end);
    compFac = 2;
end

type = hlp_serial_types.get_details(type);

nBytes = double(type.size*n*compFac);
v = typecast(m(pos:pos+nBytes-1), type.name).';
pos = pos + nBytes;
end

function [v,pos] = deserialise_simple_data(m, pos)
[type, nDims,size,pos] = hlp_serial_types.unpack_data_tag(m,pos);

switch type.name
    case {'logical', 'char', 'string'}
        field_width = 'uint8';
    otherwise
        field_width = type.name;
end

if nDims > 0
    nData = prod(size);
    [v, pos] = read_bytes(m, pos, field_width, nData);
else
    v = [];
end

switch type.name
    case 'logical'
        v = logical(v);
    case 'char'
        v = char(v);
    case 'string'
        v = convertCharsToStrings(char(v));
end

if nDims > 1
    v = reshape(v, size);
end
end

function [v, pos] = deserialise_complex_data(m, pos)
[type, nDims,size,pos] = hlp_serial_types.unpack_data_tag(m,pos);

if nDims == 0
    v = [];
else
    totalElem = prod(size);
    [data, pos] = read_bytes(m, pos, type.name, totalElem);
    v = complex(data(1:totalElem), data(totalElem+1:end));
end

if nDims > 1
    v = reshape(v, size);
end
end

% Sparse data types
function [v, pos] = deserialise_sparse(m, pos)
% second value, nDims should be always 2
[type, ~,sze,pos] = hlp_serial_types.unpack_data_tag(m,pos);


[nElem, pos] = read_bytes(m, pos, 'uint32', 1);
if isempty(sze)
    v = sparse([],[],[]);
    return;
end

switch type.name
    case 'sparse_logical'
        data_format = 'uint8';
    otherwise
        data_format = type.name(8:end);
end


[i, pos] = read_bytes(m, pos, 'uint64', nElem);
[j, pos] = read_bytes(m, pos, 'uint64', nElem);
% beware that C API which indexes from 0, not 1. Better to do alignment in
% API itself, as C would do it quicker
i = double(i);
j = double(j);
[data, pos] = read_bytes(m, pos, data_format, nElem);

switch type.name
    case 'sparse_logical'
        data = logical(data);
    case 'sparse_complex_double'
        data = complex(data(1:nElem), data(nElem+1:end));
    otherwise
end

v = sparse(i,j,data,sze(1),sze(2));
end

function [v, pos] = deserialise_cell(m, pos)
[~, nDims,fh_size,pos] = hlp_serial_types.unpack_data_tag(m,pos);

if nDims == 0
    v = {};
else
    totalElem = prod(fh_size);
    v = cell(1,totalElem);
    for i=1:totalElem
        [v{i}, pos] = deserialise_value(m, pos);
    end
end

if nDims > 1
    v = reshape(v,fh_size);
end

end

function [v, pos] = deserialise_struct(m, pos)
[~, nDims,fh_size,pos] = hlp_serial_types.unpack_data_tag(m,pos);

nElems = prod(fh_size);
if nDims == 0 && isempty(fh_size)
    v = struct([]);
    return;
elseif nDims == 1
    if nElems == 0
        v = struct();
        return
    else
        %v = reshape(struct(), [1 nElems]);
    end
else
    %v = reshape(struct(), [nElems 1 1]);
end

% Number of field names.
[nFields, pos] = read_bytes(m, pos, 'uint32', 1);
nFields = double(nFields);
if nFields == 0
    v = reshape(struct(), fh_size);
    return;
end

% Field name lengths
[fnLengths, pos] = read_bytes(m, pos, 'uint32', nFields);
fnLengths = double(fnLengths);
% Field name char data
[fnChars, pos] = read_bytes(m, pos, 'uint8', sum(fnLengths));
fnChars = char(fnChars);
% Field names.
splits = [0, cumsum(fnLengths)];
fieldNames = arrayfun(@(start,size)(fnChars(start+1:start+size)),...
    splits(1:end-1),fnLengths,'UniformOutput',false);
%
% using struct2cell
[contents,pos] = deserialise_value(m,pos);
v = cell2struct(contents,fieldNames,1);
end

function [v, pos] = deserialise_function_handle(m, pos)
[~, ~,fTag,pos] = hlp_serial_types.unpack_data_tag(m,pos);

switch fTag
    case 64 % Simple
        [name, pos] = deserialise_simple_data(m, pos);
        v = str2func(name);
    case 128 % Anonymous
        [code, pos] = deserialise_simple_data(m, pos);
        [workspace, pos] = deserialise_struct(m, pos);
        v = restore_function(code, workspace);
    case 192 % Scoped/Nested
        [parentage, pos] = deserialise_cell(m, pos);
        % recursively look up from parents, assuming that these support the arg system
        v = parentage{end};
        for k=length(parentage)-1:-1:1
            % Note: if you get an error here, you are trying to deserialize a function handle
            % to a nested function. This is not natively supported by MATLAB and can only be made
            % to work if your function's parent implements some mechanism to return such a handle.
            % The below call assumes that your function uses the BCILAB arg system to do this.
            try
                v = arg_report('handle',v,parentage{k});
            catch
                error('MATLAB:deserialise_function_handle:hlp_deserialise',...
                    'Cannot deserialise a function handle to a nested function.')
            end
        end
end
end

function [v,pos]=obj_deserialize_itself(m,pos)
% first position is the self-serialization tag. The serializable starts from
% the following byte
[v,nbytes] = serializable.deserialize(m,pos+1);
pos = pos+1+nbytes;
end


function [v, pos] = deserialise_object(m, pos)
[~, nDims,size,pos] = hlp_serial_types.unpack_data_tag(m,pos);

totalElem = prod(size);
[class_name, pos] = deserialise_simple_data(m, pos);

if totalElem == 0
    v = feval(class_name);
else
    [ser_tag, pos] = read_bytes(m, pos, 'uint8', 1);

    if strcmp(class_name, 'MException')
        class_name = 'MException_her';
        ser_tag = 2;
    end

    switch ser_tag
        case 0 % Object serialises itself
            v(1:totalElem) = feval(class_name);
            for i=1:totalElem
                [v(i),nbytes] = v(i).deserialize(m, pos);
                pos = pos+nbytes;
            end
        case 1 % Serialise as saveobj (must have loadobj)
            [conts, pos] = deserialise_value(m, pos);
            % Preallocate
            cls = str2func([class_name '.loadobj']);
            v = arrayfun(cls, conts);
        case 2 % Serialise as struct
            [conts, pos] = deserialise_value(m, pos);
            % Preallocate

            cls = str2func(class_name);
            v = arrayfun(cls, conts);
    end
end

if nDims > 1
    v = reshape(v, size);
end
end
