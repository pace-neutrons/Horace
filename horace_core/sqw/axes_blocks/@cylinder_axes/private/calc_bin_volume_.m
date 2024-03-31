function volume = calc_bin_volume_(obj,ax_in_cell)
%CALC_BIN_VOLUME_ calculate the volume of a lattice cell defined by the
%cellarray of lattice axes.
%
% The volume is either single value if all axes bins are the same or the
% 1D array of size of total number of bins in the lattice if some cell
% volumes differ.
%

if ~iscell(ax_in_cell) || numel(ax_in_cell) ~=4
    error('HORACE:cylinder_axes:invalid_argument', ...
        'Input for calc_bin_volume function should be cellarray containing 4 axis. It is: %s', ...
        disp2str(ax_in_cell));
end

grid_sizes = cellfun(@(ax)(ax(2:end)-ax(1:end-1)),ax_in_cell, ...
    'UniformOutput',false);


dE_regular = true;
if abs(min(grid_sizes{4}) - max(grid_sizes{4})) > eps('single') && ...
        abs(min(grid_sizes{3}) - max(grid_sizes{3})) > eps('single')
    dE_regular = false;
end
% dR = r_2^2-r_1^2 = (r_2-r_1)*(r_1+r_2);
ax_r = ax_in_cell{1};
nr = 1:numel(ax_r)-1;
dr = grid_sizes{1};
dR = arrayfun(@(i)abs((ax_r(i)+ax_r(i+1))*dr(i)/2), ...
    nr);
grid_sizes{1} = dR;
%
%grid_sizes{2} = dQ_|| -- linear axes;

% dPhi
if obj.angular_unit_is_rad(1)
    dPhi = grid_sizes{3};
else
    dPhi = deg2rad(grid_sizes{3});
    grid_sizes{3} = dPhi;
end

if numel(dR)==1 && numel(dPhi) == 1 && dE_regular
    volume = dR(1)*grid_sizes{2}(1)*dPhi(1)*grid_sizes{4}(1);
else
    volume = grid_sizes{1}(:)';
    for i=2:4
        volume = repmat(volume(:)',1,numel(grid_sizes{i})).*...
            repelem(grid_sizes{i}(:)',numel(volume));
    end
end