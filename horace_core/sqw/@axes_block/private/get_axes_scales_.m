function  [cube_coord,step] = get_axes_scales_(obj)
% Return 4D cube, describing the grid cell of the axes block

step = ((obj.img_range_(2,:)-obj.img_range_(1,:))./obj.nbins_all_dims_)';
r0   = zeros(4,1);

cube_coord = expand_box(r0,step);
