function data = sqw_op_build_bz_bckgrnd(pageop_obj,r2_ignore,rlu)
%sqw_op_build_bz_bckgrnd builds background out of q-values beyond of the
% specified cut-off radius and moves background signal into first Brilluoin zone.
%
% Inputs:
% pageop_obj -- Initialized instance of PageOp_sqw_op_bin_pixels object providing all necessary data
% r2_ignore  -- square of cut-off radius to select background (A^-2)
% rlu        -- reciprocal lattice vectors for the used lattice
%

% Get access to [9 x Npix] page of pixels data
data = pageop_obj.page_data;

% calculate pixels distances from centre of Crystal Cartesian coordinate system
Q2 = data(1,:).*data(1,:)+data(2,:).*data(2,:)+data(3,:).*data(3,:);
keep = Q2>=r2_ignore; % identify pixels outside of cut-off radius (background)
%keep = Q2<r2_ignore; % foreground
data = data(:,keep);  % select pixels outside of cut-off radius
if isempty(data)
    return;      % leave if this page does not contain background data
end

% Cubic lattice scale in BCC lattice
scale = 2*rlu;
q_coord = data(1:3,:);   % 
img_shift   = round(q_coord./scale(:)).*scale(:); % BRAGG positions
% in the new lattice are located at the even rlu values

% move all q-coordinates into expanded Brillouin zone +-1*rlu size
q_coord  = q_coord - img_shift;

% move 7 cubes with negative coordinates of expanded Brillouin zone into
% the first cube where all q-coordinates are positive
invert = q_coord<0;
q_coord(invert) = -q_coord(invert);

% construct result containing modified coordinates
data(1:3,:) = q_coord;

end