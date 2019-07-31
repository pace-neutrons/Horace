function xyz = get_xyz_data(obj,nax)
% get vector of bin boundaries for histogram data or bin centers
% for distribution in specific direction

nob = numel(obj);
if  nob > 1
    sz = size(obj);
    obj = reshape(obj,nob,1);
    xyz = cell(nob,1);    
    for i=1:nob
        if obj(i).valid_
            xyz{i} = obj(i).xyz_{nax};            
        else
            xyz{i} = obj(i).error_mess_;                        
        end
    end
    xyz = reshape(xyz,sz);    
else
    if obj.valid_
        xyz = obj.xyz_{nax};
    else
        xyz = obj.error_mess_;
    end
end


