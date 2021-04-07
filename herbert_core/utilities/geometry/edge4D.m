function edge = edge4D(bound_box,edge_ind)
% return 4D vector with coorinates of a box edge in 4D
%
% Input:
% bound_box --
%      either: 4x2 vector, containing min/max coordinates of a box,
%              aligned with coordinate axis. The nodes coordinates are
%              arranged along columns (first dimension)
%      or    : 4x16 vector of a box nodes, containing all box nodes
%              coordinates. The nodes order is defined by expand_box routine
% edge_ind  -- 4x1 array of edge nodes indexes, calculated by get_geometry
%              routine
%
% Returns:
% edge      -- 4x2 vector,combining two nodes of the edge, defined by
%              input indexes

if size(bound_box,2) ==2 % build edges from bounding box aligned with
    % coordinate axis
    
    [all_i,all_j,all_k,all_t] = ind2sub([2,2,2,2],edge_ind);
    n1 = [bound_box(1,all_i(1));bound_box(2,all_j(1));bound_box(3,all_k(1));bound_box(4,all_t(1))];
    n2 = [bound_box(1,all_i(2));bound_box(2,all_j(2));bound_box(3,all_k(2));bound_box(4,all_t(2))];
    edge  = [n1,n2];
    
elseif size(bound_box,2) ==16 % build edges from the bounding box, defined
    % by all its nodes
    edge  = [bound_box(:,edge_ind(1)),bound_box(:,edge_ind(2))];
else
    error('HERBERT:geometry:invalid_argument',...
        ['The dimensions of the bounding box in edge4D should be 4x2 or 4x16. ',...
        ' Provided box with the dimensions: %s'],...
        evalc('disp(size(bound_box))'))
end

