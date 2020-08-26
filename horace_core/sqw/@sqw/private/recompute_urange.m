function urange = recompute_urange(w)
% Recalculate urange for an sqw type object
%
%   >> urange = recompute_urange(w)
%
% Input:
% ------
%   w       sqw-type sqw object (i.e. has pixels)
%
% Output:
% -------
%   urange  urange as recomputed from the pix array


% Original author: T.G.Perring
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)


% Recomputing urange requires the whole of the pixel array to be processed,
% as the pix coordinates are not the same as the projection axes coordinates.

npixtot=w.data.pix.num_pixels;

% Catch trivial case of no pixels; convention for size of urange in this case
if npixtot==0
    urange=[Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf];
    return
end

% Non-zero number of pixels
h_ave=header_average(w.header);
pix_to_rlu=h_ave.u_to_rlu(1:3,1:3); % pix to rlu
pix0 = h_ave.uoffset;               % pix offset
u_to_rlu=w.data.u_to_rlu(1:3,1:3);  % proj to rlu
u0 = w.data.uoffset;                % proj offset

min_uq = realmax*ones(size(w.data.pix.q_coordinates));
max_uq = -realmax*ones(size(w.data.pix.q_coordinates));
min_dE = realmax;
max_dE = -realmax;
while true  % loop through pages of pixel data
    u_q = (u_to_rlu\pix_to_rlu)*(w.data.pix.q_coordinates) ...
            + u_to_rlu\(pix0(1:3) - u0(1:3));

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

urange=zeros(2, 4);
urange(1, 1:3) = min_uq';
urange(2, 1:3) = max_uq';
urange(1, 4) = min_dE + (pix0(4)-u0(4));
urange(2, 4) = max_dE + (pix0(4)-u0(4));
