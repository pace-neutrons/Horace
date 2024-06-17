function  [nodes,inside] = get_interp_nodes(obj,this_proj,char_sizes)
% Return the rectangular grid surrounding input AxesBlock and expressed in
% Crystal Cartesian coordinate system.
% The grid values contain 1 for the nodes which may belong to the AxesBlock
% shape and zeros for the nodes which would not.
%
% The grid is used for calculating interseptions between the AxesBlock
% shape and the reference grid, which contains information about pixels
% positions.
%
% Inputs:
% obj     -- initialized axes block which describes shape for intersection
% this_proj
%         -- aProjection class, descrbing the sapes' coordinate system
% char_sizes
%         -- 4-element array which contains characteristic sizes of the
%            grid to build over the shape to calculate its intersection
%            with the source grid
% Returns:
% nodes  -- 3 element cellarray containing X,Y,Z 3-dimensional coordinates
%           (in ndgrid form) of the rectangular grid used for interpolation
% inside -- 1 element array, containing 1 for nodes which may lie inside of
%           the input shape and 0 for nodes which may not.

% Assuming 3D case. 4D case may be expanded later
if ~this_proj.do_3D_transformation
    error('HPRACE:AxesBlockBase:not_implemented', ...
        '4D grit overlapping is not yet implemented');
end

% get target range in Crystal Cartesian coordinate system, build bounding
% box around the axes block (if it was offsetted -- fine, around offsetted
% point)
[range_cc,in_range] = obj.get_targ_range(this_proj,line_proj('offset',this_proj.offset,'type','aaa'));
in_range = in_range>=0;

offset_cc = this_proj.transform_hkl_to_pix(this_proj.offset(1:3)');
range_cc = range_cc(:,1:3); % 3D case
% expand minimas
range_cc(1,:) = range_cc(1,:)-char_sizes+offset_cc(:)';
% expand maximas
range_cc(2,:) = range_cc(2,:)+char_sizes+offset_cc(:)';

axes = cell(1,3);
grid_size = zeros(1,3);
is_iax = false(1,4);
is_iax(obj.iax) = true;

for i=1:3
    if is_iax(i)
        % ranges are already expanded to include char_size halo.
        if in_range
            ns = 5;
            axes{i} = [range_cc(1,i),range_cc(1,i)+char_sizes(i),...
                offset_cc(i),...
                range_cc(2,i)-char_sizes(i),range_cc(2,i)];
        else
            ns = 4;
            axes{i} = [range_cc(1,i),range_cc(1,i)+char_sizes(i),...
                range_cc(2,i)-char_sizes(i),range_cc(2,i)];
        end
        is_duplicated = [axes{i}(1:end-1) == axes{i}(2:end),false];
        if any(is_duplicated)
            axes{i} = axes{i}(~is_duplicated);
            ns = numel(axes{i});
        end
    else
        step = char_sizes(i);
        ns = floor((range_cc(2,i)-range_cc(1,i))/step);
        if abs(range_cc(1,i)+ns*step-range_cc(2,i))>eps('single')
            step = (range_cc(2,i)-range_cc(1,i))/ns;
        end
        range_cc(2,i) = range_cc(1,i)+ns*step; % redefine max range to avoid round-off errors
        axes{i} = linspace(range_cc(1,i),range_cc(2,i),ns);
    end
    grid_size(i) = ns;
end
[nX,nY,nZ] = ndgrid(axes{:});
ndCoord_cc = [nX(:)';nY(:)';nZ(:)'];
ndCoord = this_proj.transform_pix_to_img(ndCoord_cc);
bin_in = bin_inside(ndCoord,grid_size,obj.img_range(:,1:3),true);

% expand integrated ranges to integration edges if central bins belongs
% to the shape (make shape cylindrical in integrated directions)
for i=1:3
    if is_iax(i)
        bin_idx = {1:grid_size(1),1:grid_size(2),1:grid_size(3)};

        bin_idx{i} = 3;
        cb_idx = ndgridcell(bin_idx);
        cb_idx = sub2ind(grid_size,cb_idx{:});
        center_inside = bin_in(cb_idx);

        bin_idx{i} = 2;
        lb_idx = ndgridcell(bin_idx);
        lb_idx = sub2ind(grid_size,lb_idx{:});
        lm_incide = bin_in(lb_idx);

        bin_idx{i} = 4;
        ub_idx = ndgridcell(bin_idx);
        ub_idx = sub2ind(grid_size,ub_idx{:});
        rm_incide = bin_in(ub_idx);

        cyl_shape = center_inside|lm_incide|rm_incide;
        bin_in(cb_idx)= cyl_shape;
        bin_in(lb_idx)= cyl_shape;
        bin_in(ub_idx)= cyl_shape;
    end
end

inside = double(bin_in);
nodes = {nX,nY,nZ};
end

