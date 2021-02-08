function edge = edge3D(bound_box,edge_ind)
% Calculate edge coordinates from the bounding box, 
% defined by its min and max values and edge indexes
[all_i,all_j,all_k] = ind2sub([2,2,2],edge_ind);
n1 = [bound_box(1,all_i(1));bound_box(2,all_j(1));bound_box(3,all_k(1))];
n2 = [bound_box(1,all_i(2));bound_box(2,all_j(2));bound_box(3,all_k(2))];    
edge  = [n1,n2];
