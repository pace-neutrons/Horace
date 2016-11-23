function  [sz,err] = cellarray_size_from_file_(obj,fid,pos,shape,sz)
%
nel = prod(shape);
var=cell(shape);
for i=1:nel
    [szi,var{i},err]=obj.size_from_file(fid,pos);
    if err
        return;
    end
    pos = pos +szi;
    sz  = sz+szi;
end

