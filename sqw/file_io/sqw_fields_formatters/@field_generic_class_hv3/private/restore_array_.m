function [var,sz] = restore_array_(obj,bytes,pos,shape,sz)
% recursively restore cellarray

nel = prod(shape);
stor =cell(shape');
for i=1:nel
    [stor{i},szi]=obj.field_from_bytes(bytes,pos);
    pos = pos +szi;
    sz  = sz+szi;
end
var = repmat(stor{1},1,nel);
for i=1:nel
    var(i) = stor{i};
end
if size(shape,1) > size(shape,2)
    shape = shape';
end
var = reshape(var,shape);

