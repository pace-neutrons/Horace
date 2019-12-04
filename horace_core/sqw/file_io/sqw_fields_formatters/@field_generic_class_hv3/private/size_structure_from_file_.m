function  [sz,err] = size_structure_from_file_(obj,fid,n_fields,shape,pos,sz)
% Calculate the size of an arbitrary structure stored in file according to
% sqw v3 format
%
%
err = false;
if n_fields>0
    for i=1:prod(shape)
        for j=1:n_fields
            [szi,obj,err] = obj.size_from_file(fid,pos);
            if err; return; end
            
            sz = sz + szi;
            pos = pos + szi;
        end
    end
end
