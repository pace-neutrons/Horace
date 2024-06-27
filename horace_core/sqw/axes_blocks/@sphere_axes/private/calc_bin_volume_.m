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
    % dR = r_2^3-r_1^3 = (r_2-r_1)*(r_1^2+r_1*r_2+r_2^2);
    ax_r = nodes_info{1};
    nr = 1:numel(ax_r)-1;
    dr = grid_edges{1};
    dR = arrayfun(@(i)abs((ax_r(i)*ax_r(i) + ax_r(i)*ax_r(i+1)+ax_r(i+1)*ax_r(i+1))*dr(i)/3), ...
        nr);
    grid_edges{1} = dR;

    % dTheta = cos(Theta_2)-cos(Theta_1) = -2*sin((Theta_1+Theta_2)/2)*sin((Theta_2-Theta_1)/2);
    if obj.angular_unit_is_rad(1)
        ax_th = nodes_info{2};
    else
        ax_th = deg2rad(nodes_info{2});
        grid_edges{2}= deg2rad(grid_edges{2});
    end
    nth = 1:numel(ax_th)-1;
    dth = grid_edges{2};
    dThet = arrayfun(@(i)abs(2*sin((ax_th(i)+ax_th(i+1))/2)*sin(dth(i)/2)), nth);
    grid_edges{2} = dThet;

    % dPhi
    if obj.angular_unit_is_rad(2)
        dPhi = grid_edges{3};
    else
        dPhi = deg2rad(grid_edges{3});
        grid_edges{3} = dPhi;
    end

    if numel(dR)==1 && numel(dThet) == 1 && dE_regular
        volume = dR(1)*dThet(1)*dPhi(1)*grid_edges{4}(1);
    else
        volume = grid_edges{1}(:)'*obj.get_volume_scale();
        for i=2:4
            volume = repmat(volume(:)',1,numel(grid_edges{i})).*...
                repelem(grid_edges{i}(:)',numel(volume));
        end
    end
else
    if size(nodes_info,2) == 4
        errror('HORACE:sphere_axes:not_implemented', ...
            'Volume of 4-Dimensional grid is not yet implemented')
    end
    cell_idx = get_gridcell_ind(grid_size(1:3));

    r1     = nodes_info(1,cell_idx{1});
    r2     = nodes_info(1,cell_idx{2});
    Theta1 = nodes_info(2,cell_idx{1});
    Theta2 = nodes_info(2,cell_idx{3});
    dPhi   = nodes_info(3,cell_idx{4}) - nodes_info(3,cell_idx{1});
    volume  = obj.get_volume_scale()*abs((r2-r1).*(r2.*r2+r1.*r1+r1.*r2).*sin((Theta1+Theta2)/2).*sin((Theta1-Theta2)/2).*dPhi);
end