function  [var,sz] = restore_structure_(obj,bytes,names,shape,pos,sz)
% Restore custom structure
%
nf = numel(names);

if nf>0
    var=repmat(cell2struct(cell(numel(names),1),names,1),shape');   % works for any sz (including zero dimensions)
    for i=1:prod(shape)
        for j=1:numel(names)
            [var(i).(names{j}),szi]=obj.field_from_bytes(bytes,pos);
            sz = sz + szi;
            pos = pos + szi;
        end
    end
else    % can have no field names
    if isequal(shape,[0,0])
        var=struct([]);
    elseif isequal(shape,[1,1])
        var=struct;
    else
        var=repmat(struct,shape');  % this is the way to get arbitrary size, not with struct([])
    end
end

