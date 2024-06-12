function  [nodes,inside] = get_interp_nodes(obj,this_proj,char_sizes)
% return nodes of the interpolation grid used as base for identifying grid
% intercept

% Assuming 3D case. 4D case would may be expanded later
if ~this_proj.do_3D_transformation
    error('HPRACE:AxesBlockBase:not_implemented', ...
        '4D grit overlapping is not yet implemented');
end

% get target range in Crystal Cartesian coordinate system
range_cc = obj.get_targ_range(this_proj,line_proj('type','aaa'));
range_cc = range_cc(:,1:3); % 3D case
% expand minimas
range_cc(1,:) = range_cc(1,:)-char_sizes;
% expand maximas
range_cc(2,:) = range_cc(2,:)+char_sizes;

axes = cell(1,3);
grid_size = zeros(1,3);

for i=1:3
    if any(i==obj.iax)
        ns = 4;
        axes{i} = [range_cc(1,i),range_cc(1,i)+char_sizes(i),range_cc(2,i)-char_sizes(i),range_cc(2,i)];
    else
        ns = floor((range_cc(2,i)-range_cc(1,i))/char_sizes(i));
        if abs(range_cc(1,i)+ns*char_sizes(i)-range_cc(2,i))>eps('single')
            ns = ns+1;
        end
        range_cc(2,i) = range_cc(1,i)+ns*char_sizes(i);
        axes{i} = linspace(range_cc(1,i),range_cc(2,i),ns);
    end
    grid_size(i) = ns;
end
[nX,nY,nZ] = ndgrid(axes{:});
ndCoord_cc = [nX(:)';nY(:)';nZ(:)'];
ndCoord = this_proj.transform_pix_to_img(ndCoord_cc);
bin_inside = aProjectionBase.bin_inside(ndCoord,grid_size,obj.img_range(:,1:3),true);


%keep_bins = bin_inside(:)|edge_bins(:);
inside = zeros(grid_size);
inside(bin_inside)=1;
%inside = inside(keep_bins);
%nodes  = ndCoord_cc(keep_bins);
nodes = {nX,nY,nZ};
end

