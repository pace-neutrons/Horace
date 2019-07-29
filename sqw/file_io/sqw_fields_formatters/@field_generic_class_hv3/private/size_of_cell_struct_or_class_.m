function sz = size_of_cell_struct_or_class_(obj,sz,type,shape,val)
% Calculate size of cellarray, structure or class
%
nel = numel(val);
if iscell(val)
    for i=1:nel
        sz =sz+ obj.size_of_field(val{i});
    end
else % structure or custom class
    try % obtain the structure, which contains all independent class field
        val1 = structIndep(val(1));
    catch ME
        if ~strcmpi(ME.identifier,'MATLAB:UndefinedFunction')
            throw(ME);
        end
    end
    names=fieldnames(val1);
    nn = numel(names);
    sz  = obj.head_size(type,shape)+8;
    if ~isempty(names)
        fsz = cellfun(@(nm)(8+numel(nm)),names,...
            'UniformOutput',true);
        sz = sz+sum(fsz);
        % recursively find the size of the structure fields
        sz = process_single(obj,val1,names,sz,nn);
    else    % no field names
    end
    for i=2:nel
        try
            val1 = structIndep(val(i));
        catch ME
            if ~strcmpi(ME.identifier,'MATLAB:UndefinedFunction')
                throw(ME);
            end
        end
        sz = process_single(obj,val1,names,sz,nn);
    end
end


function sz = process_single(obj,class_struc,names,sz,nn)

for i=1:nn
    sz = sz+ obj.size_of_field(class_struc.(names{i}));
end


