function bytes = convert_cell_struct_or_class_(obj,head,val)
% Convert into sequence of bytes a cellarray or structure or custom class
%
nel = numel(val);

if iscell(val)
    tBytes =cell(nel+1,1);
    tBytes{1} = head;
    for i=1:nel
        tBytes{i+1}=obj.bytes_from_field(val{i});
    end
elseif isa(val,'function_handle')
    f_str = func2str(val);
    bytes = [head,typecast(numel(f_str),'uint8'),uint8(f_str)];
    return;
else % structure or custom class
    try
        val1 = structIndep(val(1));
    catch ME
        if ~strcmpi(ME.identifier,'MATLAB:UndefinedFunction')
            throw(ME);
        end
        val1=val(1);
    end
    names=fieldnames(val1);
    nn = numel(names);
    tBytes = cell(nn*nel+1,1);
    tBytes{1} = [head,typecast(nn,'uint8')];
    base = 1;
    if ~isempty(names)
        tbn = cellfun(@(nm)[typecast(numel(nm),'uint8'),uint8(nm)],names,...
            'UniformOutput',false);
        tBytes{1} = [tBytes{1},[tbn{:}]];
        [tBytes,base] = process_single(obj,val1,names,tBytes,base,nn);
    end
    for i=2:nel
        try
            val1 = structIndep(val(i));
        catch ME
            if ~strcmpi(ME.identifier,'MATLAB:UndefinedFunction')
                throw(ME);
            end
        end
        [tBytes,base] = process_single(obj,val1,names,tBytes,base,nn);
    end
end
bytes = [tBytes{:}];

function [tBytes,base] = process_single(obj,class_struc,names,tBytes,base,nn)

for i=1:nn
    tBytes{base+i} = obj.bytes_from_field(class_struc.(names{i}));
end
base = base+nn;
