function v = hlp_deserialise(m)
    global type_details;
    if isempty(type_details)
        type_details = struct('name',...
                              {'logical', 'char', 'string', 'double', 'single', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64', 'complex_double', 'complex_single', 'complex_int8', 'complex_uint8', 'complex_int16', 'complex_uint16', 'complex_int32', 'complex_uint32', 'complex_int64', 'complex_uint64', 'cell', 'struct', 'function_handle', 'value_object', 'handle_object_ref', 'enum', 'sparse_logical', 'sparse_double', 'sparse_complex_double'},...
                              'size',...
                              {1, 1, 1, 8, 4, 1, 1, 2, 2, 4, 4, 8, 8, 16, 8, 2, 2, 4, 4, 8, 8, 16, 16, 0, 0, 0, 0, 0, 0, 1, 8, 16},...
                              'tag',...
                              {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31});

    end

    v = deserialise_value(m,uint32(1));

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
        error('Unknown class');
    end
end

function [v,pos] = deserialise_simple_data(m, pos)
    [type, nDims] = get_tag_data(m, pos);

    switch type.name
      case {'logical', 'char', 'string'}
        deserialiser = 'uint8';
      otherwise
        deserialiser = type.name;
    end

    if nDims == 0
        v = typecast(m(pos+1:pos+type.size), deserialiser);
        pos = pos + type.size + 1;
    else
        nElems = typecast(m(pos+1:pos+4*nDims), 'uint32').';
        pos = pos + 4*nDims;
        totalElem = prod(nElems);
        if totalElem == 0
            v = [];
            pos = pos + 1;
        else
            v = typecast(m(pos+1:pos+type.size*totalElem), deserialiser).';
            pos = pos + type.size*totalElem + 1;
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
    [type, nDims] = get_tag_data(m, pos);

    deserialiser = type.name(9:end); % Strip off complex_

    if nDims == 0
        data = typecast(m(pos+1:pos+type.size), deserialiser).';
        pos = pos + type.size + 1;
        v = complex(data(1), data(2));
    else
        nElems = typecast(m(pos+1:pos+4*nDims), 'uint32').';
        totalElem = prod(nElems);
        pos = pos + 4*nDims;
        data = typecast(m(pos+1:pos+type.size*totalElem), deserialiser).';
        pos = pos + type.size*totalElem + 1;
        v = complex(data(1:totalElem), data(totalElem+1:end));
    end

    if nDims > 1
        v = reshape(v, nElems);
    end
end

% Sparse data types
function [v, pos] = deserialise_sparse(m, pos)
    [type, ~] = get_tag_data(m, pos);

    switch type.name
      case 'sparse_logical'
        deserialiser = 'uint8';
      case 'sparse_complex_double'
        deserialiser = 'double';
      otherwise
        deserialiser = type.name(8:end);
    end

    dims = typecast(m(pos+1:pos+4*2), 'uint32');
    pos = pos + 4*2;
    nElem = typecast(m(pos+1:pos+4), 'uint32');
    pos = pos + 4;
    i = typecast(m(pos+1:pos+8*nElem), 'uint64') + 1;
    pos = pos + 8 * nElem;
    j = typecast(m(pos+1:pos+8*nElem), 'uint64') + 1;
    pos = pos + 8 * nElem;
    data = typecast(m(pos+1:pos+type.size*nElem), deserialiser);
    pos = pos + type.size*nElem;

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
    [~, nDims] = get_tag_data(m, pos);

    if nDims == 0
        [v, pos] = deserialise_value(m, pos+1);
        v = {v};
    else
        nElems = typecast(m(pos+1:pos+4*nDims), 'uint32').';
        totalElem = prod(nElems);
        if totalElem == 0
            v = {};
        else
            pos = pos + 4*nDims + 1;
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
    [~, nDims] = get_tag_data(m, pos);
    if nDims == 0
        v = struct();
        pos = pos + 1;
    elseif nDims == 1
        nElems = typecast(m(pos+1:pos+4*nDims), 'uint32').';
        pos = pos + 4*nDims+1;

        if nElems == 0
            v = struct([]);
            return
        else
            v = reshape(struct(), [1 nElems]);
        end
    else
        nElems = typecast(m(pos+1:pos+4*nDims), 'uint32').';
        pos = pos + 4*nDims+1;
        v = reshape(struct(), [nElems 1 1]);
    end

    % Number of field names.
    %    pos, m(pos)
    nfields = double(typecast(m(pos:pos+3),'uint32'));
    pos = pos + 4;
    if nfields == 0
        return;
    end
    % Field name lengths
    fnLengths = double(typecast(m(pos:pos+nfields*4-1),'uint32'));
    pos = pos + nfields*4;
    % Field name char data
    fnChars = char(m(pos:pos+sum(fnLengths)-1)).';
    pos = pos + length(fnChars);
    % Field names.
    fieldNames = cell(length(fnLengths),1);
    splits = [0; cumsum(double(fnLengths))];
    for k=1:length(splits)-1
        fieldNames{k} = fnChars(splits(k)+1:splits(k+1));
    end
    % using struct2cell
    [contents,pos] = deserialise_value(m,pos);
    v = cell2struct(contents,fieldNames,1);
end

function [v, pos] = deserialise_function_handle(m, pos)
    [~, tag] = get_tag_data(m, pos);

    switch tag
      case 1 % Simple
        [name, pos] = deserialise_simple_data(m, pos+1);
        v = str2func(name);
      case 2 % Anonymous
        [code, pos] = deserialise_simple_data(m, pos+1);
        [workspace, pos] = deserialise_struct(m, pos);
        v = restore_function(code, workspace);
      case 3 % Scoped/Nested
        [parentage, pos] = deserialise_cell(m, pos+1);
        % recursively look up from parents, assuming that these support the arg system
        v = parentage{end};
        for k=length(parentage)-1:-1:1
            % Note: if you get an error here, you are trying to deserialize a function handle
            % to a nested function. This is not natively supported by MATLAB and can only be made
            % to work if your function's parent implements some mechanism to return such a handle.
            % The below call assumes that your function uses the BCILAB arg system to do this.
            v = arg_report('handle',v,parentage{k});
        end
    end
end

function [v, pos] = deserialise_object(m, pos)
    [~, nDims] = get_tag_data(m, pos);

    if nDims == 0
        [class_name, pos] = deserialise_simple_data(m, pos+1);
        ser_tag = m(pos);
        pos = pos + 1;
        switch ser_tag
          case 0 % Object serialises itself
            instance = feval(class_name);
            [v, nbytes] = instance.deserialize(m, pos);
            pos = pos+nbytes+8;
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
                    set(v,fn{1},conts.(fn{1}));
                end
            end
        end
    else
        nElems = typecast(m(pos+1:pos+4*nDims), 'uint32').';
        totalElem = prod(nElems);
        pos = pos + 4*nDims;
        [class_name, pos] = deserialise_simple_data(m, pos+1);
        if totalElem == 0
            v = feval(class_name);
        else
            ser_tag = m(pos);
            pos = pos + 1;
            switch ser_tag
              case 0 % Object serialises itself
              case 1 % Serialise as saveobj (must have loadobj)
                [conts, pos] = deserialise_value(m, pos);
                % v = arrayfun(@(i)(eval([class_name '.loadobj(conts(' num2str(i) '))'])), [1:totalElem])
                % Preallocate
                v(1:totalElem) = feval(class_name);
                for i=1:totalElem
                    v(i) = eval([class_name '.loadobj(conts(' num2str(i) '))']);
                end
              case 2 % Serialise as struct
                [conts, pos] = deserialise_value(m, pos);
                %                try % Direct assign
                %  v = arrayfun(@(i)(eval([class_name '(conts(' num2str(i) '))'])), [1:totalElem])
                % Preallocate
                v(1:totalElem) = feval(class_name);
                for i=1:totalElem
                    v(i) = eval([class_name '(conts(' num2str(i) '))']);
                end
                %                catch % Loop assign
                %                      % Preallocate
                %                    v(1:totalElem) = feval(class_name);
                %                    for fn=fieldnames(conts)'
                %                        %                        set(v,fn{1},num2cell(arrayfun(@(x)(x.(fn{1}), conts))));
                %                    end
                %                end
            end
        end

    end

    if nDims > 1
        v = reshape(v, [nElems 1 1]);
    end
end

function [type, nDims] = get_tag_data(m, pos)
    global type_details;
    type = m(pos);
    nDims = uint32(bitshift(bitand(32+64+128, type), -5));
    type = type_details(bitand(31, type) + 1);

end