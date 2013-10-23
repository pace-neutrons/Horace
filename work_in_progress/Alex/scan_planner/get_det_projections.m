function [u_to_rlu,ucoords] = get_det_projections(this,efix,en_transfer,crystal_cell,proj,goni_angles,det_file_name)
% interface to inrefnal sqw function returning projections of detecors
% positions into 4D reciprocal space of a crystall
% Label pixels in an spe file with coords in the 4D space defined by crystal Cartesian coordinates
% and energy transfer. 
% Allows for correction scattering plane (omega, dpsi, gl, gs) - see Tobyfit for conventions
%
%   >> [u_to_rlu, ucoords] = ...
%    calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det)
%
% Input:
%   efix        Fixed energy (meV)
%   emode       Direct geometry=1, indirect geometry=2
%   alatt       Lattice parameters (Ang^-1)
%   angdeg      Lattice angles (deg)
%   u           First vector (1x3) defining scattering plane (r.l.u.)
%   v           Second vector (1x3) defining scattering plane (r.l.u.)
%   psi         Angle of u w.r.t. ki (rad)
%   omega       Angle of axis of small goniometer arc w.r.t. notional u
%   dpsi        Correction to psi (rad)
%   gl          Large goniometer arc angle (rad)
%   gs          Small goniometer arc angle (rad)

%   det         Data structure of par file (see get_par)
%
% Output:
%   u_to_rlu    Matrix (3x3) of projection axes in reciprocal lattice units
%              i.e. u(:,1) first vector - u(1:3,1) r.l.u. etc.
%              This matrix can be used to convert components of a vector in the
%              projection axes to r.l.u.: v_rlu = u * v_proj
%   ucoords     [4 x npix] array of coordinates of pixels in crystal Cartesian
%              coordinates and energy transfer

%
% $Revision$ ($Date$)
%
det = get_par(det_file_name,'-hor');


nEn = numel(en_transfer);
if size(en_transfer,2)==1
    data.en = en_transfer;
else
    data.en = en_transfer';    
end
ang2rad = pi/180;
%
[det_blocks_nums,nBlocks] = split_par(det);
det = strip_det_keep_edges(det_blocks_nums,det);

nDet=size(det.phi,2);
data.S = ones(nEn,nDet);

[u_to_rlu, ucoords] = ...
    calc_projections (efix, 1, crystal_cell.alatt, crystal_cell.angdeg, proj.u, proj.v, goni_angles.psi*ang2rad, goni_angles.omega*ang2rad, ...
                               goni_angles.dpsi*ang2rad,goni_angles.gl*ang2rad, goni_angles.gs*ang2rad,data,det);

nDet=size(det.phi,2);

nExtDet=3*nDet/2;
x = zeros(nExtDet,1);
y = zeros(nExtDet,1);
z = zeros(nExtDet,1);

x(1:3:nExtDet)=ucoords(1,1:2:nDet);
x(2:3:nExtDet)=ucoords(1,2:2:nDet);
x(3:3:nExtDet)=NaN;
y(1:3:nExtDet)=ucoords(2,1:2:nDet);
y(2:3:nExtDet)=ucoords(2,2:2:nDet);
y(3:3:nExtDet)=NaN;
z(1:3:nExtDet)=ucoords(3,1:2:nDet);
z(2:3:nExtDet)=ucoords(3,2:2:nDet);
z(3:3:nExtDet)=NaN;

hold on
plot3(x,y,z,'-g')


function det = strip_det_keep_edges(ind,det)

% nDet = size(det.phi,2);
% ind=  logical(zeros(nDet,1));
% n_prev = det_block_nums(1);
% ic = 1;
% for i=1:nDet
%   n_current = det_block_nums(i);
%   if n_current ~= n_prev
%       ind(i-1) = true;
%      ind(i) = true;
%      ic = ic+1;   
%   else
%   end
%   n_prev = n_current;
% end
% ind(1)=true;
% ind(end)=true;

det.phi    = det.phi(ind);
det.azim  = det.azim(ind);
det.group = det.group(ind);
det.x2     = det.x2(ind);
det.width  = det.width(ind);
det.height = det.height(ind);