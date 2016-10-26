function [var,sz] = restore_cellarray_(obj,bytes,pos,shape,sz)
% recursively restore cellarray

nel = prod(shape);
var=cell(shape);
for i=1:nel
    [var{i},szi]=obj.field_from_bytes(bytes,pos);
    pos = pos +szi;
    sz  = sz+szi;
end




