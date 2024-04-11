function bound_dim_id = get_bound_dimensions_(obj,img_ranges,selected_dims)
% return dimensions id, connected with the source dimensions
% ID-s by target projection, or in other words, the ID-s of the
% dimensions which change when input dimensions change.
%
% E.g. if source coordinate system is linear system and target
% coordinate system is spherical coordinate system, the changes
% in dimension 1 (ex) bring changes to |Q| (dim 1) if spherical
% projeciton's vector u is directed along [1,0,0] and offset is
% [0,0,0,0] or contribute to |Q|-theta dimensions (dim ID-s 1,2)
% if offset is [0,1,0,0]
%
% To use this method target projection have to be set.



if numel(selected_dims) ~= 4 
    error('HORACE:aProjectionBase:invalid_argument', ...
        'Selected dimesions should be 4 element logical array containing true or false. Provided: %d', ...
        disp2str(selected_dims));
end
selected_dims = logical(selected_dims);
n_dim_to_test = sum(selected_dims);
inf_range = isinf(img_ranges);
min_max = img_ranges;
if any(inf_range(:))
    min_max(inf_range) = sign(img_ranges(inf_range));
end
base_point = 0.5*(min_max(1,:)+min_max(2,:))';

n_streak = 10;
test_coord = zeros(4,n_streak*n_dim_to_test);
ic = 0;
for i=1:4
    if ~selected_dims(i)
        continue;
    else
        ic = ic+1;
    end
    mult  = base_point;
    mult(i) = 1;
    coord_streak = linspace(min_max(1),min_max(2),n_streak);
    coord_streak  = coord_streak.*mult;

    j = 1+(ic-1)*n_streak;
    test_coord(:,j:j+n_streak-1) = coord_streak;
end
targ_coord = obj.from_this_to_targ_coord(test_coord);
bound_dim_id = false(4,n_dim_to_test);
for i=1:n_dim_to_test
    j = 1+(i-1)*n_streak;
    bound_dim_id(:,i) = any(abs(targ_coord(:,j:j+n_streak-1))>eps('single'),2);
end
