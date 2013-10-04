function [u_to_rlu,lines] = get_det_projections2(efix,en_transfer,Crystal,proj,k_range,det_file_name,psi_range)
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
% goni_angles structure with fields:
%   psi         Angle of u w.r.t. ki (rad)
%   omega       Angle of axis of small goniometer arc w.r.t. notional u
%   dpsi        Correction to psi (rad)
%   gl          Large goniometer arc angle (rad)
%   gs          Small goniometer arc angle (rad)
% 
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
det = detectors_par(det_file_name,'-load');

Gon = goniometer();

% identify blocks of adjacent detectors;
block_nums = split_par(det);          

if exist('psi_range','var')
    num_plots=numel(psi_range);
else
    num_plots=1;
    psi_range(1) = this.psi;
end

lines=cell(num_plots,3);

for i=1:num_plots
    Gon.set_psi(psi_range(i));

    [u_to_rlu, ucoords] =   calc_projections (Gon,det,Crystal,efix,en_transfer,proj.u,proj.v);
%extract 2D coordinates of these detectors belonging to the range;
    [lines{i,1},lines{i,2},lines{i,3}] = split_det(ucoords,block_nums,k_range);
%    [x,y,z] = split_det(ucoords,block_nums,k_range);
 %   plot(x,y,'-r') ; 
end

                           


function [x,y,z] = split_det(ucoords,block_nums,k_range)

nDet = size(ucoords,2);

% identify wawe vectors located in the range requested;
n_constrains =numel(k_range);
correct         = logical(ones(nDet,1));

for i=1:nDet
    for is=1:n_constrains
         iss=4-is;
         if ucoords(iss,i)<k_range{is}(1)||ucoords(iss,i)>=k_range{is}(2)
             correct(i)=false;
             break;
        end
    end
end
ucoords        =ucoords(:,correct);
block_nums = block_nums(correct);

nDet        = size(ucoords,2);
if nDet == 0
    x(1)=0;
    y(1)=0;    
    z(1)=0;    
    return;
end

% indentify number of detector blocks still in range
n_prev      = block_nums(1);
n_blocks  = 1;
for i=2:nDet
   n_current = block_nums(i);
   if n_current ~= n_prev
      n_blocks = n_blocks+1;   
   else
   end
   n_prev = n_current;
end

% form the line, describing detectors in range;
x = zeros(nDet+n_blocks,1);
y = zeros(nDet+n_blocks,1);
z = zeros(nDet+n_blocks,1);
x(1)= ucoords(1,1);
y(1)= ucoords(2,1);
z(1)= ucoords(3,1);
ic = 1;
n_prev  = block_nums(1);
for i=2:nDet
       n_current = block_nums(i);
       if n_current ~= n_prev
          ic = ic+1;              
          x(ic)=NaN;
          y(ic)=NaN;
          z(ic)=NaN;          
      end
       ic = ic+1;                 
       x(ic)=ucoords(1,i);
       y(ic)=ucoords(2,i);
       z(ic)=ucoords(3,i);       
          
      n_prev = n_current;
end
for i=ic:nDet+n_blocks
          x(i)=NaN;
          y(i)=NaN;
          z(i)=NaN;                
end



function  [block_nums,nBlocks] = split_par( par)
% function analyses angular positions of the detectors 
% specified in the the par-data (columns 2 and 3) and identifies the 
% detectos goups, assuming that data arranged in blocks of adjacent   
% (located one after another) detectos; The significance criteria roughly 
% assumes the existence of blocks of at least 3 adjacent detectors. 
% 
%  usage:
%>> par_indexes = split_par( par)
%Input:
%par     --  is data obtanied from Tobyfit Par file with column 2 and 3
%             containing radial and asimutal detectors positions;
% Output:
% par_indexes -- integer array of size par with numbers, specifying the
%                     detectors block
%
% Original author: AB
%
% $Revision$ ($Date$)
%

% how many adjacent detecotors assumed to be a line 
Criteria = 3; % will actually work on four.

if isstruct(par)
    X = par.phi;
    Y = par.azim;
    nDetectors = numel(X);
else
    X = par(2,:);
    Y = par(3,:);
    nDetectors = size(par,2);    
end
distX=X(2:end)-X(1:end-1);
distY=Y(2:end)-Y(1:end-1);
Dist = sqrt(distX.*distX+distY.*distY);
md = sum(Dist)/numel(Dist);

nBlocks =1;
block_nums = zeros(nDetectors,1);
block_nums(1)=1;
for i=1:nDetectors-1
    if Dist(i)>Criteria*md
       nBlocks = nBlocks+1;
    end
    block_nums(i+1)=nBlocks; 

end

