function  sz = get_char_size(obj,this_proj)
% Return characteristic sizes of a source grid cell in Crystal Cartesian
% coordinate system
%
%
% Inputs:
% obj         -- initialized instance of line_axes class
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

range  = obj.img_range;
n_bins = obj.nbins_all_dims;
sz   = (range(2,:)-range(1,:))./n_bins;
if nargin == 1
    return;
end
%
% parse various inputs:
% Assuming 3D case. 4D case would may be expanded later
if ~this_proj.do_3D_transformation
    error('HORACE:line_axes:not_implemented', ...
        '4D grit overlapping is not yet implemented');
end
q_min = range(1,1:3);
q_max = q_min + sz(1:3);
img_coords = expand_box(q_min,q_max);

img_coords = this_proj.transform_img_to_pix(img_coords);


sz = min_max(img_coords)';
sz = [sz(2,:)-sz(1,:),range(2,4)-range(1,4)];
end