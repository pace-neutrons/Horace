function  [cube_coord,step] = get_axes_scales_(obj)
% Return the array of vertices of a 4D hypercube describing the grid cell
% of this axes block
%
% TODO: HACKY, unclear. We try to find cube, which allows to build a grid 
% The characteristic size allows to build a grid, which would contain at
% least one point within the grid

step = 0.5*((obj.img_range_(2,:)-obj.img_range_(1,:))./obj.nbins_all_dims_)';
r0   = zeros(4,1);

cube_coord = expand_box(r0,step);
