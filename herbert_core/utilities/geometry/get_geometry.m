function [nodes_ind,edges_ind] = get_geometry(n_dims)
% Returns a box structure in 2,3 or 4 dimensions, necessary to convert 
% compact (min_value,max_value) aligned box representation into the whole
% shape representation (coordinates of all nodes and arrays of coordinates 
% of all edges)
%
% Inputs:
% n_dims  -- number of dimensions (ND)
% Outputs:
% nodes_ind  -- the NDx2^ND cellarray of indexes, used to expand
%               a box defined by its min/max points in appropriate
%               dimensions space into the whole ND representation
%               e.g. in 2D its array of {[1,1],[1,2],[2,1],[2,2]}
%               used to produce a rectangle, and in 3D is the array like
%              {[1,1,1],[1,2,1],....[2,2,2]}, used in constructing a cuboid.
% edges_ind  -- NDxN_edges array of indexes, defining the indexes of the
%               edges of the appropriate shapes in ND, used to expand min/max
%               shape representation into set of edges. N_edges here is
%               the number of shape edges eaual to ND^2*ND/2.
%               e.g, in 2D is will be the array [1,2;2,3;3,4;1,4]' where
%               the numbers are the linear indexes of the nodes, defined
%               by ind2sub (or sub2ind) procedure.
persistent nodes_ind2D;
persistent nodes_ind3D;
persistent nodes_ind4D;
persistent edges_ind2D;
persistent edges_ind3D;
persistent edges_ind4D;
switch(n_dims)
    case(2)
        if isempty(nodes_ind2D)
            [nodes_ind2D,edges_ind2D] = build2D();
        end
        nodes_ind = nodes_ind2D;
        edges_ind = edges_ind2D;
    case(3)
        if isempty(nodes_ind3D)
            [nodes_ind3D,edges_ind3D] = build3D();
        end
        
        nodes_ind = nodes_ind3D;
        edges_ind = edges_ind3D;
    case(4)
        if isempty(nodes_ind4D)
            [nodes_ind4D,edges_ind4D] = build4D();
        end
        
        nodes_ind = nodes_ind4D;
        edges_ind = edges_ind4D;
    otherwise
        error('GET_GEOMETRY:invalid_argument',...
            'Function recognises only 2 to 4 dimensions, Requested: %d',...
            n_dims);
end
function [nodes,edges_ind]=build2D()
% build generic 2D geometry representation (nodes indexes and edges
% indexes). The detailed description of the results is given in
% get_geometry
ind = zeros(2,2);
%
% number nodes linearly according to their positions
i = 1:4;
ind(i) = i;
nodes = reshape(ind,4,1);
% and convert node numbers into index respresentation (cellarray of node
% indexes)
[ix,iy] = ind2sub(size(ind),nodes);
nodes = arrayfun(@(x,y)([x,y]),ix,iy,'UniformOutput',false);

nb_pairs = [1,0;0,1;-1,0;0,-1];
% 
% Allocate memory for all nodes candidates The number of nodes is 
% 4 = n_nodes*n_edges_from_node/2  but the memory is twice of that to
% accound for duplicates
edges_ind = zeros(2,8);
ic = 1;
for ii=1:4
    [i0,j0] = ind2sub(size(ind),ii);
    for jj=1:size(nb_pairs,1)
        i1 = i0+nb_pairs(jj,1);
        if i1<1 || i1>2; continue; end
        j1 = j0+nb_pairs(jj,2);
        if j1<1 || j1>2; continue; end
        edges_ind(:,ic) = sort([ii;ind(i1,j1)]);
        ic = ic+1;
    end
end
uni_num = edges_ind(1,:)+4*edges_ind(2,:);
[~,unii] = unique(uni_num);
edges_ind = edges_ind(:,unii);

function [nodes,edges_ind]=build3D()
% build generic 3D geometry representation (nodes indexes and edges
% indexes) The detailed description of the results is given in
% get_geometry
%
ind = zeros(2,2,2);
ND = numel(ind);
%
% number nodes linearly according to their positions
i = 1:ND;
ind(i) = i;
nodes = reshape(ind,ND,1);
% and convert node numbers into index respresentation (cellarray of node
% indexes)
[ix,iy,iz] = ind2sub(size(ind),nodes);
nodes = arrayfun(@(x,y,z)([x,y,z]),ix,iy,iz,'UniformOutput',false);

nb_pairs = [1,0,0; 0, 1,0; 0,0, 1;
    -1,0,0; 0,-1,0; 0,0,-1];

% Allocate memory for all nodes candidates The number of nodes is 
% 12=n_nodes*n_edges_from_node/2  but the memory is twice of that to
% accound for duplicates
edges_ind = zeros(2,12*2);
ic = 1;
for ii=1:ND
    [i0,j0,k0] = ind2sub(size(ind),ii);
    for jj=1:size(nb_pairs,1)
        i1 = i0+nb_pairs(jj,1);
        if i1<1 || i1>2; continue; end
        j1 = j0+nb_pairs(jj,2);
        if j1<1 || j1>2; continue; end
        k1 = k0+nb_pairs(jj,3);
        if k1<1 || k1>2; continue; end
        edges_ind(:,ic) = sort([ind(ii);ind(i1,j1,k1)]);
        ic = ic+1;
    end
end
uni_num = edges_ind(1,:)+ND*edges_ind(2,:);
[~,unii] = unique(uni_num);
edges_ind = edges_ind(:,unii);


function [nodes,edges_ind]=build4D()
% build generic 4D geometry representation (nodes indexes and edges
% indexes) The detailed description of the results is given in
% get_geometry.
%
ind = zeros(2,2,2,2);
ND = numel(ind); % 2^4
% number nodes linearly according to their positions
i = 1:ND;
ind(i) = i;
nodes = reshape(ind,ND,1);
%
% and convert node numbers into index respresentation (cellarray of node
% indexes)
[ix,iy,iz,it] = ind2sub(size(ind),nodes);
nodes = arrayfun(@(x,y,z,t)([x,y,z,t]),ix,iy,iz,it,'UniformOutput',false);

nb_pairs = ...
    [1,0,0,0; 0, 1,0,0;  0,0, 1,0; 0,0,0, 1;...
    -1,0,0,0; 0,-1,0,0;  0,0,-1,0; 0,0,0,-1];

% Allocate memory for all nodes candidates The number of nodes is 
% 32 = n_nodes*n_edges_from_node/2  but the memory is twice of that to
% accound for duplicates
edges_ind = zeros(2,32*2);
ic = 1;
for ii=1:ND
    [i0,j0,k0,l0] = ind2sub(size(ind),ii);
    for jj=1:size(nb_pairs,1)
        i1 = i0+nb_pairs(jj,1);
        if i1<1 || i1>2; continue; end
        j1 = j0+nb_pairs(jj,2);
        if j1<1 || j1>2; continue; end
        k1 = k0+nb_pairs(jj,3);
        if k1<1 || k1>2; continue; end
        l1 = l0+nb_pairs(jj,4);
        if l1<1 || l1>2; continue; end
        
        edges_ind(:,ic) = sort([ind(ii);ind(i1,j1,k1,l1)]);
        ic = ic+1;
    end
end
uni_num = edges_ind(1,:)+ND*edges_ind(2,:);
[~,unii] = unique(uni_num);
edges_ind = edges_ind(:,unii);
