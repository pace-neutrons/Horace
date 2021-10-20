function [v,nbytes] = hlp_deserialise(m,pos)
% Convert a serialised byte vector back into the corresponding MATLAB data structure.
% Data = hlp_deserialise(Bytes)
%
% In:
%   Bytes : a representation of the original data as a byte stream
%
% Out:
%   Data : some MATLAB data structure
%
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
type = bitand(31, m(pos));

switch type
    case {0,1,2,3,4,5,6,7,8,9,10,11,12}
        [v,pos] = deserialise_simple_data(m,pos);
    case {13,14,15,16,17,18,19,20,21,22}
        [v,pos] = deserialise_complex_data(m,pos);
    case {23}
        [v,pos] = deserialise_cell(m,pos);
    case {24}
        [v,pos] = deserialise_struct(m,pos);
    case {25}
        [v,pos] = deserialise_function_handle(m,pos);
    case {26, 27}
        [v,pos] = deserialise_object(m,pos);
    case {29, 30, 31}
        [v,pos] = deserialise_sparse(m,pos);
    otherwise
        error('MATLAB:deserialise_value:unrecognised_tag', 'Cannot deserialise tag %s.', hlp_serial_types.type_details(type+1).name);
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
[type, nDims, pos] = get_tag_data(m, pos);

switch type.name
    case {'logical', 'char', 'string'}
        deserialiser = 'uint8';
    otherwise
        deserialiser = type.name;
end

if nDims == 0
    [v, pos] = read_bytes(m, pos, deserialiser, 1);
else
    [nElems, pos] = read_bytes(m, pos, 'uint32', nDims);
    totalElem = prod(nElems);
    if totalElem == 0
        v = [];
    else
        [v, pos] = read_bytes(m, pos, deserialiser, totalElem);
    end
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
    v = reshape(v, nElems);
end
end

function [v, pos] = deserialise_complex_data(m, pos)

[type, nDims, pos] = get_tag_data(m, pos);


if nDims == 0
    [data, pos] = read_bytes(m, pos, type.name, 1);
    v = complex(data(1), data(2));
else
    [nElems, pos] = read_bytes(m, pos, 'uint32', nDims);
    totalElem = prod(nElems);
    [data, pos] = read_bytes(m, pos, type.name, totalElem);
    v = complex(data(1:totalElem), data(totalElem+1:end));
end

if nDims > 1
    v = reshape(v, nElems);
end
end

% Sparse data types
function [v, pos] = deserialise_sparse(m, pos)
[type, ~, pos] = get_tag_data(m, pos);

switch type.name
    case 'sparse_logical'
        deserialiser = 'uint8';
    otherwise
        deserialiser = type.name(8:end);
end

[dims, pos] = read_bytes(m, pos, 'uint32', 2);
dims = double(dims);
[nElem, pos] = read_bytes(m, pos, 'uint32', 1);

[i, pos] = read_bytes(m, pos, 'uint64', nElem);
[j, pos] = read_bytes(m, pos, 'uint64', nElem);
% +1 is to align with C API which indexes from 0, not 1
i = double(i + 1);
j = double(j + 1);
[data, pos] = read_bytes(m, pos, deserialiser, nElem);

switch type.name
    case 'sparse_logical'
        data = logical(data);
    case 'sparse_complex_double'
        data = complex(data(1:nElem), data(nElem+1:end));
    otherwise
end

v = sparse(i,j,data,dims(1),dims(2));
end

function [v, pos] = deserialise_cell(m, pos)
[~, nDims, pos] = get_tag_data(m, pos);

if nDims == 0
    [v, pos] = deserialise_value(m, pos);
    v = {v};
else
    [nElems, pos] = read_bytes(m, pos, 'uint32', nDims);
    totalElem = prod(nElems);
    if totalElem == 0
        v = {};
    else
        v = cell(1,totalElem);
        for i=1:totalElem
            [v{i}, pos] = deserialise_value(m, pos);
        end
    end
end

if nDims > 1
    v = reshape(v, [nElems 1 1]);
end

end

function [v, pos] = deserialise_struct(m, pos)
[~, nDims, pos] = get_tag_data(m, pos);
if nDims == 0
    v = struct();
