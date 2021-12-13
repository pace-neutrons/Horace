function  [cube_coord,step] = get_axes_scales(obj)
% Return 4D cube, describing the grid cell of the axes block

step = zeros(4,1);
r0   = zeros(4,1);

step(obj.iax) = (obj.iint(2,:)- obj.iint(1,:))';
r0(obj.iax)  = obj.iint(1,:)';
p = obj.p;
pax_bin_width = cellfun(@(x)abs(x(2)-x(1)),p,'UniformOutput',false);
pax_r0        = cellfun(@(x,bw)(x(1)+0.5*bw),p,pax_bin_width);
pax_bin_width = [pax_bin_width{:}]';


step(obj.pax) = pax_bin_width;
r0(obj.pax) = pax_r0;
r1 = r0+step;
cube_coord = expand_box(r0,r1);