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
else % structure or custom class
    if nel>1
        tBytes =cell(nel+1,1);
        tBytes{1} = head;
        for i=1:nel
            tBytes{i+1}=obj.bytes_from_field(val(i));
        end
    else
        try
            val = structIndep(val);
        catch ME
            if ~strcmpi(ME.identifier,'MATLAB:UndefinedFunction')
                throw(ME);
            end
        end
        names=fieldnames(val);
        nn = numel(names);
        tBytes = cell(nn+1,1);
        tBytes{1} = [head,typecast(nn,'uint8')];
        if ~isempty(names)
            tbn = cellfun(@(nm)[typecast(numel(nm),'uint8'),uint8(nm)],names,...
                'UniformOutput',false);
            tBytes{1} = [tBytes{1},[tbn{:}]];
            
            for i=1:nn
                tBytes{i+1} = obj.bytes_from_field(val.(names{i}));
            end
            
        end
    end
end
bytes = [tBytes{:}];

