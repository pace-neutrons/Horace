function xyz = get_xyz_data(obj,nax)
% get vector of bin boundaries for histogram data or bin centers
% for distribution in specific direction

nob = numel(obj);
if  nob > 1
    sz = size(obj);
    obj = reshape(obj,nob,1);
    xyz = cell(nob,1);
    for i=1:nob
        xyz{i} = obj(i).xyz_{nax};
    end
    xyz = reshape(xyz,sz);
else
    xyz = obj.xyz_{nax};
end
