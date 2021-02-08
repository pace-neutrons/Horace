function inter_points = box_intersect(box_minmax,cross_plain)
% Calculate intersection points between the box in N-D (2,3,4) 
% and plain/line/hyperplane  (N-1)D
%
% Inputs:
% box_minmax -- min and max points of the box, to intersect with
% cross_plain -- NDxND array of points defining plain in the appropriate
%                dimensions. The coordinates defined along the first
%                dimension and the second dimention correspont to number of
%                points, the plain is passing through (has to be ND). If
%                there are ND-1 points, the missing point assumed to be
%                equal to 0.
% Outputs:
% inter_points - NDxNp where NP -- the number of intesection points
%                array of points, defining intersection between the
%                edges of the box and the line/plain/hyperplain defined as
%                the second argument
%                If no intersection points are present, the array is empty

ndim = size(cross_plain,1);
switch(ndim)
    case(2)
        inter_points = intersect2D(box_minmax,cross_plain);
    case(3)
        inter_points = intersect3D(box_minmax,cross_plain);        
    case(4)
        inter_points = intersect4D(box_minmax,cross_plain);                
        
    otherwise
        error('BOX_INTERSECT:invalid_argument',...
            'Routine accepts the data from 2 to 4 dimensions. Got %d',...
            ndim);
end
function inter_points = intersect4D(box_minmax,cross_plain)
        error('BOX_INTERSECT:not_implemented',...s
            '4D interestions are not yet implemented');

function inter_points = intersect2D(box_minmax,cross_plain)
npoints = size(cross_plain,2);
if npoints == 1 %
    cross_plain = [cross_plain,[0;0]];
end
[~,edges_ind] = get_geometry(2);
buf = cell(4,1);
nint = 0;
for i=1:size(edges_ind,2)    
    edge_ind = edges_ind(:,i);
    edge =edge2D(box_minmax,edge_ind);
    int_point = inters2D(edge,cross_plain);
    if ~isempty(int_point)
        nint = nint+1;
        buf{nint} = int_point;
    end
end
if nint>0
    inter_points = [buf{:}];
else
    inter_points = [];
end
    

function int_point = inters2D(edge,plain)
r1 = plain(:,1)-plain(:,2);
r2 = edge(:,2) - edge(:,1);
det = [r1(2),-r1(1);r2(2),-r2(1)];
cn = cond(det);
if cn >1.e+8  % parallel
    int_point = [];
    return;
end
rhs = [...
    det(1)*plain(1,2)-det(3)*plain(2,2);...
    det(2)*edge(1,1)-det(4)*edge(2,1)];
int_point = det\rhs;
% project interpolation point on edge and check if intersection between
% edges.
rr = int_point-edge(:,1);
e_edge = r2/sqrt(r2'*r2);
proj_edge = rr'*e_edge;

if proj_edge<0 || proj_edge>1 %outside of
    int_point  = [];
end