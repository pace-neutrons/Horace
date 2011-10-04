function [u_to_rlu,ucoords] = get_det_projections1(this,efix,en_transfer,crystal_cell,proj,goni_angles,psi_range)
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
% $Revision: 480 $ ($Date: 2010-07-12 12:56:46 +0100 (Mon, 12 Jul 2010) $)
%
Np = 100;
ndet=Np;

ph_min=-20;
ph_max=60;
dPh = (ph_max-ph_min)/(Np-1);



det.group=1:ndet;
det.x2    = 1:ndet;
det.phi   = ph_min:dPh:ph_max;
det.azim =zeros(ndet,1);
det.width=ones(ndet,1);
det.height=ones(ndet,1);

if exist('psi_range','var')
    num_plots=numel(psi_range);
else
    num_plots=1;
    psi_range(1) = goni_angles.psi;
end

nEn = numel(en_transfer);
if size(en_transfer,2)==1
    data.en = en_transfer;
else
    data.en = en_transfer';    
end
ang2rad = pi/180;
%
%[det_blocks_nums,nBlocks] = split_par(det);
%det = strip_det_keep_edges(det_blocks_nums,det);

nDet=size(det.phi,2);
data.S = ones(nEn,nDet);

for i=1:num_plots
    goni_angles.psi = psi_range(i);
    [u_to_rlu, ucoords] = ...
    calc_projections (efix, 1, crystal_cell.alatt, crystal_cell.angdeg, proj.u, proj.v, goni_angles.psi*ang2rad, goni_angles.omega*ang2rad, ...
                               goni_angles.dpsi*ang2rad,goni_angles.gl*ang2rad, goni_angles.gs*ang2rad,data,det);


    hold on
    plot(ucoords(1,:),ucoords(2,:),'-b')
end


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