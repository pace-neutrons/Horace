function  [cube_coord,step] = get_axes_scales_(obj)
% Return 4D cube, describing the grid cell of the axes block

step = zeros(4,1);
r0   = zeros(4,1);

% integration step
step(obj.iax) = (obj.iint(2,:)- obj.iint(1,:))';

% projection axes step
p = obj.p;
pax_bin_width = cellfun(@(x)abs(x(2)-x(1)),p,'UniformOutput',false);
pax_bin_width = [pax_bin_width{:}]';


step(obj.pax) = pax_bin_width;
cube_coord = expand_box(r0,step);
