function  sz = proces_cellarray_size_(obj,bytes,pos,shape,sz)
%
nel = prod(shape);
for i=1:nel
    szi =obj.size_from_bytes(bytes,pos);    
    pos = pos +szi;
    sz  = sz+szi;
end

