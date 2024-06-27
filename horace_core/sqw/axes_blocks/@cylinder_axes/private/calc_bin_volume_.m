function volume = calc_bin_volume_(obj,nodes_info,varargin)
%CALC_BIN_VOLUME_ calculate the volume of a lattice cell defined by the
%cellarray of lattice axes.
%
% The volume is either single value if all axes bins are the same or the
% 1D array of size of total number of bins in the lattice if some cell
% volumes differ.
%

[is_axes,grid_size]= AxesBlockBase.process_bin_volume_inputs(obj,nodes_info,varargin{:});


grid_edges = cellfun(@(ax)(ax(2:end)-ax(1:end-1)),nodes_info, ...
    'UniformOutput',false);

if is_axes
    dE_regular = true;
    if abs(min(grid_edges{4}) - max(grid_edges{4})) > eps('single') && ...
            abs(min(grid_edges{3}) - max(grid_edges{3})) > eps('single')
        dE_regular = false;
    end
    % dR = r_2^2-r_1^2 = (r_2-r_1)*(r_1+r_2);
    ax_r = nodes_info{1};
    nr = 1:numel(ax_r)-1;
    dr = grid_edges{1};
    dR = arrayfun(@(i)abs((ax_r(i)+ax_r(i+1))*dr(i)/2), ...
        nr);
    grid_edges{1} = dR;
    %
    %grid_sizes{2} = dQ_|| -- linear axes;

    % dPhi
    if obj.angular_unit_is_rad(1)
        dPhi = grid_edges{3};
    else
        dPhi = deg2rad(grid_edges{3});
        grid_edges{3} = dPhi;
    end

    if numel(dR)==1 && numel(dPhi) == 1 && dE_regular
        volume = dR(1)*grid_edges{2}(1)*dPhi(1)*grid_edges{4}(1);
    else
        volume = grid_edges{1}(:)';
        for i=2:4
            volume = repmat(volume(:)',1,numel(grid_edges{i})).*...
                repelem(grid_edges{i}(:)',numel(volume));
        end
    end
else
    if size(nodes_info,2) == 4
        errror('HORACE:cylinder_axes:not_implemented', ...
            'Volume of 4-Dimensional grid is not yet implemented')
    end
    
    cell_idx = get_gridcell_ind(grid_size(1:3));

    r1 = nodes_info(1,cell_idx{1});
    r2 = nodes_info(1,cell_idx{2});    
    dz = nodes_info(2,cell_idx{3})   - nodes_info(2,cell_idx{1});
    dPhi = nodes_info(3,cell_idx{4}) - nodes_info(3,cell_idx{1});    
    volume  = abs(0.5*(r1+r2).*(r2-r1).*dz.*dPhi);
end




