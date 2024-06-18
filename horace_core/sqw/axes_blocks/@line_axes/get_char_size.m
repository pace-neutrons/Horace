function  sz = get_char_size(obj,this_proj)
% Return characteristic sizes of a source grid cell in Crystal Cartesian
% coordinate system
%
%
% Inputs:
% obj        -- initialized instance of AxesBlock class
% this_proj
%    Either:  -- the projection which describes current coordinate system,
%                where this axes block grid is defined.
% Or:         -- 3xNpix array of the axesBlockBase nodes in Crystal Cartesian
%                coordinate system, used to identify characteristic size
%
% Output:
% sz         -- characteristic sizes (sizes of the bounding box)
%               which surounds biggest grid cell in Crystal Cartesian
%               coordinate system


range = obj.img_range;
n_bins = obj.nbins_all_dims;
sz   = (range(2,:)-range(1,:))./n_bins;
if nargin == 1
    return;
end
%
% parse various inputs:
% Assuming 3D case. 4D case would may be expanded later
if ~this_proj.do_3D_transformation
    error('HPRACE:AxesBlockBase:not_implemented', ...
        '4D grit overlapping is not yet implemented');
end
img_coords = zeros(3,8);
q0 = range(:,1:3);
img_coords()

img_coords = this_proj.transform_img_to_pix(img_coords);


x = reshape(img_coords(1,:),nbs(1:3));
y = reshape(img_coords(2,:),nbs(1:3));
z = reshape(img_coords(3,:),nbs(1:3));



grid_nodes = cellfun(@get_grid_node,idxN,'UniformOutput',false);
grid_nodes = [grid_nodes{:}];
sz = min_max(grid_nodes)';
sz = [sz(2,:)-sz(1,:),dE_nodes(2)-dE_nodes(1)];


    function node = get_grid_node(idn)
        id  = num2cell(idn+idx0);
        node = [x(id{:});y(id{:});z(id{:})];
    end
end