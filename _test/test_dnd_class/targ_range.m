function range = targ_range(obj,targ_proj)
%TARG_RANGE calculate the full range of the image to be produded by target
% projection from the current image

source_proj = obj.proj;
%
% cross-assign appropriate projections to enable possible optimizations
source_proj.targ_proj = targ_proj;
targ_proj.targ_proj   = source_proj;


if isa(source_proj,class(targ_proj))
    cur_range = obj.img_range;
    full_range = expand_box(cur_range(1,:),cur_range(2,:));
else
    
end

full_targ_range = source_proj.from_this_to_targ_coord(full_range);

range = [min(full_targ_range,[],2);max(full_targ_range,[],2)];
