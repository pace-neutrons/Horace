function xyz = get_xyz_data(obj,nax)
% get vector of bin boundaries for histogram data or bin centers
% for distribution in specific direction

if numel(obj) > 1
    obj = reshape(obj,numel(obj),1);
    valid = obj(:).valid_;
    xyz = cell(numel(obj),1);
    xyz(valid) = obj(valid).xyz{nax};
    xyz(~valid) = obj(~valid).error_mess_;
else
    if obj.valid_
        xyz = obj.xyz_{nax};
    else
        xyz = obj.error_mess_;
    end
end


