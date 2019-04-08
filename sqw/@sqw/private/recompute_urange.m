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
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)


% Recomputing urange requires the whole of the pixel array to be processed,
% as the pix coordinates are not the same as the projection axes coordinates.

npixtot=size(w.data.pix,2);

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
u_q=(u_to_rlu\pix_to_rlu)*(w.data.pix(1:3,:)) + u_to_rlu\repmat((pix0(1:3)-u0(1:3)),1,npixtot);
urange=zeros(2,4);
urange(1,1:3)=min(u_q,[],2)';
urange(2,1:3)=max(u_q,[],2)';
urange(1,4)=min(w.data.pix(4,:)) + (pix0(4)-u0(4));
urange(2,4)=max(w.data.pix(4,:)) + (pix0(4)-u0(4));
