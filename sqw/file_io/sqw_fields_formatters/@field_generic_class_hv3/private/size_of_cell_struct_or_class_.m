function sz = size_of_cell_struct_or_class_(obj,sz,type,shape,val)
% Calculate size of cellarray, structure or class
%
nel = numel(val);
if iscell(val)
    for i=1:nel
        sz =sz+ obj.size_of_field(val{i});
    end
else % structure or custom class
    names=fieldnames(val);
    nn = numel(names);
    sz  = obj.head_size(type,shape)+8;
    if ~isempty(names)
        fsz = cellfun(@(nm)(8+numel(nm)),names,...
            'UniformOutput',true);
        sz = sz+sum(fsz);
        for i=1:nn
            sz = sz+obj.size_of_field(val.(names{i}));
        end
    else    % no field names
    end
end

