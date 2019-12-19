function  sz = size_structure_(obj,bytes,n_fields,shape,pos,sz)
% Calculate the size of an arbitrary structure.
%

if n_fields>0
    for i=1:prod(shape)
        for j=1:n_fields
            szi=obj.size_from_bytes(bytes,pos);
            sz = sz + szi;
            pos = pos + szi;
        end
    end
end

