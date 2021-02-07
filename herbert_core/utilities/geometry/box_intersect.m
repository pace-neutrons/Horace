function inter_points = box_intersect(box_minmax,cross_plain)
% Calculate intersection points between the box in N-D (2,3,4) 
% and plain/line/hyperplane  (N-1)D
%
% Inputs:
% 
% If no intersection exist, 
% box_minmax -- min and max points of the box, to intersect with
% cross_plain -- NDxND array of points defining plain in the appropriate
%                dimensions. The coordinates go as column

