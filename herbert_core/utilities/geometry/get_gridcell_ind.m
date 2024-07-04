function [nodes_ind,n_dims] = get_gridcell_ind(grid_size)
% Returns an indices of cells for 1,2,3 or 4 dimensional grid, assuming
% that the cell nodes are obtained using ndgrid function and placed into 
% [ND,N-nodes] array of grid nodes coordinates.
%
% Inputs:
% grid_size --   ND elements array, where ND may be 1,2,3 or 4, which 
%                describes the size of the ND grid.
%
% Outputs:
% nodes_ind  -- [ND+1,prod(grid_size-1)] elements array containing the
%               linear indices of the nodes, which define every grid cell. 
%
%               e.g. for 1D grid of N-points, nodes_ind would have a form:
%               [1,2....N-1;...
%                2,3....N];             
% 

n_dims = numel(grid_size);
if n_dims == 2 && any(grid_size==1)
    n_dims = 1;
    ignore = grid_size==1;
    grid_size = grid_size(~ignore);
    if isempty(grid_size)
        error('HERBERT:get_grid_ind:invalid_argument',...
            'cell can not contain single element')
    end
end

if n_dims > 1 && any(grid_size<2)
    error('HERBERT:get_grid_ind:invalid_argument',...
        'grid must have at least 2 elements in each dimensions. Requested grid size is %s',...
        disp2str(grid_size));
end



switch(n_dims)
    case(1)
        nodes_ind = build1D(grid_size);
    case(2)
        nodes_ind = build2D(grid_size);
    case(3)
        nodes_ind = build3D(grid_size);
    case(4)
        nodes_ind = build4D(grid_size);
    otherwise
        error('HERBERT:get_grid_ind:invalid_argument',...
            'Function recognises only 2 to 4 dimensions, Requested: %d',...
            n_dims);
end
end

function nodes=build1D(grid_size)

i1 = 1:grid_size-1;
nodes = {i1;i1+1};

end

function nodes=build2D(grid_size)

ax = cell(2,1);
ax{1} = ax_points(grid_size(1));
ax{2} = ax_points(grid_size(2));

[lindX,lindY] = ndgrid(ax{:});
lind00 = sub2ind(grid_size,lindX(:),lindY(:));

[lindX,lindY] = ndgrid(ax{1}+1,ax{2});
lind10 = sub2ind(grid_size,lindX(:),lindY(:));

[lindX,lindY] = ndgrid(ax{1},ax{2}+1);
lind01 = sub2ind(grid_size,lindX(:),lindY(:));

nodes = {lind00(:),lind10(:),lind01(:)};

end

function nodes=build3D(grid_size)
ax = cell(3,1);

ax{1} = ax_points(grid_size(1));
ax{2} = ax_points(grid_size(2));
ax{3} = ax_points(grid_size(3));

addi = zeros(3,4);
addi(:,2:4)= eye(3);

nodes = cell(4,1);
for i=1:4
    [lindX,lindY,lindZ] = ndgrid(ax{1}+addi(1,i),ax{2}+addi(2,i),ax{3}+addi(3,i));
    nodes{i} = sub2ind(grid_size,lindX(:),lindY(:),lindZ(:));
end

end

function nodes=build4D(grid_size)
ax = cell(5,1);

ax{1} = ax_points(grid_size(1));
ax{2} = ax_points(grid_size(2));
ax{3} = ax_points(grid_size(3));
ax{4} = ax_points(grid_size(4));

addi = zeros(4,5);
addi(:,2:5)= eye(4);


nodes = cell(5,1);
for i=1:5
    [lindX,lindY,lindZ,lindE] = ndgrid(ax{1}+addi(1,i),ax{2}+addi(2,i),ax{3}+addi(3,i),ax{4}+addi(4,i));
    nodes{i} = sub2ind(grid_size,lindX(:),lindY(:),lindZ(:),lindE(:));
end
end

function ap = ax_points(sz)
ap = 1:sz-1;
end

