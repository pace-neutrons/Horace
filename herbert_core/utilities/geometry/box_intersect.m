function inter_points = box_intersect(box_minmax,cross_plain)
% Calculate intersection points between the box in ND (N=2,3,4)
% and line/plain/hyperplane of dimensions (N-1)D
%
% Inputs:
% box_minmax -- NDx2 array of min and max points of the box, to intersect with.
%
% cross_plain -- NDxND array of points defining plain in the appropriate
%                dimensions. The coordinates defined along the first
%                dimension and the second dimention correspont to number of
%                points, the plain is passing through (has to be ND). If
%                there are ND-1 points, the missing point assumed to be
%                equal to 0.
% Outputs:
% inter_points - NDxNp array of points, defining intersection between the
%                edges of the box and the line/plain/hyperplain defined as
%                the second argument. NP is the number of intesection
%                points.
%                If no intersections between box and plain occur, 
%                the inter_points array is empty.
% Examples:
% 
% Calculate intersection points between line passing trhough points 0.5,0.5
% and 0.5,1 and the box [0,0;1,1]':
%>>cp = box_intersect([0,0;1,1]',[0.5,0.5;0.5,1]');
%>>disp(cp)
%>>cp = 
%>>   0.5000    0.5000
%>>        0    1.0000
%
% Calculate intersection points between plain passing through the points 
% (1/2,0,0), (1/2,0,1) and (1,1/2,0) and unit 3D box in the centre of
% coordinages:
%
%>>cp = box_intersect([0,0,0;1,1,1]',[1/2,0,0;1/2,0,1;1,1/2,0]');
%>>disp(cp)
%    0.5000    1.0000    0.5000    1.0000
%         0    0.5000         0    0.5000
%         0         0    1.0000    1.0000
%
% NOTE:
% Can be generalized to N-Dimensions and simplified, if the generic 
% normal in N-D isvdefined and expressed through N-dimensional Levi-Civita 
% symbol.

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
%
function inter_points = intersect4D(box_minmax,cross_plain)
npoints = size(cross_plain,2);
if npoints == 3 %
    cross_plain = [cross_plain,[0;0;0;0]];
end
plain_norm = normal4D(cross_plain);
if plain_norm'*plain_norm < 1.e-12
    error('BOX_INTERSECT:invalid_argument',...
        'vectors, defining the intersection plain are parallel')
end
plain_norm = plain_norm/norm(plain_norm);
%
[~,edges_ind] = get_geometry(4);
buf = cell(32,1);
nint = 0;
for i=1:size(edges_ind,2)
    edge_ind = edges_ind(:,i);
    edge =edge4D(box_minmax,edge_ind);
    int_point = intersection(edge,plain_norm,cross_plain(:,4));
    if ~isempty(int_point)
        nint = nint+1;
        buf{nint} = int_point;
    end
end
if nint>0
    inter_points = [buf{:}];
    max1 = max(inter_points(1,:))+1;
    max2 = max(inter_points(2,:))+1;
    max3 = max(inter_points(3,:))+1;    
    p_id = inter_points(1,:)+max1*(inter_points(2,:)+...
        max2*(inter_points(3,:)+max3*inter_points(4,:)));
    [~,uid] = unique(p_id);
    inter_points = inter_points(:,uid);
else
    inter_points = [];
end

function inter_points = intersect3D(box_minmax,cross_plain)
npoints = size(cross_plain,2);
if npoints == 2 %
    cross_plain = [cross_plain,[0;0;0]];
end
plain_norm = cross(cross_plain(:,1)-cross_plain(:,3),cross_plain(:,2)-cross_plain(:,3));
if plain_norm'*plain_norm < 1.e-12
    error('BOX_INTERSECT:invalid_argument',...
        'vectors, defining the intersection plain are parallel')
end
plain_norm = plain_norm/norm(plain_norm);
%
[~,edges_ind] = get_geometry(3);
buf = cell(12,1);
nint = 0;
for i=1:size(edges_ind,2)
    edge_ind = edges_ind(:,i);
    edge =edge3D(box_minmax,edge_ind);
    int_point = intersection(edge,plain_norm,cross_plain(:,3));
    if ~isempty(int_point)
        nint = nint+1;
        buf{nint} = int_point;
    end
end
if nint>0
    inter_points = [buf{:}];
    max1 = max(inter_points(1,:))+1;
    max2 = max(inter_points(2,:))+1;
    p_id = inter_points(1,:)+max1*(inter_points(2,:)+max2*inter_points(3,:));
    [~,uid] = unique(p_id);
    inter_points = inter_points(:,uid);
else
    inter_points = [];
end

function inter_points = intersect2D(box_minmax,cross_plain)
npoints = size(cross_plain,2);
if npoints == 1 %
    cross_plain = [cross_plain,[0;0]];
end
[~,edges_ind] = get_geometry(2);
buf = cell(4,1);
nint = 0;
p0 = cross_plain(:,2);
dr = cross_plain(:,1)-p0;
normal = [dr(2);-dr(1)];
normal = normal/norm(normal);
for i=1:size(edges_ind,2)
    edge_ind = edges_ind(:,i);
    edge =edge2D(box_minmax,edge_ind);
    int_point = intersection(edge,normal,p0);
    if ~isempty(int_point)
        nint = nint+1;
        buf{nint} = int_point;
    end
end
if nint>0
    inter_points = [buf{:}];
    max1= max(inter_points(1,:))+1;
    p_id = inter_points(1,:)+max1*inter_points(2,:);
    [~,uid] = unique(p_id);
    inter_points = inter_points(:,uid);
else
    inter_points = [];
end


function int_point = intersection(edg,normal,p0)
r0 = edg(:,1);
dr = edg(:,2) - r0;
edge_length = norm(dr);
slope = normal'*dr;
if abs(slope)  <1.e-12  % parallel or in plain
    % even if the edge lies in the plain,
    % we can reject this intersection, as other edges will provide
    % appropriate intersections with nodes
    int_point = [];
    return;
end
t = -normal'*(r0-p0)/slope;
rr = dr*t;
% project interpolation point on edge and check if intersection lies
% between edges.
e_edge = dr/sqrt(dr'*dr); % unit vector along edge
proj_edge = rr'*e_edge;   % projection of interpolation point to edge

if proj_edge<0 || proj_edge>edge_length %on plain but outside of the edge
    int_point  = [];
    return
end
int_point = r0+rr;