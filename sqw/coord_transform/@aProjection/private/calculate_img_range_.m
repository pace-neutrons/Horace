function img_range = calculate_img_range_(obj,qu_range)
% Process image range from pixels range and defined transformation


full_range = build_full_range_(qu_range);

full_range = obj.pix_to_img(full_range);
img_range(1,:)=min(full_range,[],2)';
img_range(2,:)=max(full_range,[],2)';


function full_range = build_full_range_(qu_range)
% Build full 3D or 4D range box given vectors of min-max coordinates
%
% ugly, something smarter should be possible
%

ndims = size(qu_range,2);
if ndims  == 3
    ind3D =  {[1,1,1],[1,2,1],[1,1,2],[1,2,2],[2,2,2],[2,1,2],[2,2,1],[2,1,1]};
    full_range = cellfun(@(ind)[qu_range(ind(1),1);qu_range(ind(2),2);qu_range(ind(3),3)],...
        ind3D,'UniformOutput',false);
    full_range  = [full_range{:}];
elseif ndims == 4
    ind4D =  {[1,1,1,1],[1,2,1,1],[1,1,2,1],[1,2,2,1],[2,2,2,1],[2,1,2,1],[2,2,1,1],[2,1,1,1],...
        [1,1,1,2],[1,2,1,2],[1,1,2,2],[1,2,2,2],[2,2,2,2],[2,1,2,2],[2,2,1,2],[2,1,1,2]};
    full_range = cellfun(@(ind)[qu_range(ind(1),1);qu_range(ind(2),2);qu_range(ind(3),3);qu_range(ind(4),4)],...
        ind4D,'UniformOutput',false);
    full_range  = [full_range{:}];
else
    error('BUILD_FULL_RANGE:invalid_arguments','only 3D and 4D grids are supported')
end
