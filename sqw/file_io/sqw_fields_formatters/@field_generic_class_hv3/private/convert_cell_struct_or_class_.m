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
    names=fieldnames(val);
    nn = numel(names);
    tBytes = cell(nn*nel+1,1);
    tBytes{1} = [head,typecast(nn,'uint8')];
    if ~isempty(names)
        tbn = cellfun(@(nm)[typecast(numel(nm),'uint8'),uint8(nm)],names,...
            'UniformOutput',false);
        tBytes{1} = [tBytes{1},[tbn{:}]];
        for j=1:nel
            for i=1:nn
                tBytes{(j-1)*nn+i+1} = obj.bytes_from_field(val(j).(names{i}));
            end
        end
    else    % no field names
    end
end
bytes = [tBytes{:}];