elseif nDims == 1
    [nElems, pos] = read_bytes(m, pos, 'uint32', nDims);
    if nElems == 0
        v = struct([]);
        return
    else
        v = reshape(struct(), [1 nElems]);
    end
else
    [nElems, pos] = read_bytes(m, pos, 'uint32', nDims);
    v = reshape(struct(), [nElems 1 1]);
end

% Number of field names.
[nFields, pos] = read_bytes(m, pos, 'uint32', 1);
nFields = double(nFields);
if nFields == 0
    return;
end

% Field name lengths
[fnLengths, pos] = read_bytes(m, pos, 'uint32', nFields);
fnLengths = double(fnLengths);
% Field name char data
[fnChars, pos] = read_bytes(m, pos, 'uint8', sum(fnLengths));
fnChars = char(fnChars);
% Field names.
fieldNames = cell(length(fnLengths),1);
splits = [0, cumsum(fnLengths)];
for k=1:length(splits)-1
    fieldNames{k} = fnChars(splits(k)+1:splits(k+1));
end
% using struct2cell
[contents,pos] = deserialise_value(m,pos);
v = cell2struct(contents,fieldNames,1);
end

function [v, pos] = deserialise_function_handle(m, pos)
[~, tag, pos] = get_tag_data(m, pos);
switch tag
    case 1 % Simple
        [name, pos] = deserialise_simple_data(m, pos);
        v = str2func(name);
    case 2 % Anonymous
        [code, pos] = deserialise_simple_data(m, pos);
        [workspace, pos] = deserialise_struct(m, pos);
        v = restore_function(code, workspace);
    case 3 % Scoped/Nested
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
                error('MATLAB:deserialise_function_handle:hlp_deserialise', 'Cannot deserialise a function handle to a nested function.')
            end
        end
end
end

function [v, pos] = deserialise_object(m, pos)
[~, nDims, pos] = get_tag_data(m, pos);

if nDims == 0
    [class_name, pos] = deserialise_simple_data(m, pos);
    [ser_tag, pos] = read_bytes(m, pos, 'uint8', 1);
    switch ser_tag
        case 0 % Object serialises itself
            instance = feval(class_name);
            [v, nbytes] = instance.deserialize(m,pos);
            %pos = pos+nbytes+8;
            pos = pos+nbytes;
        case 1 % Serialise as saveobj (must have loadobj)
            [conts, pos] = deserialise_value(m, pos);
            v = eval([class_name '.loadobj(conts)']);
        case 2 % Serialise as struct
            [conts, pos] = deserialise_value(m, pos);
            try % Direct assign
                v = eval([class_name '(conts)']);
            catch % Loop assign
                v = feval(class_name);
                for fn=fieldnames(conts)'
                    v.(fn{1}) = conts.(fn{1});
                end
            end
    end
else
    [nElems, pos] = read_bytes(m, pos, 'uint32', nDims);
    totalElem = prod(nElems);
    [class_name, pos] = deserialise_simple_data(m, pos);
    if totalElem == 0
        v = feval(class_name);
    else
        [ser_tag, pos] = read_bytes(m, pos, 'uint8', 1);
        switch ser_tag
            case 0 % Object serialises itself
                
                v(1:totalElem) = feval(class_name);
                for i=1:totalElem
                    [v(i),nbytes] = v(i).deserialize(m, pos);
                    pos = pos+nbytes+8;
                end
            case 1 % Serialise as saveobj (must have loadobj)
                
                [conts, pos] = deserialise_value(m, pos);
                % Preallocate
                v(1:totalElem) = feval(class_name);
                for i=1:totalElem
                    v(i) = eval([class_name '.loadobj(conts(' num2str(i) '))']);
                end
            case 2 % Serialise as struct
                [conts, pos] = deserialise_value(m, pos);
                % Preallocate
                v(1:totalElem) = feval(class_name);
                for i=1:totalElem
                    v(i) = eval([class_name '(conts(' num2str(i) '))']);
                end
        end
    end
    
end

if nDims > 1
    v = reshape(v, [nElems 1 1]);
end
end

function [type, nDims, pos] = get_tag_data(m, pos)
[type, pos] = read_bytes(m, pos, 'uint8', 1);
% Take top 3 bits
nDims = bitshift(bitand(32+64+128, type), -5);
% Take bottom 5 bits
type = hlp_serial_types.type_details(bitand(31, type) + 1);

end