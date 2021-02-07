function [nodes_ind,edges_ind] = get_geometry(n_dims)

persistent nodes_ind2D;
persistent nodes_ind3D;
persistent nodes_ind4D;
persistent edges_ind2D;
persistent edges_ind3D;
persistent edges_ind4D;
if isempty(nodes_ind2D)
    %nodes_ind2D= {[1,1];[1,2];[2,2];[2,1]};
    %edges_ind2D= [1,2;2,3;3,4;4,1];
    [nodes_ind2D,edges_ind2D] = build2D();
    
    %     nodes_ind3D= {[1,1,1]; [1,1,2]; [1,2,2]; [1,2,1];...
    %         [2,1,1]; [2,1,2]; [2,2,2]; [2,2,1]};
    %     edges_ind3D= [1,2; 2,3; 3,4; 4,1; ...
    %         1,5; 5,6; 6,2; 6,7; ...
    %         7,3; 7,8; 8,4; 8,5];
    [nodes_ind3D,edges_ind3D] = build3D();
    [nodes_ind4D,edges_ind4D] = build4D();
    %     nodes_ind4D= {...
    %         [1,1,1,1]; [1,1,1,2]; [1,1,2,2]; [1,1,2,1];... %1
    %         [2,1,1,1]; [2,1,1,2]; [2,1,2,2]; [2,1,2,1];... %5
    %         [2,2,1,1]; [2,2,1,2]; [2,2,2,2]; [2,2,2,1];... %9
    %         [1,2,1,1]; [1,2,1,2]; [1,2,2,2]; [1,2,2,1]};   %13
    %     edges_ind4D = [1,2; 2,3; 3,4; 4,1; ...
    %         1,5];
end
switch(n_dims)
    case(2)
        nodes_ind = nodes_ind2D;
        edges_ind = edges_ind2D;
    case(3)
        nodes_ind = nodes_ind3D;
        edges_ind = edges_ind3D;
    case(4)
        nodes_ind = nodes_ind4D;
        edges_ind = edges_ind4D;
    otherwise
        error('GET_GEOMETRY:invalid_argument',...
            'Function recognises only 2 to 4 dimensions, Requested: %d',...
            n_dims);
end
function [nodes,eges_ind]=build2D()
ind = zeros(2,2);
i = 1:4;
ind(i) = i;
nodes = reshape(ind,4,1);
[ix,iy] = ind2sub(size(ind),nodes);
nodes = arrayfun(@(x,y)([x,y]),ix,iy,'UniformOutput',false);

nb_pairs = [1,0;0,1;-1,0;0,-1];

%
% n_nodes*n_edges_from_node/2
eges_ind = zeros(2,4);
ic = 1;
for ii=1:4
    [i0,j0] = ind2sub(size(ix),ii);
    for jj=1:size(nb_pairs,1)
        i1 = i0+nb_pairs(jj,1);
        if i1<1 || i1>2; continue; end
        j1 = j0+nb_pairs(jj,2);
        if j1<1 || j1>2; continue; end
        eges_ind(:,ic) = sort([ind(ii);ind(i1,j1)]);
        ic = ic+1;
    end
end
uni_num = eges_ind(1,:)+4*eges_ind(2,:);
[~,unii] = unique(uni_num);
eges_ind = eges_ind(:,unii);

function [nodes,eges_ind]=build3D()
ind = zeros(2,2,2);
ND = numel(ind);
i = 1:ND;
ind(i) = i;
nodes = reshape(ind,ND,1);
[ix,iy,iz] = ind2sub(size(ind),nodes);
nodes = arrayfun(@(x,y,z)([x,y,z]),ix,iy,iz,'UniformOutput',false);

nb_pairs = [1,0,0; 0, 1,0; 0,0, 1;
    -1,0,0; 0,-1,0; 0,0,-1];

%12=n_nodes*n_edges_from_node/2
eges_ind = zeros(2,12);
ic = 1;
for ii=1:ND
    [i0,j0,k0] = ind2sub(size(ix),ii);
    for jj=1:size(nb_pairs,1)
        i1 = i0+nb_pairs(jj,1);
        if i1<1 || i1>2; continue; end
        j1 = j0+nb_pairs(jj,2);
        if j1<1 || j1>2; continue; end
        k1 = k0+nb_pairs(jj,3);
        if k1<1 || k1>2; continue; end
        eges_ind(:,ic) = sort([ind(ii);ind(i1,j1,k1)]);
        ic = ic+1;
    end
end
uni_num = eges_ind(1,:)+ND*eges_ind(2,:);
[~,unii] = unique(uni_num);
eges_ind = eges_ind(:,unii);


function [nodes,eges_ind]=build4D()

ind = zeros(2,2,2,2);
ND = numel(ind);
i = 1:ND;
ind(i) = i;
nodes = reshape(ind,ND,1);
[ix,iy,iz,it] = ind2sub(size(ind),nodes);
nodes = arrayfun(@(x,y,z,t)([x,y,z,t]),ix,iy,iz,it,'UniformOutput',false);

nb_pairs = ...
    [1,0,0,0; 0, 1,0,0;  0,0, 1,0; 0,0,0, 1;...
    -1,0,0,0; 0,-1,0,0;  0,0,-1,0; 0,0,0,-1];

% 32 = n_nodes*n_edges_from_node/2
eges_ind = zeros(2,32);
ic = 1;
for ii=1:ND
    [i0,j0,k0,l0] = ind2sub(size(ix),ii);
    for jj=1:size(nb_pairs,1)
        i1 = i0+nb_pairs(jj,1);
        if i1<1 || i1>2; continue; end
        j1 = j0+nb_pairs(jj,2);
        if j1<1 || j1>2; continue; end
        k1 = k0+nb_pairs(jj,3);
        if k1<1 || k1>2; continue; end
        l1 = l0+nb_pairs(jj,4);
        if l1<1 || l1>2; continue; end
        
        eges_ind(:,ic) = sort([ind(ii);ind(i1,j1,k1,l1)]);
        ic = ic+1;
    end
end
uni_num = eges_ind(1,:)+ND*eges_ind(2,:);
[~,unii] = unique(uni_num);
eges_ind = eges_ind(:,unii);
