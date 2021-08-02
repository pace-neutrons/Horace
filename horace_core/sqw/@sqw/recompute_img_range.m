function img_range = recompute_img_range(w)
% Recalculate img_range for an sqw type object
%
%   >> img_range = recompute_img_range(w)
%
% Input:
% ------
%   w       sqw-type sqw object (i.e. has pixels)
%
% Output:
% -------
%   img_range  img_range as recomputed from the pix array
%
% Recomputing img_range requires the whole of the pixel array to be processed,
% as the pix coordinates are not the same as the projection axes coordinates.
%
npixtot = w.data.pix.num_pixels;

% Catch trivial case of no pixels; convention for size of img_range in this case
if npixtot == 0
    img_range = [Inf, Inf, Inf, Inf; -Inf, -Inf, -Inf, -Inf];
    return
end

% Non-zero number of pixels
h_ave = header_average(w.header_x);
pix_to_rlu = h_ave.expdata(1).u_to_rlu(1:3, 1:3); % pix to rlu
pix0 = h_ave.expdata(1).uoffset;                  % pix offset (in hkl)
u_to_rlu = w.data.u_to_rlu(1:3, 1:3);  % proj to rlu
u0 = w.data.uoffset;                   % proj offset (in hkl)

% matrix to transform pixel coordinates to projection frame
pix_to_proj = u_to_rlu \ pix_to_rlu;

w.data.pix.move_to_first_page();

min_uq = realmax*ones(size(w.data.pix.q_coordinates));
max_uq = -realmax*ones(size(w.data.pix.q_coordinates));
min_dE = realmax;
max_dE = -realmax;
while true  % loop through pages of pixel data
    u_q = pix_to_proj*(w.data.pix.q_coordinates);

    min_uq = min(min(u_q, min_uq), [], 2);
    max_uq = max(max(u_q, max_uq), [], 2);
    min_dE = min(min_dE, min(w.data.pix.dE));
    max_dE = max(max_dE, max(w.data.pix.dE));

    if w.data.pix.has_more()
        w.data.pix.advance();
    else
        break;
    end
end

proj_offset = u_to_rlu\(pix0(1:3) - u0(1:3));
dE_offset = pix0(4) - u0(4);

img_range = zeros(2, 4);
img_range(1, 1:3) = (min_uq + proj_offset)';
img_range(2, 1:3) = (max_uq + proj_offset)';
img_range(1, 4) = min_dE + dE_offset;
img_range(2, 4) = max_dE + dE_offset;
