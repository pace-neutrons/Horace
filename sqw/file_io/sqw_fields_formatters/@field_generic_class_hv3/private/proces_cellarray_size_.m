function  sz = proces_cellarray_size_(obj,bytes,pos,shape,sz)
%
nel = prod(shape);
var=cell(shape);
for i=1:nel
    [var{i},szi]=obj.size_from_bytes(bytes,pos);
    pos = pos +szi;
    sz  = sz+szi;
end

